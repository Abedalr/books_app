import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String? thumbnail;
  final String previewLink;
  final String? downloadPdfUrl;
  final String? localPath;
  final String category;

  // --- الحقول الخاصة بالتوقيت والمفضلة ---
  final DateTime? downloadDate;
  final bool isFavorite;

  String get author => authors.isNotEmpty ? authors.first : 'مؤلف مجهول';

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    this.thumbnail,
    required this.previewLink,
    this.downloadPdfUrl,
    this.localPath,
    this.downloadDate,
    this.category = "عام", // قيمة افتراضية لتجنب المشاكل
    this.isFavorite = false,
  });

  // 1. استدعاء سريع (Shortcut) لتبسيط الكود في الصفحات
  static Book f(DocumentSnapshot doc) => fromFirestore(doc);

  // 2. دالة تحويل البيانات من Firestore (تتعامل مع DocumentSnapshot)
  static Book fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Book(
      id: doc.id,
      title: data['title'] ?? 'عنوان غير معروف',
      authors: data['authors'] != null
          ? List<String>.from(data['authors'])
          : ['مؤلف مجهول'],
      description: data['description'] ?? 'لا يوجد وصف متاح.',
      thumbnail: data['thumbnail'],
      previewLink: data['previewLink'] ?? '',
      downloadPdfUrl: data['downloadPdfUrl'],
      localPath: data['localPath'],
      // التعامل مع Timestamp الخاص بـ Firebase
      downloadDate: data['downloadDate'] != null
          ? (data['downloadDate'] as Timestamp).toDate()
          : null,
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // 3. تحديث دالة copyWith
  Book copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? description,
    String? thumbnail,
    String? previewLink,
    String? downloadPdfUrl,
    String? localPath,
    DateTime? downloadDate,
    bool? isFavorite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      previewLink: previewLink ?? this.previewLink,
      downloadPdfUrl: downloadPdfUrl ?? this.downloadPdfUrl,
      localPath: localPath ?? this.localPath,
      downloadDate: downloadDate ?? this.downloadDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // 4. دالة التحميل من Archive.org
  factory Book.fromArchive(Map<String, dynamic> doc) {
    final String identifier = doc['identifier'] ?? '';
    List<String> parsedAuthors = [];
    if (doc['creator'] != null) {
      if (doc['creator'] is List) {
        parsedAuthors = List<String>.from(doc['creator'].map((e) => e.toString()));
      } else {
        parsedAuthors = [doc['creator'].toString()];
      }
    } else {
      parsedAuthors = ['مؤلف مجهول'];
    }

    return Book(
      id: identifier,
      title: doc['title'] ?? 'عنوان غير معروف',
      authors: parsedAuthors,
      description: doc['description'] ?? 'لا يوجد وصف متاح.',
      thumbnail: "https://archive.org/services/img/$identifier",
      previewLink: "https://archive.org/details/$identifier",
      downloadPdfUrl: "https://archive.org/download/$identifier/$identifier.pdf",
      localPath: null,
      downloadDate: null,
      isFavorite: false,
    );
  }

  // 5. تحويل الكائن إلى Map (للحفظ المحلي)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'description': description,
      'thumbnail': thumbnail,
      'previewLink': previewLink,
      'downloadPdfUrl': downloadPdfUrl,
      'localPath': localPath,
      'downloadDate': downloadDate?.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  // 6. استرجاع الكائن من Map (للقراءة المحلية)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      authors: map['authors'] != null
          ? List<String>.from((map['authors'] as Iterable).map((e) => e.toString()))
          : ['مؤلف مجهول'],
      description: map['description']?.toString() ?? '',
      thumbnail: map['thumbnail']?.toString(),
      previewLink: map['previewLink']?.toString() ?? '',
      downloadPdfUrl: map['downloadPdfUrl']?.toString(),
      localPath: map['localPath']?.toString(),
      downloadDate: map['downloadDate'] != null
          ? DateTime.tryParse(map['downloadDate'])
          : null,
      isFavorite: map['isFavorite'] == 1 || map['isFavorite'] == true,
    );
  }
}