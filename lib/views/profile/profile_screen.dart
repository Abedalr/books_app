import 'dart:io';
import 'package:books/views/profile/upload_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// استيراد الـ Providers
import '../../view_models/book_provider.dart';
import '../../view_models/settings_provider.dart';
import '../../view_models/analytics_provider.dart';
import '../../view_models/auth_provider.dart';

// استيراد الشاشات
import '../home/favorites_screen.dart';
import '../home/downloaded_books_screen.dart';
import '../book_details/user_comments_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../library/liked_books_screen.dart';
import '../auth/login_screen.dart';
import '../profile/analytics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<SettingsProvider>().isDarkMode;
    // نستخدم watch هنا لنسمع أي تغيير في بيانات المستخدم (مثل الصورة والاسم)
    final authProvider = context.watch<AuthProvider>();

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer3<BookProvider, SettingsProvider, AnalyticsProvider>(
        builder: (context, bookProvider, settingsProvider, analyticsProvider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // الهيدر مع "خداع الـ Cache" لضمان ظهور الصورة الجديدة فوراً
              _buildSliverHeader(
                  context,
                  bookProvider,
                  analyticsProvider.userRank,
                  isDark,
                  authProvider.user?.displayName ?? "مستخدم جديد",
                  authProvider.user?.photoURL
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildStatsRow(context, bookProvider, isDark),
                      const SizedBox(height: 30),

                      _buildSectionTitle("إدارة الحساب", isDark),
                      _buildMenuCard(context, [
                        _buildMenuAction(
                          context,
                          title: "تعديل الملف الشخصي",
                          icon: Icons.person_outline_rounded,
                          color: Colors.blue,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        ),
                        _buildMenuAction(
                          context,
                          title: "رفع كتاب جديد",
                          icon: Icons.cloud_upload_outlined,
                          color: Colors.orange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadBookScreen())),
                        ),
                        _buildMenuAction(
                          context,
                          title: "الكتب المحملة",
                          icon: Icons.download_done_rounded,
                          color: Colors.green,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadedBooksScreen())),
                        ),
                        _buildMenuAction(
                          context,
                          title: "إحصائيات القراءة الذكية",
                          icon: Icons.analytics_rounded,
                          color: Colors.indigo,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                        ),
                      ], cardColor, isDark),

                      const SizedBox(height: 25),

                      _buildSectionTitle("التفضيلات والظهور", isDark),
                      _buildMenuCard(context, [
                        _buildThemeToggle(settingsProvider, isDark),
                        _buildMenuAction(
                          context,
                          title: "مكتبتي المفضلة",
                          icon: Icons.bookmark_border_rounded,
                          color: Colors.pink,
                          trailing: "${bookProvider.totalFavorites}",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                        ),
                        _buildMenuAction(
                          context,
                          title: "كتب أعجبتني",
                          icon: Icons.thumb_up_off_alt_rounded,
                          color: Colors.orange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LikedBooksScreen())),
                        ),
                      ], cardColor, isDark),

                      const SizedBox(height: 40),

                      _buildLogoutButton(context, isDark),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, BookProvider provider, String userRank, bool isDark, String userName, String? photoUrl) {
    // كسر الكاش بإضافة Timestamp للرابط
    final String? finalImageUrl = (photoUrl != null && photoUrl.isNotEmpty)
        ? "$photoUrl${photoUrl.contains('?') ? '&' : '?' }v=${DateTime.now().millisecondsSinceEpoch}"
        : null;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.indigo[900],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo[900]!, Colors.indigo[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () async {
                  await provider.changeProfileImage();
                  if (context.mounted) {
                    await context.read<AuthProvider>().reloadUser();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: finalImageUrl != null
                          ? CachedNetworkImage(
                        // السر هنا: استخدام التوقيت الحالي كـ Key يجبر Flutter على تحديث الصورة فوراً
                        key: ValueKey(DateTime.now().millisecondsSinceEpoch.toString()),
                        imageUrl: finalImageUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo),
                        ),
                        errorWidget: (context, url, error) => _buildAvatarPlaceholder(userName),
                      )
                          : _buildAvatarPlaceholder(userName),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                userName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo'
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      userRank,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo'
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Image.network(
      "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&size=128",
      fit: BoxFit.cover,
      width: 110,
      height: 110,
    );
  }

  Widget _buildStatsRow(BuildContext context, BookProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("المفضلة", "${provider.totalFavorites}", Colors.pink, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
          }),
          _buildVerticalDivider(isDark),
          _buildStatItem("التعليقات", "${provider.totalComments}", Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserCommentsScreen()));
          }),
          _buildVerticalDivider(isDark),
          _buildStatItem("إعجابات", "${provider.likedBooksFromFirebase.length}", Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LikedBooksScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) => Container(height: 30, width: 1, color: isDark ? Colors.white10 : Colors.grey[200]);

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500], fontFamily: 'Cairo')),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> items, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey[100]!),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuAction(BuildContext context, {required String title, required IconData icon, required Color color, String? trailing, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
      trailing: trailing != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Text(trailing, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo, fontFamily: 'Cairo')),
      )
          : Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
    );
  }

  Widget _buildThemeToggle(SettingsProvider settings, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.purple, size: 22),
      ),
      title: const Text("الوضع الليلي", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
      trailing: Switch.adaptive(
        value: settings.isDarkMode,
        activeColor: Colors.purple,
        onChanged: (v) => settings.toggleTheme(v),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => _showLogoutConfirmation(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 10),
            Text("تسجيل الخروج", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تسجيل الخروج", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(color: Colors.grey[600], fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text("خروج", style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}