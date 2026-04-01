import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../view_models/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // استخدام Microtask لضمان جلب البيانات فور بناء الواجهة
    Future.microtask(() =>
        context.read<AnalyticsProvider>().fetchUserStats()
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text("لوحة الإنجازات",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: textColor, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 28),
            onPressed: () {
              // مساحة لإضافة صفحة المتصدرين الكاملة أو التحديات
            },
          ),
        ],
      ),
      body: analytics.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : RefreshIndicator(
        onRefresh: () => analytics.fetchUserStats(),
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernLevelCard(analytics),
              const SizedBox(height: 25),

              Row(
                children: [
                  _buildStatTile("الكتب المكتملة", "${analytics.booksFinished}", Icons.auto_stories, Colors.blue, cardColor, textColor),
                  const SizedBox(width: 15),
                  _buildStatTile("إجمالي الوقت", "${analytics.totalHours}س ${analytics.remainingMinutes}د", Icons.timer, Colors.orange, cardColor, textColor),
                ],
              ),
              const SizedBox(height: 25),

              // قسم المتصدرين
              _buildLeaderboardPreview(analytics, cardColor, textColor, primaryColor),
              const SizedBox(height: 25),

              _buildChartBox(
                  "نشاطك الأسبوعي",
                  analytics.weeklyHoursData.every((val) => val == 0)
                      ? const Center(child: Text("ابدأ القراءة لتظهر إحصائياتك", style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)))
                      : LineChart(_lineChartData(analytics.weeklyHoursData)),
                  cardColor,
                  textColor,
                  height: 180),
              const SizedBox(height: 25),

              _buildChartBox(
                  "توزيع الاهتمامات",
                  analytics.categoryStats.isEmpty
                      ? const Center(child: Text("لا توجد بيانات كافية", style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)))
                      : PieChart(_pieChartData(analytics.categoryStats)),
                  cardColor,
                  textColor,
                  height: 240),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- دالة بناء قائمة المتصدرين (معالجة حالة القائمة الفارغة بشكل أفضل) ---
  Widget _buildLeaderboardPreview(AnalyticsProvider analytics, Color cardColor, Color textColor, Color primary) {
    final topReaders = analytics.leaderboard;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("أكثر القراء نشاطاً", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo', color: textColor)),
              const Icon(Icons.trending_up_rounded, color: Colors.green, size: 22),
            ],
          ),
          const SizedBox(height: 15),
          if (topReaders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("كن أول المتصدرين الآن!", style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topReaders.length,
              separatorBuilder: (context, index) => Divider(height: 20, color: textColor.withOpacity(0.05)),
              itemBuilder: (context, index) {
                final reader = topReaders[index];
                // تلوين المراكز الثلاثة الأولى
                Color rankColor = index == 0 ? Colors.amber : (index == 1 ? Colors.grey : (index == 2 ? Colors.brown : primary));

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: rankColor.withOpacity(0.1),
                      child: Text("${index + 1}", style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(reader['displayName'] ?? "مستخدم",
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: textColor, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("${reader['booksFinished']} كتب",
                          style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // --- مربعات الإحصائيات الرفيعة ---
  Widget _buildStatTile(String title, String value, IconData icon, Color accentColor, Color cardColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo', fontWeight: FontWeight.w500))
        ]),
      ),
    );
  }

  // --- حاوية الرسوم البيانية المتناسقة ---
  Widget _buildChartBox(String title, Widget chart, Color cardColor, Color textColor, {double height = 200}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo', color: textColor)),
        const SizedBox(height: 25),
        SizedBox(height: height, child: chart),
      ]),
    );
  }

  // --- كارت المستوى (برستيج المستخدم) ---
  Widget _buildModernLevelCard(AnalyticsProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("المستوى ${provider.currentLevel}", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(provider.userRank, style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 13)),
          ]),
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 45),
        ]),
        const SizedBox(height: 25),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: provider.nextLevelProgress,
            backgroundColor: Colors.white12,
            color: Colors.amber,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${provider.totalXP} XP", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const Text("المستوى التالي", style: TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'Cairo')),
          ],
        ),
      ]),
    );
  }

  // الرسوم البيانية (Line & Pie) بقيت كما هي مع تحسين بسيط في المظهر
  LineChartData _lineChartData(List<double> data) {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          isCurved: true,
          color: const Color(0xFF6366F1),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(colors: [const Color(0xFF6366F1).withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        )
      ],
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
    );
  }

  PieChartData _pieChartData(Map<String, double> stats) {
    return PieChartData(
      sectionsSpace: 4,
      centerSpaceRadius: 50,
      sections: stats.entries.map((e) {
        final index = stats.keys.toList().indexOf(e.key);
        return PieChartSectionData(
          value: e.value,
          title: '${e.value.toInt()}%',
          color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.8),
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        );
      }).toList(),
    );
  }
}