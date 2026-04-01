import 'package:books/views/auth/signup_screen.dart';
import 'package:books/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. استيراد المكتبة
import '../../view_models/auth_provider.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة ذكية لحفظ حالة الدخول والانتقال
  Future<void> _handleLoginSuccess() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // حفظ حالة الدخول لكي لا يطلبها التطبيق مرة أخرى
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isFirstTime', false); // نؤكد أنه ليس مستخدماً جديداً

    if (!mounted) return;

    // الانتقال للشاشة الرئيسية وتصفير الـ Stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // --- الشعار (Logo) ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded, size: 80, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                "مرحباً بك مجدداً",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white : Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "سجل دخولك لتكمل رحلتك في عالم القراءة",
                style: TextStyle(fontSize: 16, fontFamily: 'Cairo', color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // --- البريد الإلكتروني ---
              _buildTextField(
                controller: _emailController,
                label: "البريد الإلكتروني",
                icon: Icons.email_outlined,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // --- كلمة المرور ---
              _buildTextField(
                controller: _passwordController,
                label: "كلمة المرور",
                icon: Icons.lock_outline_rounded,
                isDark: isDark,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    "نسيت كلمة المرور؟",
                    style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- زر تسجيل الدخول المحدث ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 58),
                  backgroundColor: Colors.indigo[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 5,
                ),
                onPressed: authProvider.isLoading ? null : () async {
                  // محاولة تسجيل الدخول عبر البروفايدر
                  String? result = await authProvider.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );

                  if (result == null) {
                    // إذا نجح الدخول (result == null تعني لا يوجد خطأ)
                    await _handleLoginSuccess();
                  } else {
                    // إذا فشل، نعرض رسالة الخطأ
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result, style: const TextStyle(fontFamily: 'Cairo')),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "تسجيل الدخول",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                ),
              ),
              const SizedBox(height: 25),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[600], fontSize: 15, fontFamily: 'Cairo'),
                      children: [
                        const TextSpan(text: "ليس لديك حساب؟ "),
                        TextSpan(
                          text: "سجل الآن",
                          style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.indigo[400]),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: onVisibilityToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}