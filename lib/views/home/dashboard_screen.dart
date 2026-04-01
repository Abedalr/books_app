import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مهمة لعملية الخروج من التطبيق
import 'package:provider/provider.dart';
import 'package:books/views/book_details/pdf_viewer_screen.dart';
import 'package:books/views/home/downloaded_books_screen.dart';
import '../../view_models/book_provider.dart';
import '../../view_models/auth_provider.dart';
import '../auth/notifications_screen.dart';
import '../../models/book_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // نمنع الخروج المباشر عند ضغط زر الرجوع
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final NavigatorState navigator = Navigator.of(context);

        // إذا كان هناك صفحات فرعية مفتوحة داخل الـ Stack، ارجع إليها
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // إذا كنت في الصفحة الرئيسية، أظهر ديالوج لتأكيد الخروج
          final bool shouldExit = await _showExitDialog(context) ?? false;
          if (shouldExit) {
            SystemNavigator.pop(); // الخروج البرمجي من التطبيق
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
        body: Stack(
          children: [
            // المحتوى الرئيسي للتطبيق
            Consumer<BookProvider>(
              builder: (context, provider, child) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(context, isDark),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildWelcomeText(isDark),
                            const SizedBox(height: 30),
                            _buildProfessionalQuickActionCard(context, provider, isDark),
                            const SizedBox(height: 40),
                            _buildSectionHeader(
                              context,
                              title: "أحدث الإضافات",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DownloadedBooksScreen()),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLatestArrivals(context, provider, isDark),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ديالوج تأكيد الخروج لمنع الخروج المفاجئ
  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تنبيه', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل تريد إغلاق التطبيق؟', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 90,
      floating: true,
      pinned: true,
      elevation: 0,
      centerTitle: false,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          "المكتبة الذكية",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'Cairo',
            color: isDark ? Colors.white : Colors.indigo[900],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: _buildNotificationIcon(context, isDark),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                size: 26,
                color: isDark ? Colors.white : Colors.indigo[900]),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF0F0F0F) : Colors.white, width: 1.5),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWelcomeText(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        String fullDisplayName = authProvider.user?.displayName ?? "";
        String firstName = fullDisplayName.split(' ').first;
        if (firstName.isEmpty) firstName = "مبدعنا";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "طاب يومك، $firstName 👋",
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white60 : Colors.indigo[300],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "استعد لرحلة معرفية جديدة",
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.indigo[900]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfessionalQuickActionCard(BuildContext context, BookProvider provider, bool isDark) {
    final lastBook = provider.lastReadBook;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF303F9F), const Color(0xFF1A237E)]
              : [Colors.indigo[800]!, Colors.indigo[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigoAccent.withOpacity(isDark ? 0.2 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (lastBook != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      path: lastBook.localPath ?? lastBook.previewLink,
                      title: lastBook.title,
                      category: (lastBook.category != null && lastBook.category!.isNotEmpty) ? lastBook.category! : 'عام',
                      bookId: lastBook.id,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  _buildBookCover(lastBook),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("متابعة القراءة",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lastBook?.title ?? "لم تبدأ قراءة أي كتاب بعد",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildContinueButton(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(Book? lastBook) {
    return Hero(
      tag: 'last_book_cover',
      child: Container(
        width: 90,
        height: 135,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withOpacity(0.05),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(4, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: (lastBook?.thumbnail != null && lastBook!.thumbnail!.isNotEmpty)
              ? Image.network(
            lastBook.thumbnail!,
            width: 90, height: 135, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
          )
              : _buildPlaceholderIcon(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 90, height: 135,
      color: Colors.indigo[900]!.withOpacity(0.5),
      child: const Icon(Icons.menu_book_rounded, color: Colors.white24, size: 40),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    return Row(
      children: [
        const Text("إضغط هنا للاستكمال",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Cairo')),
        const SizedBox(width: 5),
        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white.withOpacity(0.7)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
        GestureDetector(
          onTap: onTap,
          child: const Text("شاهد الكل",
              style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo')),
        ),
      ],
    );
  }

  Widget _buildLatestArrivals(BuildContext context, BookProvider provider, bool isDark) {
    final books = provider.downloadedBooks;

    if (provider.isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(30.0),
        child: CircularProgressIndicator(color: Colors.indigoAccent),
      ));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: books.isEmpty
          ? _buildEmptyState(isDark)
          : SizedBox(
        key: const ValueKey("books_list"),
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _buildBookItem(context, book, isDark, provider);
          },
        ),
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book, bool isDark, BookProvider provider) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                provider.setLastReadBook(book);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    path: book.localPath ?? book.previewLink,
                    title: book.title,
                    category: (book.category != null && book.category!.isNotEmpty) ? book.category! : 'عام',
                    bookId: book.id,
                  ),
                ));
              },
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.indigo[50],
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: (book.thumbnail != null && book.thumbnail!.isNotEmpty)
                      ? Image.network(
                    book.thumbnail!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.wifi_off_rounded, color: isDark ? Colors.white10 : Colors.indigo[100], size: 40),
                    ),
                  )
                      : Center(child: Icon(Icons.book, color: isDark ? Colors.white10 : Colors.indigo[100], size: 40)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, fontFamily: 'Cairo')
          ),
          const SizedBox(height: 2),
          Text(
              book.authors.isNotEmpty ? book.authors.first : "مؤلف مجهول",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[600], fontSize: 11, fontFamily: 'Cairo')
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      key: const ValueKey("empty_state"),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.indigo.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white10 : Colors.indigo.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined, color: Colors.indigoAccent.withOpacity(0.3), size: 50),
          const SizedBox(height: 15),
          const Text("لا توجد قراءات حالية",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          Text("ابدأ بتحميل كتبك المفضلة لتظهر هنا",
              style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 11, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}