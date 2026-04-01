import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // لاستخدامه في التحقق من الحقل

  @override
  void dispose() {
    _emailController.dispose();
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
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.indigo[900]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- أيقونة احترافية مع أنيميشن بسيط (اختياري) ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ]
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, size: 70, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 40),

              // --- العناوين ---
              Text(
                "هل نسيت كلمة المرور؟",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "لا تقلق، أدخل بريدك الإلكتروني وسنتحقق من وجود حسابك لإرسال رابط الاستعادة.",
                style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.6),
              ),
              const SizedBox(height: 40),

              // --- حقل البريد الإلكتروني المطور ---
              _buildEmailField(isDark),
              const SizedBox(height: 40),

              // --- زر الإرسال الذكي ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 58),
                  backgroundColor: Colors.indigo[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: Colors.indigo.withOpacity(0.3),
                ),
                onPressed: authProvider.isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    // استدعاء الدالة الجديدة التي تعيد String?
                    String? result = await authProvider.resetPassword(_emailController.text.trim());

                    if (context.mounted) {
                      if (result == null) {
                        // حالة النجاح: الإيميل موجود وتم الإرسال
                        _showSuccessDialog(context);
                      } else {
                        // حالة الفشل: الإيميل غير مسجل أو خطأ فني
                        _showErrorSnackBar(context, result);
                      }
                    }
                  }
                },
                child: authProvider.isLoading
                    ? const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  "التحقق والإرسال",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ميثود بناء حقل الإيميل مع Validation
  Widget _buildEmailField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontWeight: FontWeight.w600),
        validator: (value) {
          if (value == null || value.isEmpty) return "يرجى إدخال البريد الإلكتروني";
          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return "يرجى إدخال بريد صحيح";
          return null;
        },
        decoration: InputDecoration(
          labelText: "البريد الإلكتروني",
          hintText: "example@mail.com",
          prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.indigo[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  // ميثود إظهار الخطأ بشكل احترافي
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  // ميثود رسالة النجاح
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Icon(Icons.mark_email_unread_rounded, color: Colors.green, size: 70),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "تم إرسال الرابط!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text(
              "وجدنا حسابك بنجاح! تم إرسال تعليمات تغيير كلمة المرور إلى بريدك الإلكتروني.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("حسناً، سأتحقق الآن", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}