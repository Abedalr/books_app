import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.indigo[900]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // --- العنوان والترحيب ---
            Text(
              "إنشاء حساب جديد",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.indigo[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "انضم إلينا واستمتع بقراءة أفضل الكتب العربية",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // --- حقل الاسم المستعار ---
            _buildTextField(
              controller: _nameController,
              label: "الاسم المستعار",
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // --- حقل البريد الإلكتروني ---
            _buildTextField(
              controller: _emailController,
              label: "البريد الإلكتروني",
              icon: Icons.email_outlined,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // --- حقل كلمة المرور ---
            _buildTextField(
              controller: _passwordController,
              label: "كلمة المرور",
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              isPassword: true,
              isVisible: _isPasswordVisible,
              onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            const SizedBox(height: 20),

            // --- حقل تأكيد كلمة المرور ---
            _buildTextField(
              controller: _confirmPasswordController,
              label: "تأكيد كلمة المرور",
              icon: Icons.lock_reset_rounded,
              isDark: isDark,
              isPassword: true,
              isVisible: _isPasswordVisible,
              onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            const SizedBox(height: 40),

            // --- زر إنشاء الحساب ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                backgroundColor: Colors.indigo[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 5,
                shadowColor: Colors.indigo.withOpacity(0.4),
              ),
              onPressed: authProvider.isLoading ? null : () async {
                if (_validateForm()) {
                  String? error = await authProvider.signUp(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _nameController.text.trim(), // تم إضافة الاسم هنا كما في البروفايدر الجديد
                  );

                  if (error == null) {
                    // تحديث الاسم فوراً في فايربيز بعد النجاح
                    await authProvider.updateDisplayName(_nameController.text.trim(), context);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم إنشاء الحساب بنجاح!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  }
                }
              },
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "إنشاء الحساب",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // --- العودة لتسجيل الدخول ---
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    children: [
                      const TextSpan(text: "لديك حساب بالفعل؟ "),
                      TextSpan(
                        text: "سجل دخولك",
                        style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ميثود مساعدة لبناء الحقول بشكل احترافي
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
          prefixIcon: Icon(icon, color: Colors.indigo[400]),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: onVisibilityToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  // التحقق البسيط من الحقول
  bool _validateForm() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى ملء جميع الحقول")));
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كلمات المرور غير متطابقة")));
      return false;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يجب أن تكون كلمة المرور 6 أحرف على الأقل")));
      return false;
    }
    return true;
  }
}