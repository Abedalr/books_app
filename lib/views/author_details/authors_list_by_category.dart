import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import 'author_books_screen.dart';

class AuthorsListByCategory extends StatefulWidget {
  final Map<String, dynamic> category;

  const AuthorsListByCategory({super.key, required this.category});

  @override
  State<AuthorsListByCategory> createState() => _AuthorsListByCategoryState();
}

class _AuthorsListByCategoryState extends State<AuthorsListByCategory> {
  String searchAuthor = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // التأكد من أن القائمة يتم التعامل معها كقائمة ديناميكية
    final List allAuthors = widget.category['authors'] as List;

    // منطق الفلترة المحسن
    final filteredAuthors = allAuthors.where((author) {
      final Map<String, dynamic> authorMap = Map<String, dynamic>.from(author);
      final name = authorMap['name'].toString().toLowerCase();
      return name.contains(searchAuthor.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark, primaryColor),

          SliverToBoxAdapter(
            child: _buildSearchBar(isDark, primaryColor),
          ),

          filteredAuthors.isEmpty
              ? SliverFillRemaining(child: _buildNoResults(isDark))
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // تحويل العنصر إلى Map لضمان الوصول الآمن للحقول
                  final author = Map<String, dynamic>.from(filteredAuthors[index]);
                  return _buildAuthorCard(context, author, isDark, primaryColor);
                },
                childCount: filteredAuthors.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, Color primary) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.category['category'] ?? "قسم غير معروف",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Cairo', color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withBlue(100)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: 0.15,
                child: Text(widget.category['icon'] ?? "📖", style: const TextStyle(fontSize: 80)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchAuthor = value),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "ابحث عن مؤلف في هذا القسم...",
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            prefixIcon: Icon(Icons.person_search_rounded, color: primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorCard(BuildContext context, Map<String, dynamic> author, bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          Provider.of<BookProvider>(context, listen: false).fetchBooksByAuthor(author['name']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthorBooksScreen(authorData: author)),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildAuthorAvatar(author['name'] ?? "?", primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author['name'] ?? "غير معروف",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author['fullBio'] ?? "لا يوجد وصف متوفر لهذا المؤلف",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    // تمرير الحقل بأمان للويدجت
                    _buildTopWorkBadge(author['topWorks'], isDark),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar(String name, Color primary) {
    String initial = name.isNotEmpty ? name[0] : "?";
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.8), primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24, fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  // تم تعديل هذا الويدجت ليكون "مضاداً للانفجار" (Null Safety)
  Widget _buildTopWorkBadge(dynamic topWorks, bool isDark) {
    String displayWork = "استكشف الأعمال";

    if (topWorks != null) {
      if (topWorks is List && topWorks.isNotEmpty) {
        displayWork = topWorks[0].toString();
      } else if (topWorks is String && topWorks.isNotEmpty) {
        displayWork = topWorks.split('،')[0];
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              displayWork,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 70, color: isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "لا يوجد مؤلف بهذا الاسم في هذا القسم",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}