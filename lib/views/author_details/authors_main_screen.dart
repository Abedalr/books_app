import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/authors_data.dart';
import 'authors_list_by_category.dart';

class AuthorsMainScreen extends StatefulWidget {
  const AuthorsMainScreen({super.key});

  @override
  State<AuthorsMainScreen> createState() => _AuthorsMainScreenState();
}

class _AuthorsMainScreenState extends State<AuthorsMainScreen> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // قائمة "الأكثر قراءة" مع إضافة لمسات جمالية
  final List<Map<String, String>> trending = [
    {"name": "نجيب محفوظ", "icon": "📜", "color": "0xFFE91E63"},
    {"name": "دوستويفسكي", "icon": "🔍", "color": "0xFF673AB7"},
    {"name": "أحمد خالد توفيق", "icon": "💀", "color": "0xFF607D8B"},
    {"name": "المتنبي", "icon": "✒️", "color": "0xFFFF9800"},
    {"name": "مصطفى محمود", "icon": "🧠", "color": "0xFF4CAF50"},
    {"name": "أسامة المسلم", "icon": "🐉", "color": "0xFF2196F3"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // تصفية الأقسام بناءً على البحث
    final filteredCategories = AuthorsData.categorizedAuthors.where((cat) {
      final categoryName = cat['category'].toString().toLowerCase();
      return categoryName.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. AppBar احترافي مع محرك بحث مدمج
          _buildSliverAppBar(context, isDark, primaryColor),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. قسم الأكثر قراءة (يظهر فقط عند عدم البحث)
                if (searchQuery.isEmpty) _buildTrendingSection(isDark, primaryColor),

                // 3. عنوان الأقسام
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        searchQuery.isEmpty
                            ? "كل التصنيفات"
                            : "نتائج البحث عن: $searchQuery",
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                      ),
                      if (searchQuery.isEmpty)
                        Text(
                          "${filteredCategories.length} قسم",
                          style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. قائمة الأقسام بتصميم Container مودرن
          if (filteredCategories.isEmpty)
            SliverFillRemaining(child: _buildNoResultsState(isDark))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final cat = filteredCategories[index];
                    return _buildCategoryItem(context, cat, isDark, primaryColor);
                  },
                  childCount: filteredCategories.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, Color primary) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : primary,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "المؤلفون والأدباء",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Cairo', color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withBlue(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // حقل البحث الزجاجي
            Positioned(
              bottom: 55,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "ابحث عن قسم (شعر، رواية، فكر...)",
                        hintStyle: TextStyle(color: Colors.white70, fontSize: 12),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
          child: Text("الأكثر قراءة 🔥",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: trending.length,
            itemBuilder: (context, index) {
              final author = trending[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [primary, Colors.blueAccent.withOpacity(0.1)]),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        child: Text(author['icon']!, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(author['name']!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, dynamic> cat, bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthorsListByCategory(category: cat)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(child: Text(cat['icon'], style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat['category'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "استكشف عالم ${cat['category']}",
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primary.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 16),
          const Text("لا توجد نتائج بحث", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}