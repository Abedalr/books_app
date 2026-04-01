import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class BookService {
  // الرابط الأساسي مع إضافة فلتر اللغة العربية بشكل دائم لضمان جودة النتائج
  final String baseUrl = "https://www.googleapis.com/books/v1/volumes?q=";

  Future<List<Book>> fetchBooksByCategory(String category) async {
    // إضافة langRestrict=ar لضمان أن الكتب المجلوبة عربية
    // واستخدام maxResults=20 لزيادة عدد الكتب المجلوبة
    final String url = '$baseUrl"subject:$category"&langRestrict=ar&maxResults=20';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['items'] != null) {
          List<dynamic> items = data['items'];
          // تعديلfromJson إلى fromMap لتتطابق مع الـ Model الجديد
          return items.map((json) => Book.fromMap(json)).toList();
        } else {
          return []; // إرجاع قائمة فارغة إذا لم توجد نتائج بدلاً من تعليق التطبيق
        }
      } else {
        throw Exception('فشل في تحميل الكتب: ${response.statusCode}');
      }
    } catch (e) {
      // طباعة الخطأ في الـ Console للمساعدة في التصحيح
      print("Error in fetchBooksByCategory: $e");
      return [];
    }
  }
}