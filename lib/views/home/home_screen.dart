import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import '../../view_models/auth_provider.dart';
import '../../services/notification_service.dart';

import 'dashboard_screen.dart';
import 'main_books_view.dart';
import '../auth/authors_screen.dart';
import 'favorites_screen.dart';
import 'downloaded_books_screen.dart';
import '../profile/profile_screen.dart' hide FavoritesScreen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
  List.generate(6, (index) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        NotificationService.listenToNotifications(authProvider.user!.uid);
        debugPrint("🔔 نظام الإشعارات نشط للمستخدم: ${authProvider.user!.uid}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // تأكدنا أن الخلفية نظيفة تماماً
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],

      // الـ body الآن لا يحتوي إلا على الصفحات وشريط التحميل (بدون شريط الأوفلاين الأحمر)
      body: Stack(
        children: [
          // 1. عرض الصفحات الأساسية
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildTabNavigator(0, const DashboardScreen()),
              _buildTabNavigator(1, const MainBooksView()),
              _buildTabNavigator(2, const AuthorsScreen()),
              _buildTabNavigator(3, const FavoritesScreen()),
              _buildTabNavigator(4, const DownloadedBooksScreen()),
              _buildTabNavigator(5, const ProfileScreen()),
            ],
          ),

          // 2. شريط التحميل العائم (يظهر فقط عند وجود تحميلات)
          _buildGlobalDownloadOverlay(isDark),

          // ملاحظة: تم حذف أي ويدجت يخص OfflineBanner من هنا نهائياً
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          indicatorColor: Colors.indigoAccent.withOpacity(0.15),
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (int index) =>
              setState(() => _selectedIndex = index),
          destinations: [
            _buildDestination(Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
            _buildDestination(Icons.book_outlined, Icons.book_rounded, 'الكتب'),
            _buildDestination(Icons.group_outlined, Icons.group_rounded, 'المؤلفون'),
            _buildDestination(Icons.favorite_outline, Icons.favorite_rounded, 'المفضلة'),
            _buildDestination(Icons.cloud_download_outlined, Icons.cloud_download_rounded, 'محملة'),
            _buildDestination(Icons.person_outline, Icons.person_rounded, 'حسابي'),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(
      IconData icon, IconData selectedIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, size: 24),
      selectedIcon: Icon(selectedIcon, color: Colors.indigoAccent, size: 26),
      label: label,
    );
  }

  // شريط التحميل الاحترافي (Overlay)
  Widget _buildGlobalDownloadOverlay(bool isDark) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        if (provider.downloadingBooksProgress.isEmpty) {
          return const SizedBox.shrink();
        }

        double totalProgress = provider.downloadingBooksProgress.values
            .map((e) => (e['progress'] as double))
            .fold(0.0, (a, b) => a + b) /
            provider.downloadingBooksProgress.length;

        return Positioned(
          bottom: 90,
          left: 15,
          right: 15,
          child: GestureDetector(
            onTap: () => _showDownloadDetails(context, provider),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.indigo[900],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      value: totalProgress,
                      strokeWidth: 3,
                      color: Colors.indigoAccent,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "جاري حفظ الكتب في مكتبتك...",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Cairo'),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDownloadDetails(BuildContext context, BookProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("قائمة التحميلات الحالية",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
            ),
            Expanded(
              child: provider.downloadingBooksProgress.isEmpty
                  ? const Center(child: Text("لا توجد تحميلات نشطة", style: TextStyle(fontFamily: 'Cairo')))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: provider.downloadingBooksProgress.length,
                itemBuilder: (context, index) {
                  final id = provider.downloadingBooksProgress.keys.elementAt(index);
                  final data = provider.downloadingBooksProgress[id];
                  final bool isPaused = provider.pausedBooks.contains(id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPaused ? Icons.pause_rounded : Icons.cloud_download_rounded,
                            color: Colors.indigoAccent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data?['title'] ?? "تحميل...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo'),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: data?['progress'],
                                  minHeight: 6,
                                  color: isPaused ? Colors.orange : Colors.indigoAccent,
                                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                color: isPaused ? Colors.green : Colors.orange,
                              ),
                              onPressed: () => provider.togglePauseDownload(id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                              onPressed: () => provider.cancelDownload(id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => rootPage));
  }
}