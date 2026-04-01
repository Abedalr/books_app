import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../view_models/ai_provider.dart';
import '../../view_models/book_provider.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // تمرير تلقائي للأسفل لضمان رؤية آخر الرسائل عند الفتح
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // ميثود ذكية لملاحقة الرد التدريجي (Streaming) للأسفل
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AiProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديث التمرير تلقائياً عندما يكون الذكاء الاصطناعي في حالة تحميل (يستلم الرد)
    if (aiProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    // منطق الربط بين المحادثة ومكتبة الكتب في Firebase
    final String lastQuery = _controller.text.isNotEmpty
        ? _controller.text
        : (aiProvider.history.isNotEmpty && aiProvider.history.last.role == 'user'
        ? aiProvider.history.last.parts.whereType<TextPart>().last.text
        : "");

    final matchedBooks = bookProvider.books.where((book) {
      if (lastQuery.length < 2) return false;
      return book.title.toLowerCase().contains(lastQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(lastQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context, isDark, aiProvider),
      body: Column(
        children: [
          _buildQuickActions(aiProvider, isDark),
          Expanded(
            child: aiProvider.history.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              itemCount: aiProvider.history.length,
              itemBuilder: (context, index) {
                final content = aiProvider.history[index];
                final isUser = content.role == 'user';
                // استخراج نص الرد بأمان لضمان عدم حدوث خطأ في الواجهة
                final textPart = content.parts.whereType<TextPart>().last;

                return _buildChatBubble(textPart.text, isUser, isDark);
              },
            ),
          ),

          // شريط عرض الكتب المقترحة من مكتبتك الخاصة
          if (matchedBooks.isNotEmpty)
            _buildLibraryResults(matchedBooks, isDark),

          // مؤشر التحميل أثناء انتظار رد Gemini
          if (aiProvider.isLoading)
            const LinearProgressIndicator(
                minHeight: 2,
                color: Colors.indigoAccent,
                backgroundColor: Colors.transparent),

          _buildInputSection(aiProvider, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, AiProvider provider) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.indigoAccent, size: 22),
          const SizedBox(width: 8),
          Text("مساعد بوكس الذكي",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: () => provider.clearChat(),
          tooltip: "مسح المحادثة",
        )
      ],
    );
  }

  void _handleSend(AiProvider provider) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _controller.clear();
      provider.sendMessage(text);
      Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
    }
  }

  Widget _buildChatBubble(String text, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.indigoAccent
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: isUser
            ? Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4))
            : MarkdownBody(
          data: text,
          selectable: true, // يتيح للمستخدم نسخ النصوص البرمجية أو الردود
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: isDark ? Colors.white : Colors.black87, height: 1.5, fontSize: 15),
            code: TextStyle(backgroundColor: isDark ? Colors.black54 : Colors.grey[200]),
            strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigoAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(AiProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "اسأل عن كتاب أو مؤلف...",
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _handleSend(provider),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _handleSend(provider),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.indigoAccent,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AiProvider provider, bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _actionChip("📚 اقتراح روايات", "suggest", provider, isDark),
          _actionChip("🖋️ نبذة عن كاتب", "author", provider, isDark),
          _actionChip("💡 ملخص سريع", "summary", provider, isDark),
        ],
      ),
    );
  }

  Widget _actionChip(String label, String type, AiProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        onPressed: () {
          // استخدام الميثود المخصصة في الـ Provider لنتائج أدق
          provider.askAboutBook("هذا الكتاب", type);
          _scrollToBottom();
        },
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.indigoAccent.withOpacity(0.1))
        ),
      ),
    );
  }

  Widget _buildLibraryResults(List<dynamic> books, bool isDark) {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.indigo.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text("كتب ذات صلة في مكتبتك:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    // يمكنك هنا الانتقال لصفحة تفاصيل الكتاب
                    debugPrint("Selected book: ${book.title}");
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 80, color: Colors.indigoAccent.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text("أهلاً بك في مكتبتك الذكية",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          const Text("يمكنك السؤال عن الكتب أو طلب اقتراحات مخصصة.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}