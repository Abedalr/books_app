import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

// تأكد من استيراد السيرفس المحدثة التي كتبناها في الرد السابق
import '../../services/google_auth_client.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final GoogleDriveService _driveService = GoogleDriveService();

  // Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'برمجة';
  File? _pdfFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// اختيار ملف PDF مع فلترة الحجم (اختياري)
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        // يمكنك إضافة شرط لحجم الملف هنا (مثلاً لا يتجاوز 20 ميجا)
        setState(() => _pdfFile = file);
      }
    } catch (e) {
      _showSnackBar("خطأ أثناء اختيار الملف: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// دالة الرفع الأساسية
  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pdfFile == null) {
      _showSnackBar("يرجى اختيار ملف PDF أولاً", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      // نمرر البيانات للسيرفس (استخدمنا النسخة المطورة من uploadBook)
      await _driveService.uploadBook(
        file: _pdfFile!,
        bookTitle: _titleController.text.trim(),
        // يمكنك تمرير الـ category و author للـ firestore من السيرفس
      );

      if (!mounted) return;

      _showSnackBar("تم إرسال الكتاب للمراجعة بنجاح!");
      Navigator.pop(context);

    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام Theme لتوحيد الألوان
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة كتاب للموسوعة", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("ملف الكتاب"),
                  _buildPdfPicker(theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle("معلومات الكتاب"),
                  _buildTextField(_titleController, "عنوان الكتاب", Icons.book_outlined),
                  _buildTextField(_authorController, "اسم المؤلف", Icons.person_outline),
                  _buildTextField(_descController, "وصف مختصر", Icons.notes_outlined, maxLines: 3),
                  _buildCategoryDropdown(theme),
                  const SizedBox(height: 40),
                  _buildSubmitButton(theme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isUploading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(strokeWidth: 3),
                SizedBox(height: 20),
                Text("جاري معالجة الرفع...", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("يرجى عدم إغلاق التطبيق", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPicker(ThemeData theme) {
    bool hasFile = _pdfFile != null;
    return InkWell(
      onTap: _isUploading ? null : _pickPDF,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: hasFile ? Colors.green.withOpacity(0.05) : theme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? Colors.green : theme.primaryColor.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
              size: 48,
              color: hasFile ? Colors.green : theme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              hasFile ? p.basename(_pdfFile!.path) : "اختر ملف الـ PDF هنا",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hasFile ? Colors.green[700] : Colors.grey[700],
                fontWeight: hasFile ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 1.5)),
        ),
        validator: (value) => value!.isEmpty ? "هذا الحقل مطلوب" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: "تصنيف الكتاب",
        prefixIcon: const Icon(Icons.category_outlined, size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
      items: ['برمجة', 'تصميم', 'روايات', 'تاريخ', 'طب', 'فلسفة'].map((String category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadBook,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text("إرسال للمراجعة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}