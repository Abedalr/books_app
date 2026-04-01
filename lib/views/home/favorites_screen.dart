import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../view_models/book_provider.dart';
import '../../../models/book_model.dart';
import '../book_details/pdf_viewer_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          // 1. تصفية القائمة الأساسية
          final allFavs = provider.favoriteBooks.reversed.toList();

          if (allFavs.isEmpty) return _buildEmptyState(isDark, primaryColor);

          // 2. تقسيم القوائم بناءً على الحالة (محملة أو أونلاين)
          final downloadedFavs = allFavs.where((b) => b.localPath != null).toList();
          final onlineFavs = allFavs.where((b) => b.localPath == null).toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildProfessionalAppBar(isDark, primaryColor, allFavs.length),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // التبويب الأول: الكل (مقسم لأقسام)
                _buildCombinedList(context, downloadedFavs, onlineFavs, provider, isDark, primaryColor),

                // التبويب الثاني: المحملة فقط
                _buildBooksList(context, downloadedFavs, provider, isDark, primaryColor),

                // التبويب الثالث: أونلاين فقط
                _buildBooksList(context, onlineFavs, provider, isDark, primaryColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalAppBar(bool isDark, Color primary, int count) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : primary,
      centerTitle: true,
      title: const Text(
        "مكتبتي المفضلة",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cairo',
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withBlue(150)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const Positioned(
              right: -20, top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.bookmark_outline_outlined, size: 150, color: Colors.white),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 35),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "إجمالي الكتب: $count",
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Cairo', fontSize: 13),
        tabs: const [
          Tab(text: "الكل"),
          Tab(text: "المحملة"),
          Tab(text: "أونلاين"),
        ],
      ),
    );
  }

  Widget _buildCombinedList(BuildContext context, List<Book> downloaded, List<Book> online, BookProvider provider, bool isDark, Color primary) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        if (downloaded.isNotEmpty) ...[
          _buildSectionHeader("المكتبة المحلية", Icons.download_done_rounded, Colors.green, isDark),
          ...downloaded.map((book) => _buildEnhancedBookItem(context, book, provider, isDark, primary)),
          const SizedBox(height: 25),
        ],
        if (online.isNotEmpty) ...[
          _buildSectionHeader("بانتظار التحميل", Icons.cloud_queue_rounded, Colors.orange, isDark),
          ...online.map((book) => _buildEnhancedBookItem(context, book, provider, isDark, primary)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              fontFamily: 'Cairo',
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildBooksList(BuildContext context, List<Book> books, BookProvider provider, bool isDark, Color primary) {
    if (books.isEmpty) {
      return Center(
        child: Text(
          "لا توجد كتب هنا حالياً",
          style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontFamily: 'Cairo'),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) => _buildEnhancedBookItem(context, books[index], provider, isDark, primary),
    );
  }

  Widget _buildEnhancedBookItem(BuildContext context, Book book, BookProvider provider, bool isDark, Color primary) {
    bool isDownloaded = book.localPath != null;

    // جلب حالة التحميل من الـ Provider
    var downloadData = provider.downloadingBooksProgress[book.id];
    double? downloadProgress = downloadData != null ? downloadData['progress'] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openBook(context, book, provider),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildHeroCover(book),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.authors.isNotEmpty ? book.authors.first : "مؤلف مجهول",
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      if (downloadProgress != null)
                        _buildDownloadProgressIndicator(downloadProgress, primary)
                      else
                        _buildStatusTag(isDownloaded, primary),
                    ],
                  ),
                ),
                _buildActionButtons(context, provider, book, isDownloaded, downloadProgress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCover(Book book) {
    return Hero(
      tag: 'fav_${book.id}',
      child: Container(
        width: 65,
        height: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            book.thumbnail ?? "",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadProgressIndicator(double progress, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: primary.withOpacity(0.1), color: primary),
        ),
        const SizedBox(height: 5),
        Text("${(progress * 100).toInt()}% جاري التحميل...", style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusTag(bool isDownloaded, Color primary) {
    final color = isDownloaded ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDownloaded ? Icons.offline_pin_rounded : Icons.cloud_off_rounded, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            isDownloaded ? "جاهز للأوفلاين" : "قراءة أونلاين",
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BookProvider provider, Book book, bool isDownloaded, double? progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // زر التحميل يظهر فقط إذا لم يكن الكتاب محملاً ولم يكن قيد التحميل حالياً
        if (!isDownloaded && progress == null)
          IconButton(
            icon: const Icon(Icons.download_for_offline_rounded, color: Colors.indigo, size: 24),
            onPressed: () {
              HapticFeedback.mediumImpact();
              provider.startDownload(book); // تم تعديل الاسم هنا ليتوافق مع الـ Provider
            },
          ),
        IconButton(
          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 24),
          onPressed: () => _showRemoveConfirm(context, provider, book),
        ),
      ],
    );
  }

  void _openBook(BuildContext context, Book book, BookProvider provider) async {
    final String? path = book.localPath;
    if (path != null && await File(path).exists()) {
      provider.setLastReadBook(book);
      Navigator.push(context, MaterialPageRoute(builder: (context) => PDFViewerScreen(
        path: path,
        title: book.title,
        category: (book.category != null && book.category!.isNotEmpty) ? book.category! : 'عام',
        bookId: book.id,
      )));
    } else {
      // إذا لم يكن محملاً، نفتح الرابط (تأكد أن الـ Model يحتوي على previewLink)
      Navigator.push(context, MaterialPageRoute(builder: (context) => PDFViewerScreen(
        path: book.previewLink,
        title: book.title,
        category: (book.category != null && book.category!.isNotEmpty) ? book.category! : 'عام',
        bookId: book.id,
      )));
    }
  }

  Widget _buildEmptyState(bool isDark, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline_rounded, size: 80, color: primary.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text("مفضلتك خالية حالياً", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
          const Text("أضف كتبك المفضلة لتجدها هنا دائماً", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  void _showRemoveConfirm(BuildContext context, BookProvider provider, Book book) {
    showModalBottomSheet(
      context: context,
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("إزالة من المفضلة؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
            const SizedBox(height: 15),
            Text("هل أنت متأكد من إزالة '${book.title}'؟", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("تراجع"))),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                    onPressed: () { provider.toggleFavorite(book); Navigator.pop(context); },
                    child: const Text("إزالة الآن"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}