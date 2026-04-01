import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "ابحث عن كتابك المفضل",
      "desc": "الوصول إلى آلاف الكتب من مختلف التصنيفات حول العالم بنقرة واحدة.",
      "image": "assets/images/book_one.jpg"
    },
    {
      "title": "شارك رأيك مع الآخرين",
      "desc": "نظام تعليقات وتقييم يتيح لك مناقشة الكتب مع قراء شغوفين مثلك.",
      "image": "assets/images/book_tow.jpg"
    },
    {
      "title": "أنشئ مكتبتك الخاصة",
      "desc": "احفظ كتبك المفضلة ونظمها في قوائم مخصصة لتصل إليها لاحقاً.",
      "image": "assets/images/book_three.jpg"
    },
  ];

  // دالة الانتقال الذكية: تحفظ الحالة وتوجه المستخدم للـ Login
  Future<void> _navigateToLogin() async {
    // حفظ أن المستخدم تخطى مرحلة الترحيب (Onboarding)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (!mounted) return;

    // الانتقال مع تأثير Fade أنيق كما في كودك
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => const LoginScreen(),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية الديناميكية
          _buildDynamicBackground(isDark),

          PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: _onboardingData.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return OnboardingContent(
                title: _onboardingData[index]["title"]!,
                desc: _onboardingData[index]["desc"]!,
                image: _onboardingData[index]["image"]!,
                isDark: isDark,
              );
            },
          ),

          // التحكم السفلي (تخطي، نقاط التمرير، زر التالي)
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _navigateToLogin(),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text(
                    "تخطي",
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),

                Row(
                  children: List.generate(
                    _onboardingData.length,
                        (index) => _buildDot(index, primaryColor),
                  ),
                ),

                _buildNextButton(primaryColor),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDynamicBackground(bool isDark) {
    return Stack(
      children: [
        Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        ),
        Positioned(
          top: -100,
          right: -50,
          child: CircleAvatar(
            radius: 160,
            backgroundColor: Colors.indigo.withOpacity(isDark ? 0.08 : 0.04),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, Color primary) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildNextButton(Color primary) {
    bool isLastPage = _currentPage == _onboardingData.length - 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      width: isLastPage ? 120 : 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (isLastPage) {
            _navigateToLogin();
          } else {
            _controller.nextPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
          padding: EdgeInsets.zero,
        ),
        child: isLastPage
            ? const Text("ابدأ الآن", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))
            : const Icon(Icons.arrow_forward_ios_rounded, size: 20),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, desc, image;
  final bool isDark;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.desc,
    required this.image,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withOpacity(isDark ? 0.05 : 0.02),
              ),
            ),
            Hero(
              tag: image,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    image,
                    height: MediaQuery.of(context).size.height * 0.38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white70 : Colors.blueGrey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}