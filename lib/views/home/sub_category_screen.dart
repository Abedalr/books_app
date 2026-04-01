import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'category_screen.dart';

class SubCategoryScreen extends StatelessWidget {
  final String mainCategoryName;
  // تم التعديل هنا ليكون dynamic بدلاً من String لحل مشكلة الـ Keywords
  final List<Map<String, dynamic>> subCategories;
  final Color themeColor;

  const SubCategoryScreen({
    super.key,
    required this.mainCategoryName,
    required this.subCategories,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header مطور مع تأثير Gradient و Mask
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: themeColor,
            leading: _buildBackButton(context),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                mainCategoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontFamily: 'Cairo',
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية متدرجة احترافية
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeColor,
                          themeColor.darken(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // أيقونة ديكورية كبيرة في الخلفية
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Opacity(
                      opacity: 0.2,
                      child: const Icon(Icons.auto_stories, size: 200, color: Colors.white),
                    ),
                  ),
                  // طبقة تنعيم (Overlay) لضمان وضوح النص
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // محتوى القائمة بتصميم عصري
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final sub = subCategories[index];
                  final String subName = sub['name'] ?? 'قسم غير مسمى';
                  final String subQuery = sub['query'] ?? '';

                  return _buildSubCategoryCard(context, subName, subQuery, isDark, index);
                },
                childCount: subCategories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // زر رجوع بتصميم دائري شفاف
  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.2),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard(BuildContext context, String name, String query, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact(); // اهتزاز خفيف للمسة احترافية
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  categoryTitle: name,
                  categoryQuery: query,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // أيقونة القسم بتصميم متدرج خفيف
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.explore_rounded, color: themeColor, size: 26),
                ),
                const SizedBox(width: 18),
                // اسم القسم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "استكشف محتوى $name",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // سهم الانتقال بتصميم بسيط
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: themeColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// تحسين الـ Extension لإضافة دالة التفتيح أيضاً إذا احتجتها
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}