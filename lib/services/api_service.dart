import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class ApiService {
  final Dio _dio = Dio();

  // القاعدة الذهبية للفلاتر (لغة عربية، ملفات PDF، كتب فقط)
  final String _baseFilter = "AND mediatype:texts AND format:pdf AND (language:ara OR language:arabic)";

  // ==================== محرك البحث الاحترافي ====================
  Future<List<Book>> fetchFromArchive(String query, {int limit = 20}) async {
    try {
      // دمج نص البحث مع الفلاتر لضمان جودة المحتوى
      final String fullQuery = "($query) $_baseFilter";
      final String encodedQuery = Uri.encodeComponent(fullQuery);

      // الترتيب حسب الأكثر تحميلاً (Downloads) يعطي انطباعاً بالجودة
      final String url =
          "https://archive.org/advancedsearch.php?q=$encodedQuery&sort[]=downloads+desc&fl[]=identifier,title,creator,description&rows=$limit&output=json";

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List docs = data['response']['docs'] ?? [];

        // تحويل البيانات لنماذج الكتب مع تنظيف النصوص
        return docs.map((item) => Book.fromArchive(item)).toList();
      }
    } catch (e) {
      debugPrint("Archive API Error: $e");
    }
    return [];
  }

  // ==================== أقسام الموسوعة الذكية ====================

  // 1. قسم البرمجة والتقنية (باستخدام كلمات مفتاحية دقيقة)
  Future<List<Book>> fetchProgrammingBooks() async {
    const String progQuery = "(subject:programming OR subject:برمجة OR subject:computer OR subject:تقنية)";
    return await fetchFromArchive(progQuery, limit: 25);
  }

  // 2. قسم الروايات والأدب العربي
  Future<List<Book>> fetchFictionBooks() async {
    const String fictionQuery = "(subject:fiction OR subject:رواية OR subject:أدب OR subject:قصص)";
    return await fetchFromArchive(fictionQuery, limit: 25);
  }

  // 3. قسم تطوير الذات والمال (تناسب تطبيق Sanad Pay أيضاً)
  Future<List<Book>> fetchFinanceAndSelfHelp() async {
    const String financeQuery = "(subject:finance OR subject:مال OR subject:نجاح OR subject:تطوير)";
    return await fetchFromArchive(financeQuery, limit: 20);
  }

  // ==================== تفاصيل الكتاب والروابط ====================

  // جلب معلومات الكتاب التفصيلية برقم الهوية
  Future<Book?> fetchBookMetadata(String bookId) async {
    try {
      final response = await http.get(Uri.parse("https://archive.org/metadata/$bookId")).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['metadata'] != null) return Book.fromArchive(data['metadata']);
      }
    } catch (e) {
      debugPrint("Metadata Error: $e");
    }
    return null;
  }

  // جلب رابط التحميل المباشر للـ PDF (منقح من الصور والملفات الثانوية)
  Future<String?> getDownloadUrl(String bookId, CancelToken? cancelToken) async {
    try {
      final metaResponse = await _dio.get("https://archive.org/metadata/$bookId", cancelToken: cancelToken);
      if (metaResponse.statusCode == 200) {
        List files = metaResponse.data['files'] ?? [];

        // منطق ذكي: اختيار ملف PDF الأصلي والابتعاد عن النسخ المضغوطة أو الصور (bw / thumbs)
        var pdfFile = files.firstWhere(
                (f) => f['name'].toString().toLowerCase().endsWith('.pdf') &&
                !f['name'].toString().contains('_bw') &&
                !f['name'].toString().contains('_scandata'),
            orElse: () => files.firstWhere((f) => f['name'].toString().toLowerCase().endsWith('.pdf'), orElse: () => null)
        );

        if (pdfFile != null) return "https://archive.org/download/$bookId/${pdfFile['name']}";
      }
    } catch (_) {}
    return "https://archive.org/download/$bookId/$bookId.pdf"; // رابط احتياطي
  }

  // الوصول إلى Dio من الخارج لعمليات التحميل المتقدمة
  Dio get dio => _dio;
}