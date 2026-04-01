import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthorFullDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> author;

  const AuthorFullDetailsScreen({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFBFBFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. هيدر احترافي متفاعل
          _buildSliverAppBar(context, isDark, primaryColor),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. كروت المعلومات السريعة (ميلاد/وفاة)
                  Row(
                    children: [
                      _buildModernInfoCard(
                          Icons.cake_rounded,
                          "الميلاد",
                          author['birth']?.toString() ?? 'غير متوفر',
                          Colors.blue, isDark
                      ),
                      const SizedBox(width: 15),
                      _buildModernInfoCard(
                          Icons.event_available_rounded,
                          "الوفاة",
                          author['death']?.toString() ?? 'على قيد الحياة',
                          Colors.redAccent, isDark
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // 3. قسم السيرة التاريخية
                  _buildSectionHeader(Icons.history_edu_rounded, "المسيرة التاريخية", primaryColor),
                  _buildGlassContentBox(author['detailedHistory'] ?? author['fullBio'] ?? "لا توجد تفاصيل تاريخية متوفرة حالياً.", isDark),

                  const SizedBox(height: 30),

                  // 4. قسم أبرز الأعمال (المعدل ليدعم القوائم والنصوص)
                  _buildSectionHeader(Icons.auto_stories_rounded, "أبرز الأعمال والمؤلفات", primaryColor),
                  _buildWorksChips(author['topWorks'], isDark, primaryColor),

                  const SizedBox(height: 30),

                  // 5. قسم الإنجازات
                  _buildSectionHeader(Icons.emoji_events_rounded, "الإنجازات والجوائز", Colors.amber.shade700),
                  _buildPremiumAchievementBox(author['achievements']?.toString() ?? 'لا توجد جوائز مسجلة لهذا المؤلف حتى الآن.', isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, Color primary) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          author['name'] ?? "تفاصيل المؤلف",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Cairo', color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withBlue(150)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            const Positioned(
              left: -20, bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.person_outline_rounded, size: 200, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة ذكية لمعالجة عرض الأعمال سواء كانت قائمة أو نصاً
  Widget _buildWorksChips(dynamic worksData, bool isDark, Color primary) {
    List<String> worksList = [];

    if (worksData != null) {
      if (worksData is List) {
        worksList = worksData.map((e) => e.toString()).toList();
      } else if (worksData is String) {
        worksList = worksData.split('،').where((s) => s.trim().isNotEmpty).toList();
      }
    }

    if (worksList.isEmpty) {
      return Text("لا توجد أعمال مسجلة.", style: TextStyle(color: isDark ? Colors.white30 : Colors.grey));
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: worksList.map((work) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.1)),
        ),
        child: Text(
          work.trim(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary, fontFamily: 'Cairo'),
        ),
      )).toList(),
    );
  }

  // --- بقية الويدجت مع إضافة حماية Null Safety ---

  Widget _buildModernInfoCard(IconData icon, String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500], fontFamily: 'Cairo')),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContentBox(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15,
            height: 1.8,
            color: isDark ? Colors.white70 : Colors.black87,
            fontFamily: 'Cairo'
        ),
      ),
    );
  }

  Widget _buildPremiumAchievementBox(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2311), const Color(0xFF1A1A1A)]
              : [const Color(0xFFFFF8E1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.amber.shade200 : Colors.brown.shade700,
                  fontFamily: 'Cairo'
              ),
            ),
          ),
        ],
      ),
    );
  }
}