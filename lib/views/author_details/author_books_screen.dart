import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import '../book_details/book_details_screen.dart';
import '../../models/book_model.dart';
import 'author_full_details_screen.dart'; // تأكد من إنشاء هذه الشاشة لعرض السيرة الكاملة

class AuthorBooksScreen extends StatelessWidget {
  final Map<String, dynamic> authorData;

  const AuthorBooksScreen({super.key, required this.authorData});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);
    final String name = authorData['name'] ?? 'مؤلف غير معروف';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar بتصميم جذاب وتدرج لوني
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Colors.indigo.shade800, Colors.indigo.shade400],
                      ),
                    ),
                  ),
                  // إضافة لمسة فنية (أيقونة كبيرة في الخلفية شفافة)
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(Icons.person, size: 200, color: Colors.white.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),

          // 2. بطاقة النبذة التفاعلية
          SliverToBoxAdapter(
            child: _buildInteractiveBio(context),
          ),

          // 3. قسم "الكتب المتوفرة"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "مؤلفات الكاتب المتاحة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 4. عرض الكتب أو حالة التحميل
          provider.isLoading
              ? const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
              : provider.authorBooks.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final book = provider.authorBooks[index];
                  return _buildEnhancedBookCard(context, book);
                },
                childCount: provider.authorBooks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ويدجت النبذة التفاعلية بتصميم جذاب ---
  Widget _buildInteractiveBio(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthorFullDetailsScreen(author: authorData)),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade50,
                  child: const Icon(Icons.menu_book_rounded, color: Colors.indigo),
                ),
                const SizedBox(width: 12),
                const Text(
                  "لمحة عن المسيرة",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                ),
                const Spacer(),
                const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              authorData['fullBio'] ?? "لا توجد نبذة متوفرة حالياً.",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Center(
              child: Text(
                "إضغط لعرض السيرة الذاتية الكاملة والإنجازات",
                style: TextStyle(color: Colors.indigo.shade300, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- بطاقة كتاب محسنة بصرياً ---
  Widget _buildEnhancedBookCard(BuildContext context, Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // صورة الكتاب مع ظل خفيف
                Hero(
                  tag: book.id,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5, offset: const Offset(2, 2)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        book.thumbnail ?? '',
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildPlaceholder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // تفاصيل الكتاب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authorData['name'],
                        style: TextStyle(color: Colors.indigo.shade300, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSmallInfoChip(Icons.star, Colors.amber, "4.8"),
                          const SizedBox(width: 10),
                          _buildSmallInfoChip(Icons.chrome_reader_mode_outlined, Colors.blue, "عربي"),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInfoChip(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("لم نجد نتائج حالياً", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text("جرب البحث عن مؤلف آخر", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 100,
      color: Colors.grey[200],
      child: const Icon(Icons.book_rounded, color: Colors.grey),
    );
  }
}