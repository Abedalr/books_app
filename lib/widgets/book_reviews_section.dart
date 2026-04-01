import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import '../../models/book_model.dart';

class BookReviewsSection extends StatefulWidget {
  final Book book;
  const BookReviewsSection({required this.book, super.key});

  @override
  State<BookReviewsSection> createState() => _BookReviewsSectionState();
}

class _BookReviewsSectionState extends State<BookReviewsSection> {
  final TextEditingController _controller = TextEditingController();
  double _rating = 5.0;

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- الرأس: العنوان وزر عرض الكل ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "آراء القراء",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            if (bookProvider.bookReviews.isNotEmpty)
              TextButton.icon(
                onPressed: () => _showAllBookReviews(context, bookProvider, isDark),
                icon: const Icon(Icons.history, size: 16),
                label: const Text("كل المراجعات", style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // --- حقل كتابة مراجعة جديدة ---
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "أضف مراجعة أو ملخصاً سريعاً لتعم الفائدة...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStarPicker(), // نظام اختيار النجوم التفاعلي
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (_controller.text.trim().isEmpty) return;

                      // إرسال البيانات للـ Provider ليتم حفظها في Firebase
                      // ملاحظة: تأكد أن دالة addBookReview في الـ Provider تستقبل هذه الحقول
                      await bookProvider.addBookReview(
                        bookId: widget.book.id,
                        bookTitle: widget.book.title,
                        bookThumbnail: widget.book.thumbnail,
                        content: _controller.text,
                        rating: _rating,
                      );

                      _controller.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم نشر مراجعتك بنجاح", style: TextStyle(fontFamily: 'Cairo')),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text("نشر", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- قسم العرض: معاينة أول 3 مراجعات ---
        bookProvider.bookReviews.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "لا توجد مراجعات بعد. كن أول من يكتب!",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
            ),
          ),
        )
            : Column(
          children: bookProvider.bookReviews
              .take(3)
              .map((review) => _buildReviewCard(review, isDark))
              .toList(),
        ),
      ],
    );
  }

  // --- ويدجت اختيار النجوم (Star Picker) ---
  Widget _buildStarPicker() {
    return Row(
      children: List.generate(5, (index) => InkWell(
        onTap: () => setState(() => _rating = index + 1.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: 28,
          ),
        ),
      )),
    );
  }

  // --- تصميم كارت المراجعة (Review Card) ---
  Widget _buildReviewCard(Map<String, dynamic> review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.indigo.withAlpha(30),
                backgroundImage: (review['userImage'] != null && review['userImage'] != "")
                    ? NetworkImage(review['userImage'])
                    : null,
                child: (review['userImage'] == null || review['userImage'] == "")
                    ? const Icon(Icons.person, size: 16, color: Colors.indigo)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review['userName'] ?? "مستخدم",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < (review['rating'] ?? 5) ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 14,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['content'] ?? "",
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.black87,
                height: 1.5,
                fontFamily: 'Cairo'
            ),
          ),
        ],
      ),
    );
  }

  // --- النافذة المنبثقة لعرض كافة المراجعات (BottomSheet) ---
  void _showAllBookReviews(BuildContext context, BookProvider p, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "آراء وتلخيصات القراء",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: p.bookReviews.length,
                itemBuilder: (context, index) => _buildReviewCard(p.bookReviews[index], isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}