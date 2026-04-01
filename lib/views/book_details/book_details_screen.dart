import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/book_model.dart';
import '../../view_models/auth_provider.dart';
import '../../view_models/book_provider.dart';
import 'pdf_viewer_screen.dart';

// -------------------------------------------------------------------
// 1. صفحة "سجل مراجعاتي" - محدثة لتدعم التنقل المباشر
// -------------------------------------------------------------------
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("سجل مراجعاتي", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text("يرجى تسجيل الدخول أولاً"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('book_reviews')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("لم تنشر أي مراجعات بعد.", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final review = doc.data() as Map<String, dynamic>;
              return _buildMyReviewCard(context, doc.id, review, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildMyReviewCard(BuildContext context, String reviewId, Map<String, dynamic> review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToBook(context, review['bookId']),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (review['bookThumbnail'] != null && review['bookThumbnail'] != "")
                          ? CachedNetworkImage(
                        imageUrl: review['bookThumbnail'],
                        width: 45,
                        height: 65,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(width: 45, height: 65, color: Colors.grey[200], child: const Icon(Icons.book)),
                      )
                          : Container(width: 45, height: 65, color: Colors.grey[200], child: const Icon(Icons.book)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['bookTitle'] ?? "كتاب غير معروف",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo', color: Colors.indigo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildStarRow(review['rating'] ?? 5),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDelete(context, reviewId),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                Text(
                  review['content'] ?? "",
                  style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    review['createdAt'] != null ? DateFormat('yyyy/MM/dd - hh:mm a').format((review['createdAt'] as Timestamp).toDate()) : "",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBook(BuildContext context, String? bookId) async {
    if (bookId == null || bookId.isEmpty) return;
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));

    try {
      final book = await bookProvider.getBookById(bookId);
      if (context.mounted) Navigator.pop(context);

      if (book != null) {
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => BookDetailsScreen(book: book)));
        }
      } else {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("عذراً، الكتاب غير متوفر حالياً")));
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _buildStarRow(num rating) {
    return Row(
      children: List.generate(
          5,
              (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: 16,
          )),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المراجعة", style: TextStyle(fontFamily: 'Cairo')),
        content: const Text("هل أنت متأكد من رغبتك في حذف هذه المراجعة؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('book_reviews').doc(id).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2. ويدجت المراجعات داخل صفحة الكتاب (BookReviewsSection)
// -------------------------------------------------------------------
class BookReviewsSection extends StatefulWidget {
  final Book book;
  const BookReviewsSection({required this.book, super.key});

  @override
  State<BookReviewsSection> createState() => _BookReviewsSectionState();
}

class _BookReviewsSectionState extends State<BookReviewsSection> {
  final TextEditingController _controller = TextEditingController();
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<BookProvider>(context, listen: false).fetchBookReviews(widget.book.id);
    });
  }

  void _showAllReviewsForThisBook(BuildContext context, BookProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("جميع مراجعات الكتاب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ),
            Expanded(
              child: provider.isReviewsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.bookReviews.isEmpty
                  ? const Center(child: Text("لا توجد مراجعات لهذا الكتاب بعد"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.bookReviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewListCard(provider.bookReviews[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("ملخصات وآراء القراء", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            TextButton.icon(
              onPressed: () => _showAllReviewsForThisBook(context, bookProvider, isDark),
              icon: const Icon(Icons.list_alt_rounded, size: 18),
              label: const Text("سجل المراجعات", style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "اكتب ملخصك أو تقييمك الفني للكتاب...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
              const Divider(),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildRatingPicker(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        await bookProvider.addBookReview(
                          bookId: widget.book.id,
                          bookTitle: widget.book.title,
                          bookThumbnail: widget.book.thumbnail,
                          content: _controller.text,
                          rating: _rating,
                        );
                        _controller.clear();
                        if (mounted) FocusScope.of(context).unfocus();
                      }
                    },
                    child: const Text("نشر المراجعة", style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        bookProvider.isReviewsLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookProvider.bookReviews.length > 2 ? 2 : bookProvider.bookReviews.length,
          itemBuilder: (context, index) => _buildReviewListCard(bookProvider.bookReviews[index], isDark),
        ),
      ],
    );
  }

  Widget _buildRatingPicker() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          5,
              (index) => InkWell(
            onTap: () => setState(() => _rating = index + 1.0),
            child: Icon(index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 28),
          )),
    );
  }

  Widget _buildReviewListCard(Map<String, dynamic> review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: (review['userImage'] != null && review['userImage'] != "") ? NetworkImage(review['userImage']) : null,
                child: (review['userImage'] == null || review['userImage'] == "") ? const Icon(Icons.person, size: 15) : null,
              ),
              const SizedBox(width: 8),
              Text(review['userName'] ?? "مستخدم", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              _buildStarRow(review['rating'] ?? 5, 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(review['content'] ?? "", style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildStarRow(num rating, double size) {
    return Row(
      children: List.generate(
          5,
              (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: size,
          )),
    );
  }
}

// -------------------------------------------------------------------
// 3. صفحة تفاصيل الكتاب (BookDetailsScreen) - النسخة النهائية المطورة
// -------------------------------------------------------------------
class BookDetailsScreen extends StatefulWidget {
  final Book book;
  const BookDetailsScreen({required this.book, super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isExpanded = false;
  String? _replyingToId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    // تسجيل الكتاب كآخر كتاب تمت قراءته أو تصفحه
    Future.delayed(Duration.zero, () {
      Provider.of<BookProvider>(context, listen: false).setLastReadBook(widget.book);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // --- دوال المساعدة ---
  void _toggleBookLike(String bookId, User? user) async {
    if (user == null) return;
    await Provider.of<BookProvider>(context, listen: false).toggleLike(widget.book);
  }

  void _sendComment(String text, String bookId, User? user) async {
    if (text.trim().isEmpty || user == null) return;
    try {
      String finalShortText = text;
      if (_replyingToName != null && text.contains("@$_replyingToName")) {
        finalShortText = text.replaceFirst("@$_replyingToName", "").trim();
      }

      await FirebaseFirestore.instance.collection('comments').add({
        'bookId': bookId,
        'userId': user.uid,
        'userName': user.displayName ?? "مستخدم",
        'text': finalShortText,
        'createdAt': FieldValue.serverTimestamp(),
        'parentId': _replyingToId,
        'replyToName': _replyingToName,
        'likesCount': 0,
      });

      _commentController.clear();
      setState(() { _replyingToId = null; _replyingToName = null; });
      _commentFocusNode.unfocus();

      // تحديث الإحصائيات في الـ Provider
      if (mounted) Provider.of<BookProvider>(context, listen: false).getUserStats();

    } catch (e) { debugPrint(e.toString()); }
  }

  void _likeComment(String commentId, String userId) async {
    final commentRef = FirebaseFirestore.instance.collection('comments').doc(commentId);
    final likeRef = commentRef.collection('likes').doc(userId);
    final doc = await likeRef.get();
    if (doc.exists) {
      await likeRef.delete();
      await commentRef.update({'likesCount': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'userId': userId, 'timestamp': FieldValue.serverTimestamp()});
      await commentRef.update({'likesCount': FieldValue.increment(1)});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(context, isDark),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookMainHeader(),
                    _buildActionButtons(context),
                    _buildLikeAndStatsBar(user),
                    const Divider(height: 30, thickness: 0.5),

                    // زر الانتقال لسجل مراجعات المستخدم
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        tileColor: isDark ? Colors.white10 : Colors.indigo.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: const Icon(Icons.history_edu_rounded, color: Colors.indigo),
                        title: const Text("استعرض كافة مراجعاتي السابقة", style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
                      ),
                    ),

                    _buildDescriptionSection(isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: BookReviewsSection(book: widget.book),
                    ),
                    const Divider(height: 30, thickness: 0.5),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text("الدردشة والتعليقات العامة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                    _buildCommentsList(widget.book.id, user, isDark),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomInputArea(user, isDark),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.indigo[900],
      actions: [
        IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => Share.share('أنصحك بقراءة كتاب: "${widget.book.title}" عبر تطبيق الموسوعة الشاملة')),
        _buildFavoriteButton(),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.book.thumbnail != null)
              CachedNetworkImage(
                  imageUrl: widget.book.thumbnail!,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.6),
                  colorBlendMode: BlendMode.darken),
            Center(
                child: Hero(
                    tag: 'book_${widget.book.id}',
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.book.thumbnail ?? "",
                          height: 180,
                          placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                          errorWidget: (context, url, error) => const Icon(Icons.book, size: 100, color: Colors.white),
                        )))),
          ],
        ),
      ),
    );
  }

  Widget _buildBookMainHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 8),
        Text("تأليف: ${widget.book.authors.join(', ')}",
            style: const TextStyle(color: Colors.indigo, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
      ]),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => launchUrl(Uri.parse(widget.book.previewLink)),
                icon: const Icon(Icons.chrome_reader_mode_outlined, size: 20),
                label: const Text("معاينة", style: TextStyle(fontFamily: 'Cairo')))),
        const SizedBox(width: 12),
        Expanded(child: _buildDownloadBtn(context)),
      ]),
    );
  }

  Widget _buildDownloadBtn(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    // التحقق من حالة التحميل الحالية من الـ Provider
    bool isDownloaded = bookProvider.downloadedBooks.any((b) => b.id == widget.book.id);
    bool isDownloading = bookProvider.downloadingBooksProgress.containsKey(widget.book.id);
    double progress = isDownloading ? bookProvider.downloadingBooksProgress[widget.book.id]!['progress'] : 0.0;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: isDownloaded ? Colors.teal[600] : (isDownloading ? Colors.orange : Colors.grey[200]),
          foregroundColor: isDownloaded || isDownloading ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: () async {
        if (isDownloaded) {
          final savedBook = bookProvider.downloadedBooks.firstWhere((b) => b.id == widget.book.id);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PDFViewerScreen(
                    path: savedBook.localPath!,
                    title: widget.book.title,
                    category: (widget.book.category.isNotEmpty) ? widget.book.category[0] : 'عام',
                    bookId: widget.book.id,
                  )));
        } else if (!isDownloading) {
          bookProvider.startDownload(widget.book);
        }
      },
      icon: isDownloading
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: progress, strokeWidth: 2, color: Colors.white))
          : Icon(isDownloaded ? Icons.menu_book : Icons.download_rounded, size: 20),
      label: Text(
        isDownloaded ? "اقرأ" : (isDownloading ? "${(progress * 100).toInt()}%" : "تنزيل"),
        style: const TextStyle(fontFamily: 'Cairo'),
      ),
    );
  }

  Widget _buildLikeAndStatsBar(User? user) {
    return Consumer<BookProvider>(
      builder: (context, provider, _) {
        bool isLiked = provider.likedBooksFromFirebase.any((b) => b.id == widget.book.id);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(children: [
            InkWell(
              onTap: () => _toggleBookLike(widget.book.id, user),
              child: Row(
                children: [
                  Icon(isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, color: isLiked ? Colors.blue : Colors.grey, size: 24),
                  const SizedBox(width: 8),
                  Text(isLiked ? "أعجبك" : "أعجبني", style: TextStyle(color: isLiked ? Colors.blue : Colors.grey, fontSize: 13, fontFamily: 'Cairo')),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            const Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Text("(${provider.bookReviews.length} مراجعة)", style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
          ]),
        );
      },
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("عن الكتاب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(widget.book.description,
              maxLines: _isExpanded ? null : 4,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(height: 1.6, color: isDark ? Colors.white70 : Colors.black87, fontFamily: 'Cairo', fontSize: 14)),
        ),
        TextButton(onPressed: () => setState(() => _isExpanded = !_isExpanded), child: Text(_isExpanded ? "عرض أقل" : "إقرأ المزيد", style: const TextStyle(fontFamily: 'Cairo'))),
      ]),
    );
  }

  Widget _buildCommentsList(String bookId, User? user, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('comments').where('bookId', isEqualTo: bookId).orderBy('createdAt', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("كن أول من يعلق على هذا الكتاب", style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'))));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            bool isMe = user?.uid == data['userId'];
            bool isReply = data['parentId'] != null;
            return Container(
              margin: EdgeInsets.fromLTRB(isReply ? 50 : 20, 5, 20, 5),
              child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: isMe ? Colors.indigo[600] : (isDark ? Colors.white10 : Colors.grey[100]), borderRadius: BorderRadius.circular(15)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (!isMe) Text(data['userName'] ?? "مستخدم", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[300], fontSize: 12)),
                    if (isReply) Text("@${data['replyToName']}", style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(data['text'] ?? "", style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 13)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(data['createdAt'] != null ? DateFormat('hh:mm a').format((data['createdAt'] as Timestamp).toDate()) : "الآن",
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 15),
                    InkWell(
                        onTap: () => user != null ? _likeComment(doc.id, user.uid) : null,
                        child: Row(children: [
                          const Icon(Icons.favorite, size: 12, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text("${data['likesCount'] ?? 0}", style: const TextStyle(fontSize: 11))
                        ])),
                    const SizedBox(width: 15),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _replyingToId = doc.id;
                            _replyingToName = data['userName'];
                            _commentController.text = "@${data['userName']} ";
                            _commentFocusNode.requestFocus();
                          });
                        },
                        child: const Text("رد", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
                  ]),
                ),
              ]),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomInputArea(User? user, bool isDark) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, top: 10, left: 15, right: 15),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(children: [
            if (_replyingToId != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    const Icon(Icons.reply, size: 16, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text("رد على $_replyingToName", style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() {
                          _replyingToId = null;
                          _replyingToName = null;
                          _commentController.clear();
                        }))
                  ])),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                          hintText: "أضف رأيك هنا...",
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: isDark ? Colors.white10 : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20)))),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                  backgroundColor: Colors.indigo,
                  onPressed: () => _sendComment(_commentController.text, widget.book.id, user),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
            ]),
          ]),
        ));
  }

  Widget _buildFavoriteButton() {
    return Consumer<BookProvider>(builder: (context, provider, _) {
      bool isFav = provider.isFavorite(widget.book.id);
      return IconButton(
          icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: isFav ? Colors.redAccent : Colors.white),
          onPressed: () => provider.toggleFavorite(widget.book));
    });
  }
}