import 'package:cloud_firestore/cloud_firestore.dart';

class BookReview {
  final String id;
  final String userId;
  final String userName;
  final String? userImage; // أضفنا الصورة الشخصية
  final String bookId;
  final String bookTitle; // ضروري للسجل
  final String? bookThumbnail; // اختياري للجمالية في السجل
  final String content;
  final double rating;
  final DateTime createdAt;

  BookReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.bookId,
    required this.bookTitle,
    this.bookThumbnail,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookThumbnail': bookThumbnail,
      'content': content,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt), // حفظ كـ Timestamp لسهولة الترتيب
    };
  }

  factory BookReview.fromMap(String id, Map<String, dynamic> map) {
    return BookReview(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? 'كتاب غير معروف',
      bookThumbnail: map['bookThumbnail'],
      content: map['content'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}