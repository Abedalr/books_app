import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // تهيئة الإشعارات عند تشغيل التطبيق
  static Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // التصحيح: تمرير initializationSettings مباشرة
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint("تم الضغط على الإشعار: ${details.payload}");
      },
    );

    // إنشاء قناة إشعارات لأندرويد (ضروري لإظهار الإشعار فوق التطبيقات)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'تنبيهات هامة',
      description: 'هذه القناة تستخدم لإشعارات الردود والمراجعات.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // طلب صلاحيات الإشعارات (لأندرويد 13 فما فوق)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // دالة عرض الإشعار الفوري
  static Future<void> showNotification({int? id, String? title, String? body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'تنبيهات هامة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id ?? DateTime.now().second,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'item x',
    );
  }

  // الاستماع للإشعارات الجديدة في Firestore
  static void listenToNotifications(String userId) {
    debugPrint("🔔 بدأ الاستماع لإشعارات المستخدم: $userId");

    FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;

          showNotification(
            id: change.doc.id.hashCode,
            title: data['senderName'] ?? "تنبيه جديد",
            body: data['message'] ?? "لديك إشعار جديد في مكتبتك",
          );
        }
      }
    });
  }
}