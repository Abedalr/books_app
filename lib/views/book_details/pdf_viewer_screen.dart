import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../view_models/analytics_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final String? path;
  final String? title;
  final String? category;
  final String? bookId;

  const PDFViewerScreen({
    super.key,
    required this.path,
    required this.title,
    required this.category,
    required this.bookId,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late DateTime _sessionStart;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now(); // بدء حساب وقت الجلسة
  }

  // إرسال إحصائيات وقت القراءة عند الخروج
  void _sendAnalytics() {
    final seconds = DateTime.now().difference(_sessionStart).inSeconds;
    if (seconds > 5) {
      String cat = (widget.category != null && widget.category!.isNotEmpty)
          ? widget.category!
          : 'عام';
      context.read<AnalyticsProvider>().addReadingSession(seconds, cat);
    }
  }

  // دالة إنهاء الكتاب وإضافته لقائمة المكتملة
  void _handleFinish() async {
    // التأكد من وجود كافة البيانات المطلوبة لمنع خطأ الـ Null
    if (widget.bookId == null || widget.title == null || widget.path == null) return;

    final provider = context.read<AnalyticsProvider>();

    // تمرير 4 مدخلات ليتوافق مع تحديث الـ Provider الجديد
    bool success = await provider.markBookAsFinished(
        widget.bookId!,
        widget.title!,
        widget.path!,             // المسار المطلوب لفتح الكتاب من السجل لاحقاً
        widget.category ?? 'عام'  // التصنيف للإحصائيات
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 مبارك! تم إنهاء الكتاب وإضافته لمكتبتك",
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("ملاحظة",
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: const Text("هذا الكتاب مسجل مسبقاً في قائمة الكتب المكتملة.",
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("حسناً", style: TextStyle(fontFamily: 'Cairo'))
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // تحديث وقت القراءة عند الضغط على زر الرجوع
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _sendAnalytics();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? "قارئ الكتب",
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: _handleFinish,
              icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
            )
          ],
        ),
        body: _buildViewer(),
      ),
    );
  }

  // دالة عرض ملف الـ PDF بناءً على نوع المسار (Local/Network)
  Widget _buildViewer() {
    final path = widget.path;

    if (path == null || path.isEmpty) {
      return const Center(
          child: Text("عذراً، مسار الكتاب غير صالح", style: TextStyle(fontFamily: 'Cairo'))
      );
    }

    // إذا كان الرابط يبدأ بـ http نستخدم network، وإلا نستخدم file
    if (path.startsWith('http') || path.startsWith('https')) {
      return Stack(
        children: [
          const Center(child: CircularProgressIndicator()), // مؤشر تحميل خلفي
          SfPdfViewer.network(
            path,
            key: _pdfViewerKey,
          ),
        ],
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return SfPdfViewer.file(
          file,
          key: _pdfViewerKey,
        );
      } else {
        return const Center(
            child: Text("الملف غير موجود في ذاكرة الجهاز",
                style: TextStyle(fontFamily: 'Cairo'))
        );
      }
    }
  }
}