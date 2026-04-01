import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  int _totalReadingMinutes = 0;
  int _finishedBooksCount = 0;
  List<int> _weeklyMinutes = List.filled(7, 0);
  Map<String, int> _categoryMinutes = {};
  List<Map<String, dynamic>> _finishedBooksList = [];
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int get totalHours => _totalReadingMinutes ~/ 60;
  int get remainingMinutes => _totalReadingMinutes % 60;
  int get booksFinished => _finishedBooksCount;
  List<Map<String, dynamic>> get finishedBooksList => _finishedBooksList;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  int get totalXP => (_finishedBooksCount * 150) + (_totalReadingMinutes * 2);
  int get currentLevel => (totalXP / 1000).floor() + 1;

  double get nextLevelProgress {
    double progress = (totalXP % 1000) / 1000;
    return progress.isNaN ? 0.0 : progress;
  }

  String get userRank {
    if (currentLevel >= 20) return "حكيم المكتبة الأسطوري 👑";
    if (currentLevel >= 10) return "باحث مخضرم 🎓";
    if (currentLevel >= 5) return "قارئ نهم 📚";
    return "مستكشف مبتدئ 🌱";
  }

  List<double> get weeklyHoursData => _weeklyMinutes.map((m) => m / 60.0).toList();

  Map<String, double> get categoryStats {
    if (_totalReadingMinutes <= 0 || _categoryMinutes.isEmpty) return {};
    return _categoryMinutes.map((key, val) =>
        MapEntry(key, (val / _totalReadingMinutes) * 100));
  }

  // --- الوظائف الأساسية ---

  Future<void> fetchUserStats() async {
    if (_uid == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      // جلب البيانات من السيرفر، وإذا فشل (أوفلاين) بجيبها من الكاش تلقائياً
      var userDoc = await _db.collection('users').doc(_uid).get();

      if (userDoc.exists) {
        var data = userDoc.data()!;
        _totalReadingMinutes = data['totalMinutes'] ?? 0;
        _finishedBooksCount = data['finishedBooks'] ?? 0;
        _weeklyMinutes = List<int>.from(data['weeklyMinutes'] ?? List.filled(7, 0));
        _categoryMinutes = Map<String, int>.from(data['categoryMinutes'] ?? {});
        _finishedBooksList = List<Map<String, dynamic>>.from(data['finishedBooksList'] ?? []);
      }

      // جلب قائمة المتصدرين
      await fetchLeaderboard();

    } catch (e) {
      debugPrint("⚠️ فشل جلب البيانات (قد يكون بسبب الأوفلاين): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      // في قائمة المتصدرين، يفضل نطلبها من السيرفر مباشرة عشان تكون "صادقة"
      // لكن لو أوفلاين، الفايربيز رح يعطينا آخر نسخة كاش عنده
      var snapshot = await _db.collection('users')
          .orderBy('finishedBooks', descending: true)
          .limit(5)
          .get();

      _leaderboard = snapshot.docs.map((doc) => {
        'displayName': doc.data()['displayName'] ?? 'مستخدم مجهول',
        'booksFinished': doc.data()['finishedBooks'] ?? 0,
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ خطأ في جلب المتصدرين: $e");
    }
  }

  Future<void> addReadingSession(int seconds, String category) async {
    if (seconds < 5 || _uid == null) return;

    int gainedMinutes = (seconds / 60).ceil();
    if (gainedMinutes == 0) gainedMinutes = 1;

    _totalReadingMinutes += gainedMinutes;
    _weeklyMinutes[DateTime.now().weekday % 7] += gainedMinutes;
    _categoryMinutes[category] = (_categoryMinutes[category] ?? 0) + gainedMinutes;

    notifyListeners();

    try {
      // لاحظ هنا: استخدمنا .update() وبدون await طويل
      // الفايربيز سيتكفل بمزامنة البيانات فور توفر الإنترنت
      _db.collection('users').doc(_uid).update({
        'totalMinutes': _totalReadingMinutes,
        'weeklyMinutes': _weeklyMinutes,
        'categoryMinutes': _categoryMinutes,
        'totalXP': totalXP,
        'lastRead': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ فشل التزامن مع السيرفر (سيتم الرفع لاحقاً): $e");
    }
  }

  Future<bool> markBookAsFinished(String bookId, String title, String path, String category) async {
    if (_uid == null) return false;

    bool alreadyExists = _finishedBooksList.any((book) => book['id'] == bookId);
    if (alreadyExists) return false;

    final newBook = {
      'id': bookId,
      'title': title,
      'path': path,
      'category': category,
      'date': DateFormat('yyyy/MM/dd').format(DateTime.now()),
    };

    _finishedBooksList.add(newBook);
    _finishedBooksCount++;
    notifyListeners();

    try {
      // تحديث محلي فوري ومزامنة خلفية
      await _db.collection('users').doc(_uid).update({
        'finishedBooks': _finishedBooksCount,
        'finishedBooksList': _finishedBooksList,
        'totalXP': totalXP,
      });

      await fetchLeaderboard();
      return true;
    } catch (e) {
      // في حالة الأوفلاين، العملية ستنجح محلياً ولن تعطي Error في معظم الحالات
      debugPrint("⚠️ تحديث محلي فقط (بانتظار الإنترنت)");
      return true;
    }
  }
}