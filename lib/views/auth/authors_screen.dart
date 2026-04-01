import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/authors_data.dart';
import '../author_details/authors_list_by_category.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : const Color(0xFF283593);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark, primaryColor),

          // استخدام StreamBuilder لجلب التصنيفات والمؤلفين من Firebase
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('author_categories').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverFillRemaining(child: Center(child: Text("حدث خطأ في جلب البيانات")));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              // تحويل بيانات Firebase إلى القائمة المطلوبة مع دمجها ببيانات AuthorsData المحلية إذا لزم الأمر
              List<Map<String, dynamic>> categories = snapshot.data!.docs.map((doc) {
                return {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                };
              }).toList();

              // إذا كانت المجموعة في Firebase فارغة، نستخدم البيانات المحلية كاحتياط (Fallback)
              if (categories.isEmpty) {
                categories = List<Map<String, dynamic>>.from(AuthorsData.categorizedAuthors);
              }

              // فلترة النتائج بناءً على البحث
              final filteredCategories = categories.where((cat) {
                final name = (cat['category'] ?? "").toString().toLowerCase();
                final search = searchQuery.toLowerCase();
                return name.contains(search);
              }).toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                sliver: filteredCategories.isEmpty
                    ? SliverFillRemaining(child: _buildNoResults(isDark))
                    : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final cat = filteredCategories[index];
                      return _buildProfessionalCategoryCard(context, cat, isDark, primaryColor);
                    },
                    childCount: filteredCategories.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, Color primary) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : primary,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        centerTitle: true,
        title: const Text(
          "المؤلفون والمفكرون",
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
            Positioned(
              right: -30,
              top: 20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(Icons.menu_book_rounded, size: 180, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 65,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: "ابحث عن مؤلف أو قسم معين...",
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Cairo'),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildProfessionalCategoryCard(BuildContext context, Map<String, dynamic> cat, bool isDark, Color primary) {
    // في Firebase، سنخزن الـ authors كقائمة فرعية (Sub-collection) أو Array
    final List authors = cat['authors'] as List? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthorsListByCategory(
                  category: Map<String, dynamic>.from(cat),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary.withOpacity(0.15), primary.withOpacity(0.02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      cat['icon'] ?? "📖",
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  cat['category'] ?? "بدون عنوان",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Cairo'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${authors.length} مؤلف",
                    style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 80, color: isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 20),
          const Text(
            "عذراً، لم نجد نتائج",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}