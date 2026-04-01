import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // الاستماع لتغيرات حالة التسجيل (Login/Logout)
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- 🔄 الدالة المطلوبة: تحديث بيانات المستخدم من السيرفر فوراً ---
  Future<void> reloadUser() async {
    try {
      if (_auth.currentUser != null) {
        // 1. طلب التحديث من سيرفر Firebase
        await _auth.currentUser!.reload();

        // 2. إعادة تعيين المستخدم الحالي (لأن الكائن القديم في الذاكرة لا يتحدث تلقائياً)
        _user = _auth.currentUser;

        // 3. إشعار الواجهات (مثل ProfileScreen) لإعادة بناء نفسها بالبيانات الجديدة
        notifyListeners();

        debugPrint("✅ تم تحديث بيانات المستخدم بنجاح. الرابط: ${_user?.photoURL}");
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء تحديث بيانات المستخدم: $e");
    }
  }

  // --- حفظ حالة الجلسة ---
  Future<void> _updateSessionStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // --- تحديث الاسم المستعار ---
  Future<void> updateDisplayName(String newName, BuildContext context) async {
    try {
      if (_user == null || newName.trim().isEmpty) return;
      _setLoading(true);

      await _user!.updateDisplayName(newName);

      await _firestore.collection('users').doc(_user!.uid).set({
        'displayName': newName,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // استدعاء التحديث لضمان ظهور الاسم الجديد فوراً
      await reloadUser();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث الاسم بنجاح")),
        );
      }
    } catch (e) {
      debugPrint("خطأ في تحديث الاسم: $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- تحديث صورة الملف الشخصي ---
  Future<void> updateProfilePicture(File imageFile) async {
    try {
      if (_user == null) return;
      _setLoading(true);

      // رفع الصورة لـ Storage
      Reference ref = _storage.ref().child('user_images').child('${_user!.uid}.jpg');
      await ref.putFile(imageFile);

      // جلب رابط التحميل
      String downloadUrl = await ref.getDownloadURL();

      // تحديث الرابط في Firebase Auth وفي Firestore
      await _user!.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(_user!.uid).update({
        'photoURL': downloadUrl,
      });

      // 🔥 أهم خطوة: تحديث الحالة المحلية فوراً
      await reloadUser();

    } catch (e) {
      debugPrint("خطأ في رفع الصورة: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- تسجيل حساب جديد ---
  Future<String?> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      await credential.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'displayName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'readerLevel': 'مبتدئ',
        'favorites_count': 0,
      });

      await _updateSessionStatus(true);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  // --- تسجيل الدخول ---
  Future<String?> login(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _updateSessionStatus(true);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  // --- تسجيل الخروج ---
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      await _updateSessionStatus(false);
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint("خطأ أثناء تسجيل الخروج: $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- إدارة المفضلة (معزولة لكل مستخدم) ---
  Stream<QuerySnapshot> getMyFavorites() {
    if (_user == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .snapshots();
  }

  Future<void> toggleFavorite(String bookId, Map<String, dynamic> bookData) async {
    if (_user == null) return;
    DocumentReference docRef = _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc(bookId);

    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(bookData);
    }
  }

  // --- إعادة تعيين كلمة المرور ---
  Future<String?> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'لا يوجد مستخدم بهذا البريد.';
      case 'wrong-password': return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use': return 'هذا البريد مستخدم بالفعل.';
      case 'weak-password': return 'كلمة المرور ضعيفة جداً.';
      case 'invalid-email': return 'تنسيق البريد الإلكتروني غير صحيح.';
      default: return 'حدث خطأ: ${e.message}';
    }
  }
}