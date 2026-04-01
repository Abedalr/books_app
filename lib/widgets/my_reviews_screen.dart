import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/book_model.dart';
import '../../view_models/book_provider.dart';
import '../views/book_details/book_details_screen.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: const Text("سجل مراجعاتي",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text("يرجى تسجيل الدخول أولاً", style: TextStyle(fontFamily: 'Cairo')))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('book_reviews')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("لم تقم بكتابة أي مراجعة بعد",
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.grey))
            );
          }

          // تحويل الـ docs إلى قائمة مرتبة برمجياً لضمان الدقة
          final docs = snapshot.data!.docs;
          docs.sort((a, b) {
            Timestamp t1 = a['createdAt'] ?? Timestamp.now();
            Timestamp t2 = b['createdAt'] ?? Timestamp.now();
            return t2.compareTo(t1);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final review = doc.data() as Map<String, dynamic>;
              return _buildReviewCard(context, doc.id, review, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, String reviewId, Map<String, dynamic> review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias, // لضمان أن تأثير النقر لا يخرج عن الحواف المنحنية
        child: InkWell(
          onTap: () {
            print("🚀 جاري الانتقال للكتاب: ${review['bookId']}");
            _navigateToBook(context, review['bookId']);
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // غلاف الكتاب
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: review['bookThumbnail'] != null && review['bookThumbnail'] != ""
                          ? Image.network(
                        review['bookThumbnail'],
                        width: 45, height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(width: 45, height: 65, color: Colors.grey[300], child: const Icon(Icons.book_outlined)),
                      )
                          : Container(width: 45, height: 65, color: Colors.grey[300], child: const Icon(Icons.book_outlined)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['bookTitle'] ?? "عنوان غير معروف",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                                fontSize: 15,
                                fontFamily: 'Cairo'
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildStars(review['rating'] ?? 5),
                        ],
                      ),
                    ),
                    // زر الحذف مع مساحة لمس معزولة
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDelete(context, reviewId),
                    ),
                  ],
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1)
                ),
                Text(
                  review['content'] ?? "",
                  style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.black87,
                      height: 1.5,
                      fontFamily: 'Cairo',
                      fontSize: 13
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(review['createdAt']),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Text(
                      "اضغط للتفاصيل ←",
                      style: TextStyle(fontSize: 10, color: Colors.indigo, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBook(BuildContext context, String? bookId) async {
    if (bookId == null || bookId.isEmpty) return;

    // إظهار اللودينج
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator())
    );

    try {
      final doc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();

      if (context.mounted) Navigator.pop(context); // إغلاق اللودينج

      if (doc.exists) {
        final bookData = Book.fromFirestore(doc);
        if (context.mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => BookDetailsScreen(book: bookData))
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("عذراً، بيانات الكتاب الأصلية غير متوفرة حالياً", style: TextStyle(fontFamily: 'Cairo')))
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      debugPrint("Error: $e");
    }
  }

  Widget _buildStars(num rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 16
      )),
    );
  }

  String _formatDate(dynamic ts) {
    if (ts is Timestamp) {
      return DateFormat('yyyy/MM/dd - hh:mm a').format(ts.toDate());
    }
    return "";
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("حذف المراجعة", style: TextStyle(fontFamily: 'Cairo')),
        content: const Text("هل تريد حذف هذا الرأي نهائياً؟", style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('book_reviews').doc(id).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}