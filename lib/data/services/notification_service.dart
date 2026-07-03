import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'spending_limit_service.dart';
import 'monthly_budget_service.dart';
import '../local/spending_limit_dao.dart';
import '../local/monthly_budget_dao.dart';
import '../local/transaction_dao.dart';
import '../local/database_helper.dart';
import '../../domain/models/spending_limit_model.dart';
import '../../domain/models/monthly_budget_model.dart';

class NotificationService {
  // ─── Singleton ─────────────────────────────────────────────────────────────
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Anti-spam throttle: limitId+status → tanggal terakhir notif ──────────
  // Key: '${limitId}_${status.name}', Value: date string 'yyyy-MM-dd'
  final Map<String, String> _lastNotifDate = {};

  static const String _channelId = 'financial_app';
  static const String _channelName = 'Aplikasi Keuangan';
  static const String _channelLimitId = 'spending_limit';
  static const String _channelLimitName = 'Limit Pengeluaran';

  Future<void> initialize() async {
    if (_initialized) return;
    await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId, _channelName,
          description: 'Notifikasi tagihan & keuangan',
          importance: Importance.high,
        ),
      );
      await plugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelLimitId, _channelLimitName,
          description: 'Peringatan limit pengeluaran harian',
          importance: Importance.high,
        ),
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Aplikasi Keuangan',
        body: message.notification?.body ?? '',
      );
    });

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Pastikan sudah initialized sebelum show notif
  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  /// Save FCM token to Firestore
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

  /// Check spending limits → notifikasi lokal jika warning/exceeded
  /// Anti-spam: max 1x notif per limitId+status per hari
  Future<void> checkSpendingLimits(String userId) async {
    await _ensureInitialized();
    try {
      final service = SpendingLimitService(
        dao: SpendingLimitDao(),
        txDao: TransactionDao(dbHelper: DatabaseHelper()),
      );
      final results = await service.checkLimits(userId);
      final currency = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (int i = 0; i < results.length; i++) {
        final r = results[i];

        // Throttle: skip jika sudah notif hari ini dengan status yang sama
        final throttleKey = '${r.limit.id}_${r.status.name}';
        if (_lastNotifDate[throttleKey] == today) continue;

        final label = r.limit.categoryName != null
            ? '${r.limit.categoryIcon ?? ''} ${r.limit.categoryName}'
            : 'Semua Pengeluaran';
        final spent = currency.format(r.spent);
        final limit = currency.format(r.limit.dailyLimit);
        final pct = (r.spent / r.limit.dailyLimit * 100).round();

        String title;
        String body;

        if (r.status == SpendingLimitStatus.warning) {
          title = '⚠️ Hampir Mencapai Limit';
          body = '$label: $spent dari $limit ($pct%)';
        } else {
          title = '🔴 Limit Pengeluaran Terlampaui';
          body = '$label: $spent melebihi limit $limit';
        }

        await _showLocalNotification(
          id: 200 + i,
          title: title,
          body: body,
          channelId: _channelLimitId,
          channelName: _channelLimitName,
        );

        // Tandai sudah notif hari ini → anti-spam
        _lastNotifDate[throttleKey] = today;
      }
    } catch (e) {
      debugPrint('checkSpendingLimits error: $e');
    }
  }

  /// Check tagihan jatuh tempo → notifikasi lokal
  /// Anti-spam: max 1x notif per docId per hari
  /// Skip jika status PAID (sudah lunas)
  Future<void> checkBillsDue(String userId) async {
    await _ensureInitialized();
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final in3days = today.add(const Duration(days: 3));
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      final snapshot = await FirebaseFirestore.instance
          .collection('bills')
          .doc(userId)
          .collection('items')
          .where('status', whereIn: ['UNPAID', 'PARTIAL', 'unpaid', 'partial'])
          .get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        // Validasi status: skip jika sudah PAID (double-check client-side)
        final status = (data['status'] as String? ?? '').toUpperCase();
        if (status == 'PAID') continue;

        // Skip tagihan recurring yang sudah dibayar bulan ini
        // Recurring = punya billingDay. Setelah bayar, updatedAt diset ke bulan ini.
        final billingDay = data['billingDay'] as int?;
        if (billingDay != null) {
          final updatedAt = (data['updatedAt'] as dynamic)?.toDate() as DateTime?;
          if (updatedAt != null &&
              updatedAt.year == now.year &&
              updatedAt.month == now.month) {
            // Sudah ada aktivitas bayar bulan ini → skip notif
            continue;
          }
        }

        final dueDate = (data['dueDate'] as dynamic)?.toDate() as DateTime?;
        if (dueDate == null) continue;

        final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

        // Tentukan label waktu jatuh tempo
        String? message;
        if (due == today) {
          message = 'Tagihan "${data['name']}" jatuh tempo HARI INI!';
        } else if (due == tomorrow) {
          message = 'Tagihan "${data['name']}" jatuh tempo BESOK';
        } else if (due.isAfter(today) && due.isBefore(in3days)) {
          final daysLeft = due.difference(today).inDays;
          message = 'Tagihan "${data['name']}" jatuh tempo dalam $daysLeft hari';
        }

        if (message == null) continue;

        // Anti-spam throttle: max 1x per docId per hari
        final throttleKey = 'bill_${doc.id}_$todayStr';
        if (_lastNotifDate[throttleKey] == todayStr) continue;

        await _showLocalNotification(
          id: i + 100,
          title: '⚠️ Pengingat Tagihan',
          body: message,
        );

        // Tandai sudah notif hari ini
        _lastNotifDate[throttleKey] = todayStr;
      }
    } catch (e) {
      debugPrint('checkBillsDue error: $e');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    int id = 0,
    String channelId = _channelId,
    String channelName = _channelName,
  }) async {
    await _ensureInitialized();
    final androidDetails = AndroidNotificationDetails(
      channelId, channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// Check anggaran bulanan → notifikasi lokal jika warning/exceeded
  /// Anti-spam: max 1x notif per budgetId+status per hari
  Future<void> checkMonthlyBudgets(String userId) async {
    await _ensureInitialized();
    try {
      final service = MonthlyBudgetService(
        dao: MonthlyBudgetDao(),
        txDao: TransactionDao(dbHelper: DatabaseHelper()),
      );
      final yearMonth = MonthlyBudgetService.formatYearMonth(DateTime.now());
      final budgets = await service.getBudgetsByMonth(userId, yearMonth);
      final currency = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (int i = 0; i < budgets.length; i++) {
        final b = budgets[i];
        final actual = await service.getActualSpending(userId, yearMonth, b.categoryId);
        final status = b.statusForSpent(actual);
        if (status == BudgetStatus.safe) continue;

        // Throttle: skip jika sudah notif hari ini dengan status yang sama
        final throttleKey = 'budget_${b.id}_${status.name}';
        if (_lastNotifDate[throttleKey] == today) continue;

        final label = '${b.categoryIcon} ${b.categoryName}';
        final spentStr = currency.format(actual);
        final budgetStr = currency.format(b.budgetAmount);
        final pct = (actual / b.budgetAmount * 100).round();

        String title;
        String body;

        if (status == BudgetStatus.warning) {
          title = '⚠️ Anggaran Hampir Habis';
          body = '$label: $spentStr dari $budgetStr ($pct%)';
        } else {
          title = '🔴 Anggaran Bulanan Terlampaui';
          body = '$label: $spentStr melebihi anggaran $budgetStr';
        }

        await _showLocalNotification(
          id: 300 + i,
          title: title,
          body: body,
          channelId: _channelLimitId,
          channelName: _channelLimitName,
        );

        _lastNotifDate[throttleKey] = today;
      }
    } catch (e) {
      debugPrint('checkMonthlyBudgets error: $e');
    }
  }

  Future<String?> getToken() async => await _messaging.getToken();
}
