import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- استيراد الـ Providers ---
// تأكد أن هذه المسارات مطابقة تماماً لبنية المجلدات الجديدة لديك
import 'view_models/auth_provider.dart';
import 'view_models/book_provider.dart';
import 'view_models/settings_provider.dart';
import 'view_models/ai_provider.dart';
import 'view_models/analytics_provider.dart';

// --- استيراد الشاشات والخدمات ---
import 'views/onboarding/splash_screen.dart';
import 'views/home/home_screen.dart';
import 'services/notification_service.dart';
import 'widgets/network_wrapper.dart';

// مفتاح التنقل العالمي للتحكم في التنقل (Navigator) من أي مكان في الكود
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // التأكد من تهيئة روابط Flutter قبل أي عملية أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase مع تفعيل ميزة العمل بدون إنترنت (Offline Persistence)
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 2. إعدادات تعقب الأخطاء (Crashlytics) - تعمل فقط في وضع الـ Release
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // 3. تهيئة Hive للتخزين المحلي السريع للإعدادات
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // 4. تهيئة الإشعارات المحلية وتفقد إذا تم فتح التطبيق عبر إشعار
  try {
    await NotificationService.initNotification();
  } catch (e) {
    debugPrint("⚠️ خطأ في تهيئة الإشعارات: $e");
  }

  // 5. فحص حالة تسجيل الدخول (Auto Login) عبر SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // تحديد شاشة البداية: إذا كان مسجلاً يذهب للرئيسية، وإلا يبدأ بالـ Splash
  Widget initialScreen = isLoggedIn ? const HomeScreen() : const SplashScreen();

  // 6. ضبط شفافية ولون أشرطة النظام (Status & Navigation Bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // تشغيل التطبيق مع تغليفه بـ MultiProvider لتوفير البيانات لكل الشاشات
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),        // مساعد الذكاء الاصطناعي
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()), // لوحة الإحصائيات
      ],
      child: MyApp(startScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    // استهلاك إعدادات اللغة والثيم من الـ SettingsProvider لتحديث الواجهة فورياً
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          // ربط مفتاح التنقل العالمي هنا
          navigatorKey: navigatorKey,
          title: 'Books AI Assistant',
          debugShowCheckedModeBanner: false,

          // إعدادات اللغة الدولية (Localization)
          locale: settings.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],

          // إدارة أوضاع الثيمات (فاتح / داكن / حسب النظام)
          themeMode: settings.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),

          // بناء هيكل التطبيق مع معالجة اتجاه اللغة وحالة الشبكة
          builder: (context, child) {
            return PopScope(
              canPop: false, // معالجة الرجوع يدوياً لضمان عدم الخروج المفاجئ
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                final NavigatorState? navigator = navigatorKey.currentState;
                if (navigator != null && navigator.canPop()) {
                  navigator.pop();
                } else {
                  SystemNavigator.pop(); // الخروج من التطبيق إذا كنا في الشاشة الرئيسية
                }
              },
              child: Directionality(
                textDirection: settings.locale.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                // تغليف التطبيق بمراقب حالة الإنترنت
                child: NetworkWrapper(child: child!),
              ),
            );
          },

          home: startScreen,
        );
      },
    );
  }

  // --- إعدادات الثيم الفاتح (Light Theme) ---
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo', // تأكد من وجود الخط في ملف pubspec.yaml
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF6366F1), // Indigo
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // --- إعدادات الثيم الداكن (Dark Theme) ---
  ThemeData _buildDarkTheme() {
    const darkBg = Color(0xFF0F172A);
    const darkCard = Color(0xFF1E293B);
    const primaryIndigo = Color(0xFF6366F1);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryIndigo,
        secondary: Color(0xFF818CF8),
        surface: darkCard,
        onSurface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}