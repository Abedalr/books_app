import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import '../../widgets/book_card.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryQuery;

  const CategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryQuery,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final provider = Provider.of<BookProvider>(context, listen: false);
        provider.categoryBooks = [];
        provider.fetchBooksByCategoryName(widget.categoryQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar احترافي بتأثير متدرج
              SliverAppBar(
                expandedHeight: 100,
                pinned: true,
                elevation: 0,
                centerTitle: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.indigo[800],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.categoryTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                            : [Colors.indigo[900]!, Colors.indigo[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // حالة التحميل
              if (provider.isLoading)
                SliverFillRemaining(
                  child: _buildLoadingState(isDark),
                )

              // حالة عدم وجود نتائج
              else if (provider.categoryBooks.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(context, isDark),
                )

              // عرض النتائج
              else ...[
                  SliverToBoxAdapter(
                    child: _buildResultInfoBar(provider.categoryBooks.length, isDark),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return BookCard(book: provider.categoryBooks[index]);
                        },
                        childCount: provider.categoryBooks.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 25),
        Text(
          "جاري ترتيب الرفوف لـ ${widget.categoryTitle}...",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.indigo[900],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 100, color: isDark ? Colors.white10 : Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "لم نجد كتباً في هذا القسم حالياً",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            "تأكد من اتصالك بالإنترنت أو جرب البحث في قسم آخر من أقسام الموسوعة.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("العودة للخلف", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildResultInfoBar(int count, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.sort_rounded, size: 20, color: isDark ? Colors.indigo[200] : Colors.indigo),
          const SizedBox(width: 10),
          Text(
            "نتائج البحث في ${widget.categoryTitle}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.indigo[900],
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            "$count كتاب",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}