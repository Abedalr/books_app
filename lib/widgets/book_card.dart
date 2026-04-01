import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../views/book_details/book_details_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان المؤلف مجهولاً لتغيير الستايل (اختياري)
    final bool isUnknownAuthor = book.authors.isEmpty || book.authors.first == 'مؤلف مجهول';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. قسم الصورة (مع معالجة الروابط المعطوبة)
            Expanded(
              flex: 4,
              child: _buildBookImage(book.thumbnail),
            ),

            // 2. قسم النصوص (العنوان والمؤلف)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // عنوان الكتاب
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // اسم المؤلف - تم استخدام join مباشرة لأننا أمّنا المودل
                    Text(
                      book.authors.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: isUnknownAuthor ? Colors.redAccent.shade100 : Colors.grey[600],
                        fontSize: 11,
                        fontStyle: isUnknownAuthor ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت عرض الصورة المحدث
  Widget _buildBookImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        // في حال فشل التحميل بسبب رابط معطوب أو انقطاع إنترنت
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        // إضافة تأثير تحميل بسيط (اختياري)
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      )
          : _buildPlaceholder(),
    );
  }

  // واجهة العرض في حال عدم وجود صورة (Placeholder)
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.indigo.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 30, color: Colors.indigo.withOpacity(0.3)),
          const SizedBox(height: 4),
          const Text(
            "بلا غلاف",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}