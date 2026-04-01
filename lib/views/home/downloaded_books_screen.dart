import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/book_model.dart';
import '../../view_models/book_provider.dart';
import '../book_details/pdf_viewer_screen.dart';

class DownloadedBooksScreen extends StatefulWidget {
  const DownloadedBooksScreen({super.key});

  @override
  State<DownloadedBooksScreen> createState() => _DownloadedBooksScreenState();
}

class _DownloadedBooksScreenState extends State<DownloadedBooksScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false, // نتحكم في عملية الرجوع يدوياً
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. إذا كان هناك نص في البحث، قم بتنظيفه أولاً
        if (_searchQuery.isNotEmpty) {
          setState(() {
            _searchQuery = "";
            _searchController.clear();
          });
          return;
        }

        // 2. الرجوع الطبيعي للصفحة السابقة (الـ Dashboard)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
        body: Consumer<BookProvider>(
          builder: (context, provider, child) {
            // فلترة الكتب بناءً على البحث (عنوان أو مؤلف)
            final books = provider.downloadedBooks.reversed.where((book) {
              final matchesTitle = book.title.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchesAuthor = book.authors.isNotEmpty &&
                  book.authors.first.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesTitle || matchesAuthor;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildProfessionalAppBar(context, isDark, primaryColor),

                if (books.isEmpty && _searchQuery.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, isDark, primaryColor),
                  )
                else if (books.isEmpty && _searchQuery.isNotEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildNoResultsState(isDark),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildDismissibleCard(context, books[index], provider, isDark, primaryColor),
                        childCount: books.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfessionalAppBar(BuildContext context, bool isDark, Color primary) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        centerTitle: true,
        title: const Text(
          "المكتبة المحملة",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Cairo', color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withBlue(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const Positioned(
              left: -30, top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.cloud_done_rounded, size: 180, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 55,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Cairo'),
                      decoration: const InputDecoration(
                        hintText: "ابحث في كتبك المحملة...",
                        hintStyle: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo'),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, Book book, BookProvider provider, bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('download_${book.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _showDeleteConfirmDialog(context, book, provider),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("حذف الملف", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              SizedBox(width: 10),
              Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
            ],
          ),
        ),
        child: _buildModernBookCard(context, book, provider, isDark, primary),
      ),
    );
  }

  Widget _buildModernBookCard(BuildContext context, Book book, BookProvider provider, bool isDark, Color primary) {
    String formattedDate = book.downloadDate != null
        ? DateFormat('yyyy/MM/dd').format(book.downloadDate!)
        : "تاريخ غير معروف";

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleBookOpen(context, book, provider),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildCoverImage(book),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Cairo'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authors.isNotEmpty ? book.authors.first : "مؤلف مجهول",
                        style: TextStyle(
                          color: isDark ? Colors.white30 : Colors.grey[500],
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMiniBadge(Icons.event_note_rounded, formattedDate, Colors.blue, isDark),
                          const SizedBox(width: 8),
                          _buildMiniBadge(Icons.offline_pin_rounded, "أوفلاين", Colors.green, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                  onPressed: () => _showDeleteConfirmDialog(context, book, provider),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(Book book) {
    return Hero(
      tag: 'downloaded_${book.id}',
      child: Container(
        width: 75,
        height: 105,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(2, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            imageUrl: book.thumbnail ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.indigo.withOpacity(0.1),
              child: const Icon(Icons.book, color: Colors.indigo),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  void _handleBookOpen(BuildContext context, Book book, BookProvider provider) async {
    final path = book.localPath;
    if (path != null && await File(path).exists()) {
      HapticFeedback.mediumImpact();
      provider.setLastReadBook(book);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PDFViewerScreen(
              path: path,
              title: book.title,
              category: (book.category != null && book.category!.isNotEmpty) ? book.category! : 'عام',
              bookId: book.id,
            ),
          ),
        );
      }
    } else {
      _showCustomSnackBar(context, "عذراً، الملف غير موجود في ذاكرة الجهاز", isError: true);
    }
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: isDark ? Colors.white10 : Colors.grey[200]),
          const SizedBox(height: 20),
          const Text("لا توجد نتائج مطابقة لبحثك", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: primary.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.download_for_offline_rounded, size: 80, color: primary.withOpacity(0.2)),
          ),
          const SizedBox(height: 25),
          const Text("مكتبتك الأوفلاين فارغة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
          const SizedBox(height: 10),
          const Text("حمل كتبك المفضلة لتقرأها في أي وقت وأي مكان", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo')),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // العودة للرئيسية للاستكشاف
            },
            icon: const Icon(Icons.explore_outlined, color: Colors.white),
            label: const Text("استكشف واكتشف الكتب", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(BuildContext context, Book book, BookProvider provider) async {
    HapticFeedback.heavyImpact();
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 15),
            const Text("حذف الكتاب نهائياً؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
            const SizedBox(height: 10),
            Text("سيتم حذف ملف '${book.title}' من ذاكرة هاتفك. هل أنت متأكد؟", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text("تراجع", style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      provider.deleteDownloadedBook(book);
                      Navigator.pop(context, true);
                      _showCustomSnackBar(context, "تم حذف الكتاب '${book.title}' بنجاح");
                    },
                    child: const Text("حذف الآن", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ) ??
        false;
  }

  void _showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}