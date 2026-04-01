import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  // الحقول الأساسية للإعدادات
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar'); // اللغة الافتراضية

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  // --- القاموس الشامل للتطبيق (Translation Dictionary) ---
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_title': 'مكتبتي الاحترافية',
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف الشخصي',
      'downloaded_books': 'الكتب المحملة',
      'favorites': 'المفضلة',
      'liked_books': 'كتب أعجبتني',
      'dark_mode': 'الوضع الليلي',
      'language': 'لغة التطبيق',
      'logout': 'تسجيل الخروج',
      'confirm_logout': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'exit': 'خروج',
      'stats_fav': 'المفضلة',
      'stats_comments': 'التعليقات',
      'stats_likes': 'إعجابات',
      'account_management': 'إدارة الحساب',
      'prefs_appearance': 'التفضيلات والظهور',
      'distinguished_reader': 'قارئ متميز',
    },
    'en': {
      'app_title': 'Pro Library',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'downloaded_books': 'Downloads',
      'favorites': 'Favorites',
      'liked_books': 'Liked Books',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'logout': 'Logout',
      'confirm_logout': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'exit': 'Exit',
      'stats_fav': 'Favorites',
      'stats_comments': 'Comments',
      'stats_likes': 'Likes',
      'account_management': 'Account Management',
      'prefs_appearance': 'Preferences',
      'distinguished_reader': 'Top Reader',
    },
  };

  SettingsProvider() {
    _loadSettings();
  }

  // --- دالة الترجمة (Helper Function) ---
  String translate(String key) {
    return _localizedValues[_locale.languageCode]?[key] ?? key;
  }

  // 1. تحميل الإعدادات المحفوظة عند بدء التشغيل
  void _loadSettings() {
    var box = Hive.box('settings');

    // تحميل الثيم
    bool? isDark = box.get('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    // تحميل اللغة
    String? langCode = box.get('languageCode');
    if (langCode != null) {
      _locale = Locale(langCode);
    }

    notifyListeners();
  }

  // 2. إدارة الثيم وحفظه
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    var box = Hive.box('settings');
    box.put('isDarkMode', isDark);
    notifyListeners();
  }

  // 3. إدارة اللغة وحفظها
  void setLocale(Locale locale) {
    if (_locale == locale) return;

    _locale = locale;
    var box = Hive.box('settings');
    box.put('languageCode', locale.languageCode);

    notifyListeners();
  }

  // دالة مساعدة لمعرفة هل الوضع الحالي هو ليلي أم لا
  bool get isDarkMode => _themeMode == ThemeMode.dark;
}