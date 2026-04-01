import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../book_details/pdf_viewer_screen.dart';
import '../../view_models/analytics_provider.dart';

class CompletedBooksScreen extends StatelessWidget {
  const CompletedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب القائمة من الـ Provider
    final analytics = context.watch<AnalyticsProvider>();
    final books = analytics.finishedBooksList;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان الثيم
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final appBarColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "سجل الإنجازات",
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: books.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        itemCount: books.length,
        itemBuilder: (context, index) {
          // عرض الكتب من الأحدث إلى الأقدم (المصفوفة معكوسة جاهزة من الـ Provider عادةً أو نعكسها هنا)
          final reversedBooks = books.reversed.toList();
          final bookData = reversedBooks[index];
          return _buildModernBookCard(context, bookData, isDark);
        },
      ),
    );
  }

  Widget _buildModernBookCard(BuildContext context, Map<String, dynamic> bookData, bool isDark) {
    final String title = bookData['title'] ?? "بدون عنوان";
    final String? path = bookData['path'];
    final String date = bookData['date'] ?? "--/--/----";
    final String category = bookData['category'] ?? "عام";
    final String bookId = bookData['id'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (path != null && path.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    path: path,
                    title: title,
                    category: category,
                    bookId: bookId,
                  ),
                ),
              );
            } else {
              _showErrorSnackBar(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // صورة رمزية أو أيقونة تعبر عن الكتاب
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),

                // تفاصيل الكتاب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // التصنيف (Tag)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo'
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            "تم الإنجاز: $date",
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // سهم الانتقال
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "عذراً، مسار الكتاب غير متوفر حالياً.",
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
                Icons.auto_stories_outlined,
                size: 100,
                color: isDark ? Colors.white10 : Colors.black12
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "أين الإنجازات؟",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
              "كل رحلة تبدأ بكتاب، ابدأ رحلتك الآن!",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 14)
          ),
        ],
      ),
    );
  }
}