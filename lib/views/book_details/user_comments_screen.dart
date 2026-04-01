import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';
import 'book_details_screen.dart';

class UserCommentsScreen extends StatefulWidget {
  const UserCommentsScreen({super.key});

  @override
  State<UserCommentsScreen> createState() => _UserCommentsScreenState();
}

class _UserCommentsScreenState extends State<UserCommentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadUserComments();
    });
  }

  // دالة لتأكيد الحذف
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف التعليق"),
        content: const Text("هل أنت متأكد من رغبتك في حذف هذا التعليق نهائياً؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("نشاطي والتعليقات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.userComments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.comment_bank_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text("سجل تعليقاتك فارغ حالياً", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: provider.userComments.length,
            itemBuilder: (context, index) {
              final comment = provider.userComments[index];
              final dynamic timestamp = comment['timestamp'] ?? comment['createdAt'];
              final String commentId = comment['id'] ?? "";

              return Dismissible(
                key: Key(commentId),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => _confirmDelete(context),
                onDismissed: (direction) async {
                  // هنا نستخدم دالة الحذف من الـ Provider
                  await FirebaseFirestore.instance.collection('comments').doc(commentId).delete();
                  provider.loadUserComments(); // تحديث القائمة
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف التعليق")));
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft, // لليسار لأن التطبيق عربي
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        Book? fullBook = await provider.getBookById(comment['bookId']);
                        if (mounted) Navigator.pop(context);

                        if (fullBook != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BookDetailsScreen(book: fullBook)),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // بوستر الكتاب بشكل أنيق
                                Hero(
                                  tag: 'book_img_$commentId',
                                  child: Container(
                                    width: 55,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: (comment['bookImage'] != null && comment['bookImage'] != "")
                                          ? Image.network(comment['bookImage'], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.book))
                                          : const Icon(Icons.book),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // معلومات الكتاب
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['bookTitle'] ?? "عنوان غير متوفر",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment['authorName'] ?? "مؤلف مجهول",
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 8),
                                      // نص التعليق بتصميم "فقاعة" مبسطة
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.black26 : Colors.grey.shade100,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          comment['text'] ?? "",
                                          style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white : Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (timestamp is Timestamp)
                                      ? DateFormat('dd MMM yyyy | hh:mm a', 'ar').format(timestamp.toDate())
                                      : "منذ قليل",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                // أيقونة حذف سريعة بدلاً من السحب فقط
                                IconButton(
                                  onPressed: () async {
                                    bool? del = await _confirmDelete(context);
                                    if (del == true) {
                                      await FirebaseFirestore.instance.collection('comments').doc(commentId).delete();
                                      provider.loadUserComments();
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}