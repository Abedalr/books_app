import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiProvider with ChangeNotifier {
  // مفتاح الـ API الخاص بك
  final String _apiKey = "AIzaSyBtqqR2WJ5DdGtm52pbqeAB38kZm0BzTfU";

  late GenerativeModel _model;
  ChatSession? _chat;

  // قائمة الرسائل لعرضها في الواجهة
  List<Content> history = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AiProvider() {
    _initModel();
  }

  void _initModel() {
    // تعريف الموديل بدون 'models/' وبدون 'apiVersion' لتجنب الأخطاء الحمراء
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      ],
    );

    // بدء جلسة فارغة في البداية
    _chat = _model.startChat();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    // 1. إضافة رسالة المستخدم للقائمة
    final userContent = Content.text(message);
    history.add(userContent);

    // 2. إضافة مكان رد الذكاء الاصطناعي مع نص مؤقت
    history.add(Content.model([TextPart("...جارِ التفكير")]));
    int aiResponseIndex = history.length - 1;
    notifyListeners();

    try {
      // إرسال الرسالة عبر الـ Stream
      final responseStream = _chat!.sendMessageStream(userContent);

      String fullResponse = "";
      bool isFirstChunk = true;

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          if (isFirstChunk) {
            fullResponse = ""; // مسح نص "...جارِ التفكير" عند وصول أول رد حقيقي
            isFirstChunk = false;
          }
          fullResponse += chunk.text!;

          // تحديث الواجهة فوراً
          history[aiResponseIndex] = Content.model([TextPart(fullResponse)]);
          notifyListeners();
        }
      }

    } catch (e) {
      debugPrint("Detailed AI Error: $e");
      _handleError(e, aiResponseIndex);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleError(Object e, int index) {
    String errorText = e.toString().toLowerCase();
    String errorMessage = "عذراً، حدث خطأ في الاتصال.";

    if (errorText.contains("location") || errorText.contains("403")) {
      errorMessage = "الخدمة غير متوفرة في منطقتك. تأكد من تشغيل Cloudflare Warp.";
    } else if (errorText.contains("api_key") || errorText.contains("invalid")) {
      errorMessage = "خطأ في مفتاح الـ API. يرجى التحقق من المفتاح في AI Studio.";
    } else if (errorText.contains("safety")) {
      errorMessage = "عذراً، تم حجب الرد بسبب سياسات المحتوى.";
    }

    history[index] = Content.model([TextPart(errorMessage)]);
    notifyListeners();
  }

  // دوال المساعد الذكي الخاصة بتطبيق الكتب
  void askAboutBook(String bookName, String type) {
    String prompt = "";
    switch (type) {
      case "summary":
        prompt = "أعطني ملخصاً سريعاً وشيقاً لكتاب $bookName.";
        break;
      case "author":
        prompt = "من هو مؤلف كتاب $bookName؟ وما هي أهم أعماله الأخرى؟";
        break;
      case "suggest":
        prompt = "اقترح لي 3 كتب مشابهة في الأسلوب لكتاب $bookName.";
        break;
      default:
        prompt = "أريد معلومات وافية عن كتاب $bookName";
    }
    sendMessage(prompt);
  }

  void clearChat() {
    history.clear();
    _initModel(); // إعادة تهيئة الموديل والجلسة من جديد
    notifyListeners();
  }
}