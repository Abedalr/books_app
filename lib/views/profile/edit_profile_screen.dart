import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_provider.dart';
import '../../view_models/book_provider.dart';
import 'profile_screen.dart'; // تأكد من صحة المسار حسب ترتيب المجلدات الجديد

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSaving = false; // حالة التحميل عند الضغط على زر الحفظ

  @override
  void initState() {
    super.initState();
    // جلب البيانات الحالية من الـ AuthProvider عند فتح الصفحة
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController.text = user?.displayName ?? "";
    _emailController.text = user?.email ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // دالة موحدة لتصميم الحقول (Input Decoration) لتطابق الصورة
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.indigoAccent, size: 22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.indigoAccent, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final String? localImagePath = bookProvider.profileImagePath;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // خلفية داكنة احترافية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "تعديل الملف الشخصي",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
        child: Column(
          children: [
            // --- قسم الصورة الشخصية مع إطار أزرق وزر الكاميرا ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigoAccent, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[900],
                      backgroundImage: localImagePath != null
                          ? FileImage(File(localImagePath))
                          : const NetworkImage("https://ui-avatars.com/api/?name=Abed&background=random") as ImageProvider,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => bookProvider.changeProfileImage(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.indigoAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- حقل الاسم المستعار ---
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration("الاسم المستعار", Icons.person_outline),
            ),
            const SizedBox(height: 25),

            // --- حقل البريد الإلكتروني (للقراءة فقط) ---
            TextField(
              controller: _emailController,
              enabled: false,
              style: const TextStyle(color: Colors.white38),
              decoration: _buildInputDecoration("البريد الإلكتروني", Icons.email_outlined).copyWith(
                fillColor: Colors.white.withOpacity(0.02),
              ),
            ),
            const SizedBox(height: 50),

            // --- زر حفظ التغييرات مع حالة التحميل ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                shadowColor: Colors.indigoAccent.withOpacity(0.3),
              ),
              onPressed: _isSaving ? null : () async {
                if (_nameController.text.trim().isNotEmpty) {
                  setState(() => _isSaving = true); // بدء التحميل

                  try {
                    // تحديث البيانات عبر الـ Provider
                    await authProvider.updateDisplayName(_nameController.text.trim(), context);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم تحديث ملفك الشخصي بنجاح ✨"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // الانتقال إلى صفحة البروفايل وحذف الصفحة الحالية من الـ Stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            (route) => false, // يحذف كل الصفحات السابقة ويجعل البروفايل هي الأساسية
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false); // إيقاف التحميل
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("الرجاء كتابة اسمك أولاً")),
                  );
                }
              },
              child: _isSaving
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                "حفظ التغييرات",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}