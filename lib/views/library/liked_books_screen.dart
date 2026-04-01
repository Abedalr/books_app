import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import '../book_details/book_details_screen.dart';

class LikedBooksScreen extends StatefulWidget {
  const LikedBooksScreen({super.key});

  @override
  State<LikedBooksScreen> createState() => _LikedBooksScreenState();
}

class _LikedBooksScreenState extends State<LikedBooksScreen> {
  @override
  void initState() {
    super.initState();
    // جلب البيانات عند فتح الصفحة مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadLikedBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الكتب التي أعجبتني",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      // RefreshIndicator يسمح للمستخدم بتحديث القائمة بسحبها للأسفل
      body: RefreshIndicator(
        onRefresh: () => context.read<BookProvider>().loadLikedBooks(),
        child: Consumer<BookProvider>(
          builder: (context, provider, child) {
            final likedBooks = provider.likedBooksFromFirebase;

            // إذا كان التطبيق لا يزال يجلب البيانات من Firebase أو API
            if (provider.isLoading && likedBooks.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // إذا انتهى التحميل ولم يجد أي كتب
            if (likedBooks.isEmpty) {
              return ListView( // استخدمنا ListView لجعل السحب للتحديث يعمل حتى والقائمة فارغة
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("لا توجد كتب في قائمة الإعجابات بعد"),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: likedBooks.length,
              itemBuilder: (context, index) {
                final book = likedBooks[index];

                // التحقق ما إذا كان الكتاب لا يزال في حالة تحميل البيانات من API
                bool isStillLoading = book.title == "جاري التحميل...";

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    onTap: isStillLoading
                        ? null // تعطيل الضغط إذا لم تجهز البيانات بعد
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsScreen(book: book),
                        ),
                      );
                    },
                    leading: Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (book.thumbnail != null && book.thumbnail!.isNotEmpty)
                            ? Image.network(
                          book.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                        )
                            : const Icon(Icons.book, color: Colors.grey),
                      ),
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          book.authors.isNotEmpty ? book.authors.first : "مؤلف مجهول",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (isStillLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}