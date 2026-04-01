import 'package:books/views/home/app_categories.dart';
import 'package:books/views/home/sub_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/book_provider.dart';
import '../../view_models/auth_provider.dart';
import '../../widgets/book_card.dart';
import 'category_screen.dart';

class MainBooksView extends StatefulWidget {
  const MainBooksView({super.key});

  @override
  State<MainBooksView> createState() => _MainBooksViewState();
}

class _MainBooksViewState extends State<MainBooksView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final allCategories = AppCategories.allCategories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // نمنع الخروج المباشر من التطبيق
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // إذا كان البحث مفتوحاً، أغلقه أولاً عند الضغط على زر الرجوع
        if (_isSearching) {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            bookProvider.searchBooks("");
          });
          return;
        }

        // هنا المنطق المهم: إذا كان المستخدم في صفحة التصنيفات وضغط رجوع،
        // نرجعه للتبويب الأول (الرئيسية) بدل ما يطلع من التطبيق.
        // ملاحظة: هذا يفترض أنك تستخدم TabController أو IndexedStack في الصفحة الأم.
        // إذا كنت تستخدم BottomNavigationBar بسيط، يمكنك استدعاء دالة الـ onTap للـ Index 0.

        // إذا أردت السماح بالرجوع الطبيعي إذا كان هناك Navigator stack:
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          // إذا لم يكن هناك صفحات للرجوع إليها، يمكنك توجيهه للرئيسية برمجياً
          // أو إظهار ديالوج تأكيد الخروج.
          _handleBackToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50],
        appBar: AppBar(
          toolbarHeight: 70,
          title: _isSearching
              ? _buildSearchField(bookProvider, isDark)
              : Text("الموسوعة الشاملة",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  color: isDark ? Colors.white : Colors.indigo[900])),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            _buildAppBarAction(
              icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    bookProvider.searchBooks("");
                  }
                });
              },
              isDark: isDark,
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: bookProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
            : _isSearching && bookProvider.searchResults.isNotEmpty
            ? _buildGridResults(bookProvider.searchResults)
            : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "التصنيفات",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo',
                          color: isDark ? Colors.white : Colors.indigo[900]
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.indigoAccent,
                          borderRadius: BorderRadius.circular(10)
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final cat = allCategories[index];
                    return _buildCategoryItem(context, cat, isDark);
                  },
                  childCount: allCategories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // دالة اختيارية للتحكم في كيفية العودة للرئيسية
  void _handleBackToHome(BuildContext context) {
    // إذا كنت تستخدم Provider لإدارة الـ Navigation index:
    // context.read<NavigationProvider>().setIndex(0);

    // أو إذا أردت فقط إغلاق التطبيق بذكاء:
    // SystemNavigator.pop();
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, dynamic> cat, bool isDark) {
    final Color catColor = cat['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: catColor.withOpacity(isDark ? 0.05 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () => _handleCategoryNavigation(context, cat, catColor),
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [catColor.withOpacity(0.2), catColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'], color: catColor, size: 38),
              ),
              const SizedBox(height: 15),
              Text(
                cat['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "استكشف الآن",
                style: TextStyle(fontSize: 11, color: catColor.withOpacity(0.8), fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _handleCategoryNavigation(BuildContext context, Map<String, dynamic> cat, Color themeColor) {
    if (cat['subCategories'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryScreen(
            mainCategoryName: cat['name'],
            subCategories: (cat["subCategories"] as List)
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
            themeColor: themeColor,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryScreen(
            categoryTitle: cat['name'],
            categoryQuery: cat['query'],
          ),
        ),
      );
    }
  }

  Widget _buildSearchField(BookProvider provider, bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textDirection: TextDirection.rtl,
        onChanged: (value) => provider.searchBooks(value.trim()),
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'ابحث عن عنوان، مؤلف...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.indigoAccent, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({required IconData icon, required VoidCallback onPressed, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: Icon(icon, color: isDark ? Colors.white : Colors.indigo[900], size: 24),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildGridResults(List books) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => BookCard(book: books[index]),
    );
  }
}