import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:cloud_firestore/cloud_firestore.dart';

/// [GoogleAuthClient] بتصميم محسن يضمن إغلاق الاتصال وتحرير الذاكرة
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

/// [DriveResponse] نموذج بيانات (Model) بسيط لاستقبال نتيجة الرفع
class DriveResponse {
  final String fileId;
  final String status;
  DriveResponse(this.fileId, this.status);
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// وظيفة الرفع مع معالجة احترافية للأخطاء ودعم الـ [Status]
  Future<DriveResponse?> uploadBook({
    required File file,
    required String bookTitle,
    String? category, // إضافة التصنيف لجعل الفلترة في Firestore أسهل
  }) async {
    GoogleAuthClient? authClient;

    try {
      // 1. تسجيل الدخول والتأكد من الصلاحيات
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null; // المستخدم ألغى العملية

      final authHeaders = await account.authHeaders;
      authClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authClient);

      // 2. إعداد الـ MetaData للملف على الدرايف
      final driveFile = drive.File()
        ..name = "$bookTitle.pdf"
        ..description = "Uploaded via Comprehensive Encyclopedia App"
        ..mimeType = "application/pdf";

      // 3. تنفيذ عملية الرفع (Streaming) لتقليل استهلاك الذاكرة
      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      if (response.id == null) throw Exception("فشل الحصول على الـ File ID من جوجل درايف");

      // 4. حفظ البيانات في Firestore (باستخدام وظيفة منفصلة للتنظيم)
      await _saveBookMetadata(
        fileId: response.id!,
        title: bookTitle,
        uploaderEmail: account.email,
        category: category ?? "عام",
      );

      return DriveResponse(response.id!, "success");

    } on SocketException {
      throw Exception("لا يوجد اتصال بالإنترنت، يرجى المحاولة لاحقاً");
    } catch (e) {
      // هنا يمكنك استخدام Logger بدلاً من print
      rethrow;
    } finally {
      // إغلاق الـ client دائماً لضمان عدم حدوث Memory Leak
      authClient?.close();
    }
  }

  /// وظيفة خاصة لحفظ الميتاداتا لضمان مبدأ المسؤولية الواحدة (Single Responsibility)
  Future<void> _saveBookMetadata({
    required String fileId,
    required String title,
    required String uploaderEmail,
    required String category,
  }) async {
    await _firestore.collection('books_metadata').add({
      'title': title,
      'drive_id': fileId,
      'status': 'pending',
      'category': category,
      'uploader_email': uploaderEmail,
      'created_at': FieldValue.serverTimestamp(),
      'platform': Platform.isAndroid ? 'Android' : 'iOS',
    });
  }

  Future<void> signOut() => _googleSignIn.signOut();
}