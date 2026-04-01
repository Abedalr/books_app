import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../view_models/book_provider.dart';
import '../../models/book_model.dart';

class MyDownloadsScreen extends StatelessWidget {
  const MyDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مكتبتي الأوفلاين"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Consumer<BookProvider>(
          builder: (context, bookProvider, child) {
            final List<Book> offlineBooks = bookProvider.downloadedBooks;

            if (offlineBooks.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: offlineBooks.length,
              itemBuilder: (context, index) {
                final book = offlineBooks[index];
                return _buildBookCard(context, book, bookProvider);
              },
            );
          },
        ),
      ),
    );
  }

  // واجهة في حال عدم وجود كتب
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text(
            "لا توجد كتب محملة حالياً",
            style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "الكتب التي تحملها من المتجر ستظهر هنا لتقرأها في أي وقت بدون إنترنت",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // تصميم بطاقة الكتاب
  Widget _buildBookCard(BuildContext context, Book book, BookProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: book.thumbnail != null
              ? Image.network(
            book.thumbnail!,
            width: 50,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 70,
              color: Colors.indigo.shade50,
              child: const Icon(Icons.broken_image, color: Colors.indigo),
            ),
          )
              : Container(
            width: 50,
            height: 70,
            color: Colors.indigo.shade50,
            child: const Icon(Icons.book, color: Colors.indigo),
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 14),
              SizedBox(width: 4),
              Text("جاهز للقراءة أوفلاين", style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, book, provider),
        ),

        // --- القسم المحدث بناءً على طلبك لفتح الملف وحل مشكلة Null Safety ---
        onTap: () async {
          // 1. نضع القيمة في متغير محلي أولاً (Shadowing) لترقية النوع وإرضاء Dart
          final String? path = book.localPath;

          // 2. نفحص المتغير المحلي للتأكد من وجود المسار والملف فعلياً
          if (path != null && path.isNotEmpty) {
            // فحص إضافي: هل الملف موجود فعلياً في ذاكرة الهاتف؟
            if (await File(path).exists()) {
              final result = await OpenFilex.open(path);

              if (result.type != ResultType.done) {
                _showSnackBar(context, "خطأ في فتح الملف: ${result.message}");
              }
            } else {
              _showSnackBar(context, "الملف لم يعد موجوداً، قد يكون حُذف يدوياً.");
            }
          } else {
            // في حال كان المسار غير موجود في البيانات الأصلية
            _showSnackBar(context, "ملف الكتاب غير موجود محلياً");
          }
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmDelete(BuildContext context, Book book, BookProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("حذف من المكتبة"),
        content: Text("هل أنت متأكد من حذف كتاب '${book.title}'؟ سيتم مسح الملف من ذاكرة الهاتف."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              provider.deleteDownloadedBook(book);
              Navigator.pop(context);
              _showSnackBar(context, "تم الحذف من الذاكرة بنجاح");
            },
            child: const Text("حذف الآن", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}