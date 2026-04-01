import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/book_model.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  final _settingsBox = Hive.box('settings');
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== إعدادات الصورة الشخصية والسمة ====================
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  final String _imageKey = 'profile_image_path';

  String? get profileImagePath => _profileImagePath;
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    isDarkMode = value;
    _settingsBox.put('isDarkMode', isDarkMode);
    notifyListeners();
  }

  void loadTheme() {
    isDarkMode = _settingsBox.get('isDarkMode', defaultValue: false);
    _profileImagePath = _settingsBox.get(_imageKey);
    notifyListeners();
  }

  // ==================== قوائم الكتب والبيانات ====================
  final Map<String, CancelToken> _cancelTokens = {};
  List<String> pausedBooks = [];

  List<Book> programmingBooks = [];
  List<Book> fictionBooks = [];
  List<Book> financeBooks = []; // قائمة جديدة لقسم المال والنجاح
  List<Book> searchResults = [];
  List<Book> categoryBooks = [];
  List<Book> favoriteBooks = [];
  List<Book> authorBooks = [];
  List<Book> downloadedBooks = [];
  List<Book> likedBooksFromFirebase = [];
  List<Map<String, dynamic>> userComments = [];
  List<Map<String, dynamic>> _bookReviews = [];

  List<Map<String, dynamic>> get bookReviews => _bookReviews;

  List<Book> get books => [
    ...programmingBooks,
    ...fictionBooks,
    ...financeBooks,
    ...searchResults,
    ...categoryBooks,
    ...favoriteBooks,
    ...downloadedBooks,
  ];

  bool _isReviewsLoading = false;
  bool get isReviewsLoading => _isReviewsLoading;

  double downloadProgress = 0;
  int totalFavorites = 0;
  int totalComments = 0;
  String readerLevel = "مبتدئ";
  bool isLoading = false;

  Map<String, Map<String, dynamic>> downloadingBooksProgress = {};
  Book? lastReadBook;

  BookProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    loadTheme();
    loadLastReadBook();
    await loadDownloadedBooks();
    _loadStatsFromCache();

    loadLibrary().catchError((e) {
      debugPrint("تنبيه: يعمل في وضع الأوفلاين الجزئي");
    });
  }

  void _loadStatsFromCache() {
    totalComments = _settingsBox.get('cached_total_comments', defaultValue: 0);
    readerLevel = _settingsBox.get('cached_reader_level', defaultValue: "مبتدئ");
    notifyListeners();
  }

  // ==================== ميزة البحث الذكي (الهجين) ====================
  List<Book> _localSearch(String query) {
    final searchTerm = query.toLowerCase();
    return books.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();
      return title.contains(searchTerm) ||
          author.contains(searchTerm) ||
          (book.description?.toLowerCase().contains(searchTerm) ?? false);
    }).toList();
  }

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) return;
    isLoading = true;
    searchResults = _localSearch(query);
    notifyListeners();

    try {
      // تم ربطها بالـ API المحسن الذي يفلتر اللغة العربية تلقائياً
      final remoteResults = await _apiService.fetchFromArchive(query, limit: 40)
          .timeout(const Duration(seconds: 7));

      final Map<String, Book> combined = {};
      for (var b in searchResults) { combined[b.id] = b; }
      for (var b in remoteResults) { combined[b.id] = b; }

      searchResults = combined.values.toList();
    } catch (e) {
      debugPrint("البحث السحابي غير متاح: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==================== نظام المراجعات والآراء (Firestore) ====================
  Future<void> addBookReview({
    required String bookId,
    required String content,
    required double rating,
    required String bookTitle,
    String? bookThumbnail,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || content.trim().isEmpty) return;

    try {
      await _firestore.collection('book_reviews').add({
        'bookId': bookId,
        'bookTitle': bookTitle,
        'userId': user.uid,
        'userName': user.displayName ?? "قارئ مجهول",
        'userImage': user.photoURL ?? "",
        'content': content.trim(),
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));
      await fetchBookReviews(bookId);
      await getUserStats();
    } catch (e) {
      debugPrint("خطأ في إضافة المراجعة: $e");
    }
  }

  Future<void> fetchBookReviews(String bookId) async {
    _isReviewsLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('book_reviews')
          .where('bookId', isEqualTo: bookId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));

      _bookReviews = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      _bookReviews = [];
    } finally {
      _isReviewsLoading = false;
      notifyListeners();
    }
  }

  // ==================== إدارة الملف الشخصي والقراءة الأخيرة ====================
  Future<void> changeProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 500);
      if (pickedFile != null) {
        _profileImagePath = pickedFile.path;
        await _settingsBox.put(_imageKey, _profileImagePath);
        notifyListeners();
      }
    } catch (e) { debugPrint("خطأ صورة الملف: $e"); }
  }

  Future<void> setLastReadBook(Book book) async {
    lastReadBook = book;
    notifyListeners();
    await _settingsBox.put('last_book_data', book.toMap());
  }

  void loadLastReadBook() {
    final Map<dynamic, dynamic>? bookData = _settingsBox.get('last_book_data');
    if (bookData != null) {
      lastReadBook = Book.fromMap(Map<String, dynamic>.from(bookData));
      notifyListeners();
    }
  }

  // ==================== نظام التحميل الذكي ====================
  void togglePauseDownload(String bookId) {
    if (pausedBooks.contains(bookId)) {
      pausedBooks.remove(bookId);
    } else {
      _cancelTokens[bookId]?.cancel("Paused");
      pausedBooks.add(bookId);
    }
    notifyListeners();
  }

  void cancelDownload(String bookId) {
    _cancelTokens[bookId]?.cancel("Cancelled");
    _cancelTokens.remove(bookId);
    downloadingBooksProgress.remove(bookId);
    notifyListeners();
  }

  Future<void> startDownload(Book book) async {
    if (downloadingBooksProgress.containsKey(book.id)) return;
    final cancelToken = CancelToken();
    _cancelTokens[book.id] = cancelToken;
    try {
      downloadingBooksProgress[book.id] = {'title': book.title, 'progress': 0.0};
      notifyListeners();

      final directory = await getApplicationDocumentsDirectory();
      final String filePath = "${directory.path}/${book.id.replaceAll(RegExp(r'[^\w]'), '_')}.pdf";

      String? downloadUrl = await _apiService.getDownloadUrl(book.id, cancelToken);

      await _apiService.dio.download(downloadUrl!, filePath, cancelToken: cancelToken, onReceiveProgress: (received, total) {
        if (total != -1 && downloadingBooksProgress.containsKey(book.id)) {
          downloadingBooksProgress[book.id]!['progress'] = received / total;
          notifyListeners();
        }
      });

      final file = File(filePath);
      if (await file.length() < 1000) {
        if (await file.exists()) await file.delete();
        throw "PDF Not Available";
      }
      await markAsDownloaded(book, filePath);
    } catch (e) {
      debugPrint("Download error: $e");
      downloadingBooksProgress.remove(book.id);
    } finally {
      if (!pausedBooks.contains(book.id)) {
        _cancelTokens.remove(book.id);
        downloadingBooksProgress.remove(book.id);
      }
      notifyListeners();
    }
  }

  Future<void> markAsDownloaded(Book book, String path) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final downloadedBook = book.copyWith(localPath: path, downloadDate: DateTime.now());
    String userBoxName = 'offline_books_${user.uid}';
    var userBox = await Hive.openBox(userBoxName);

    List savedFiles = userBox.get('books', defaultValue: []);
    savedFiles.removeWhere((item) => item['id'] == book.id);
    savedFiles.add(downloadedBook.toMap());

    await userBox.put('books', savedFiles);
    await loadDownloadedBooks();

    int favIndex = favoriteBooks.indexWhere((b) => b.id == book.id);
    if (favIndex != -1) favoriteBooks[favIndex] = downloadedBook;

    await getUserStats();
    notifyListeners();
  }

  Future<void> loadDownloadedBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      downloadedBooks = [];
      notifyListeners();
      return;
    }
    try {
      String userBoxName = 'offline_books_${user.uid}';
      var userBox = await Hive.openBox(userBoxName);
      List rawList = userBox.get('books', defaultValue: []);
      downloadedBooks = rawList.map((item) => Book.fromMap(Map<String, dynamic>.from(item))).toList();
      notifyListeners();
    } catch (e) { debugPrint("خطأ تحميل الكتب المحملة: $e"); }
  }

  Future<void> deleteDownloadedBook(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      if (book.localPath != null) {
        final file = File(book.localPath!);
        if (await file.exists()) await file.delete();
      }
      String userBoxName = 'offline_books_${user.uid}';
      var userBox = await Hive.openBox(userBoxName);
      List savedFiles = userBox.get('books', defaultValue: []);
      savedFiles.removeWhere((item) => item['id'] == book.id);
      await userBox.put('books', savedFiles);

      await loadDownloadedBooks();
    } catch (e) {}
  }

  Future<void> fetchBooksByAuthor(String authorName) async {
    isLoading = true;
    authorBooks = [];
    notifyListeners();
    authorBooks = await _apiService.fetchFromArchive('creator:("$authorName")');
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBooksByCategoryName(String categoryQuery) async {
    isLoading = true;
    categoryBooks = [];
    notifyListeners();
    categoryBooks = await _apiService.fetchFromArchive(categoryQuery);
    isLoading = false;
    notifyListeners();
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      final allCurrentBooks = [...books, ...likedBooksFromFirebase, ...downloadedBooks];
      try {
        return allCurrentBooks.firstWhere((b) => b.id == bookId);
      } catch (_) {
        return await _apiService.fetchBookMetadata(bookId);
      }
    } catch (e) {}
    return null;
  }

  // ==================== وظائف Firebase (التعليقات والإعجاب) ====================
  Future<void> loadUserComments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 5));
      userComments = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      totalComments = userComments.length;
    } catch (e) { debugPrint("التعليقات أوفلاين"); }
    notifyListeners();
  }

  Future<void> addComment(Book book, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;
    try {
      await _firestore.collection('comments').add({
        'userId': user.uid,
        'bookId': book.id,
        'bookTitle': book.title,
        'bookImage': book.thumbnail,
        'authorName': book.author,
        'text': text.trim(),
        'userName': user.displayName ?? "مستخدم",
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));
      await loadUserComments();
      await getUserStats();
    } catch (e) {}
  }

  Future<void> loadLikedBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likes')
          .get()
          .timeout(const Duration(seconds: 5));

      List<Book> temp = [];
      for (var doc in snapshot.docs) {
        Book? b = await getBookById(doc['bookId']);
        if (b != null) temp.add(b);
      }
      likedBooksFromFirebase = temp;
    } catch (e) {}
    notifyListeners();
  }

  Future<void> toggleLike(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid).collection('likes').doc(book.id);
    try {
      final doc = await docRef.get().timeout(const Duration(seconds: 4));
      if (doc.exists) {
        await docRef.delete();
        likedBooksFromFirebase.removeWhere((b) => b.id == book.id);
      } else {
        await docRef.set({'bookId': book.id, 'timestamp': FieldValue.serverTimestamp()});
        likedBooksFromFirebase.add(book);
      }
      notifyListeners();
    } catch (e) { debugPrint("الإعجاب يحتاج إنترنت"); }
  }

  Future<void> toggleFavorite(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid).collection('favorites').doc(book.id);

    if (isFavorite(book.id)) {
      favoriteBooks.removeWhere((item) => item.id == book.id);
      notifyListeners();
      try { await docRef.delete(); } catch (_) {}
    } else {
      final isDownloaded = downloadedBooks.any((d) => d.id == book.id);
      final bookToAdd = isDownloaded
          ? downloadedBooks.firstWhere((d) => d.id == book.id)
          : book.copyWith(isFavorite: true);

      if (!favoriteBooks.any((b) => b.id == book.id)) favoriteBooks.add(bookToAdd);
      notifyListeners();
      try { await docRef.set(bookToAdd.toMap()); } catch (_) {}
    }
    totalFavorites = favoriteBooks.length;
  }

  bool isFavorite(String bookId) => favoriteBooks.any((book) => book.id == bookId);

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get()
          .timeout(const Duration(seconds: 5));

      List<Book> cloudFavs = snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
      favoriteBooks = cloudFavs.map((favBook) {
        return downloadedBooks.firstWhere((d) => d.id == favBook.id, orElse: () => favBook);
      }).toList();

      totalFavorites = favoriteBooks.length;
      notifyListeners();
    } catch (e) { debugPrint("المفضلة تعمل في وضع الأوفلاين"); }
  }

  // ==================== المكتبة والإحصائيات الذكية (تحديث الدوال الجديدة) ====================
  Future<void> loadLibrary() async {
    if (downloadedBooks.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    try {
      // تم التحديث لاستخدام الدوال المتخصصة من ApiService التي تضمن جودة "الموسوعة"
      final results = await Future.wait([
        _apiService.fetchProgrammingBooks(),      // برمجة
        _apiService.fetchFictionBooks(),          // روايات
        _apiService.fetchFinanceAndSelfHelp(),    // مال ونجاح
        loadFavorites(),
        loadLikedBooks(),
        loadUserComments(),
        getUserStats(),
      ]).timeout(const Duration(seconds: 12));

      programmingBooks = results[0] as List<Book>;
      fictionBooks = results[1] as List<Book>;
      financeBooks = results[2] as List<Book>;

    } catch (e) {
      debugPrint("تم تحميل المكتبة جزئياً");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final commentSnap = await _firestore.collection('comments').where('userId', isEqualTo: user.uid).get();
      final reviewSnap = await _firestore.collection('book_reviews').where('userId', isEqualTo: user.uid).get();

      totalComments = commentSnap.docs.length + reviewSnap.docs.length;

      if (totalComments > 20 || downloadedBooks.length > 10) readerLevel = "قارئ متميز";
      else if (totalComments > 5 || downloadedBooks.length > 3) readerLevel = "مطلع";
      else readerLevel = "مبتدئ";

      await _settingsBox.put('cached_total_comments', totalComments);
      await _settingsBox.put('cached_reader_level', readerLevel);

      notifyListeners();
    } catch (e) {
      debugPrint("فشل تحديث الإحصائيات الحية");
    }
  }
}