import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_models/auth_provider.dart';
import '../home/home_screen.dart';
import 'onboarding_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد وحدة التحكم في الأنميشن
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // أنميشن التلاشي (الظهور التدريجي)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // أنميشن التكبير (اللوجو) مع الـ Curve الاحترافي الذي طلبته
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut), // تم التعديل لـ easeOut
      ),
    );

    _mainController.forward();
    _navigateToNext();
  }

  // المنطق المطور للتنقل بين الصفحات
  void _navigateToNext() async {
    // ننتظر 4 ثوانٍ لعرض الهوية البصرية
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // ملاحظة: لا نغير قيمة isFirstTime هنا، نتركها لصفحة الـ Onboarding
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Widget nextScreen;

    if (isFirstTime) {
      // الحالة الأولى: تشغيل لأول مرة -> صفحة التعريف
      nextScreen = const OnboardingScreen();
    } else {
      // الحالة الثانية: ليس المرة الأولى -> نتحقق من تسجيل الدخول
      if (authProvider.user != null) {
        nextScreen = const HomeScreen();
      } else {
        nextScreen = const LoginScreen();
      }
    }

    if (!mounted) return;

    // انتقال سلس (Fade) للوجهة التالية
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. الخلفية المتدرجة
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF020617)]
                    : [const Color(0xFFF0F4FF), Colors.white],
              ),
            ),
          ),

          // 2. الدوائر الملونة المموجهة (Blur Effects)
          _buildBlurredCircle(
            top: -100,
            left: -50,
            color: isDark ? Colors.indigo.withOpacity(0.15) : Colors.indigo.withOpacity(0.05),
          ),
          _buildBlurredCircle(
            bottom: -50,
            right: -50,
            color: isDark ? Colors.blueAccent.withOpacity(0.1) : Colors.blue.withOpacity(0.03),
          ),

          // 3. المحتوى المركزي (اللوجو والنص)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: size.width * 0.65, // حجم اللوجو 65% من عرض الشاشة
                    height: size.width * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : Colors.indigo.withOpacity(0.1),
                          blurRadius: 50,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.png', // اللوجو الجديد الخاص بك
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // نصوص الهوية
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      "رف الكتـب",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontFamily: 'Cairo',
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "رفيقك المثالي في رحلة المعرفة",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.blueGrey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 4. مؤشر التحميل في الأسفل
          Positioned(
            bottom: 60,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت الدوائر المموجهة الخلفية
  Widget _buildBlurredCircle({double? top, double? bottom, double? left, double? right, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}