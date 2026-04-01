import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان خلفية العناصر (وليس الشيمر نفسه) لتعطي إيحاءً بالعمق
    final Color elementBg = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    // ألوان الشيمر الأساسية
    final Color baseColor = isDark ? const Color(0xFF242424) : Colors.grey[300]!;
    final Color highlightColor = isDark ? const Color(0xFF323232) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200), // سرعة متوسطة مريحة للعين
      child: Container(
        width: 155, // عرض مثالي لكروت الكتب
        margin: const EdgeInsets.only(left: 16, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. غلاف الكتاب مع تأثير انحناء جانبي (محاكاة كعب الكتاب)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: elementBg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topLeft: Radius.circular(6), // زاوية حادة قليلاً لمحاكاة كعب الكتاب
                    bottomLeft: Radius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. عنوان الكتاب (سطر أول طويل)
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: elementBg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),

            // 3. عنوان الكتاب (تتمة السطر الثاني - أقصر)
            Container(
              width: 90,
              height: 14,
              decoration: BoxDecoration(
                color: elementBg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),

            // 4. السطر السفلي (المؤلف + التقييم)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // اسم المؤلف
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: elementBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // أيقونة صغيرة (مثل النجمة)
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: elementBg,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}