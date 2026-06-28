import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'financial_app';
  static const _channelName = 'Aplikasi Keuangan';

  Future<void> initialize() async {
    // Request FCM permission
    await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    // Init local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId, _channelName,
              description: 'Notifikasi tagihan & keuangan',
              importance: Importance.high,
            ),
          );
    }

    // Handle FCM foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Aplikasi Keuangan',
        body: message.notification?.body ?? '',
      );
    });

    debugPrint('NotificationService initialized');
  }

  /// Save FCM token to Firestore for cloud push
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        });
        debugPrint('FCM token saved: $token');
      }
    } catch (e) {
      debugPrint('saveTokenToFirestore error: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId, _channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id, title, body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// Check & notify bills due today/tomorrow
  Future<void> checkBillsDue(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final in3days = today.add(const Duration(days: 3));

      final snapshot = await FirebaseFirestore.instance
          .collection('bills')
          .doc(userId)
          .collection('items')
          .where('status', whereIn: ['UNPAID', 'PARTIAL', 'unpaid', 'partial'])
          .get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();
        final dueDate = (data['dueDate'] as dynamic)?.toDate() as DateTime?;
        if (dueDate == null) continue;

        final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
        String? message;

        if (due == today) {
          message = 'Tagihan "${data['name']}" jatuh tempo HARI INI!';
        } else if (due == tomorrow) {
          message = 'Tagihan "${data['name']}" jatuh tempo BESOK';
        } else if (due.isAfter(today) && due.isBefore(in3days)) {
          final daysLeft = due.difference(today).inDays;
          message = 'Tagihan "${data['name']}" jatuh tempo dalam $daysLeft hari';
        }

        if (message != null) {
          await _showLocalNotification(
            id: i + 100,
            title: '⚠️ Pengingat Tagihan',
            body: message,
          );
        }
      }
    } catch (e) {
      debugPrint('checkBillsDue error: $e');
    }
  }

  Future<String?> getToken() async => await _messaging.getToken();
}
