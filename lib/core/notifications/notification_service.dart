import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps Firebase Cloud Messaging + flutter_local_notifications so the rest
/// of the app can stay agnostic about which backend delivered the message.
///
/// Lifecycle:
/// - `init()` is called once at startup (after `Firebase.initializeApp`).
/// - `saveToken(userId)` is called when a user signs in.
/// - `removeTokenOnSignOut(userId)` is called when a user signs out.
class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseFirestore? firestore,
    void Function(String route)? onNavigate,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _local = localNotifications ?? FlutterLocalNotificationsPlugin(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _onNavigate = onNavigate;

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final FirebaseFirestore _firestore;
  final void Function(String route)? _onNavigate;

  static const _channelId = 'bills_due';
  static const _channelName = 'Bill reminders';
  static const _channelDescription =
      'Alerts when a bill is due or overdue.';

  /// Drawable resource name (no `@drawable/` prefix) for the small icon
  /// shown in the status bar. Must match `ic_notification.xml` and the
  /// `default_notification_icon` meta-data in AndroidManifest so cold
  /// FCM messages and foreground local notifications look identical.
  static const _smallIcon = 'ic_notification';

  /// Tint applied to `_smallIcon`. Matches the launcher background and
  /// the `notification_color` resource.
  static const Color _accent = Color(0xFF6366F1);

  bool _initialized = false;
  String? _currentToken;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // FCM permission. On iOS this triggers the system prompt; on Android 13+
    // we still rely on POST_NOTIFICATIONS but FCM also needs this call to
    // mint APNs tokens.
    await _messaging.requestPermission();

    // Local notifications init (used to display foreground messages on
    // Android, and as the channel registration target). The default
    // small icon is the monochrome silhouette — using the colored
    // launcher icon would render as the system bell on Android 5+.
    const androidInit = AndroidInitializationSettings(_smallIcon);
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _handlePayload(payload);
      },
    );

    // Create the Android channel up-front so the first notification doesn't
    // race the channel-not-found warning.
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );

    // Foreground messages: FCM doesn't display anything itself, so we render
    // via the local plugin.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // App was opened from a tapped notification (warm or cold start).
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = message.data['route'] as String?;
      if (route != null) _onNavigate?.call(route);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['route'] as String?;
      if (route != null) _onNavigate?.call(route);
    }
  }

  Future<void> saveToken(String userId) async {
    if (userId.isEmpty) return;
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      _currentToken = token;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .set({
            'token': token,
            'platform': _platform(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } on Exception catch (e, st) {
      log(
        'NotificationService.saveToken failed',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> removeTokenOnSignOut(String userId) async {
    if (userId.isEmpty) return;
    final token = _currentToken;
    if (token == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .delete();
    } on Exception {
      // Best-effort cleanup; ignore failures.
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    await _local.show(
      id: message.messageId.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          // Pin the small-icon + tint here too — without this Android
          // would otherwise grab whatever the AppCompat default is, and
          // foreground notifications would diverge visually from the
          // background ones delivered by FCM.
          icon: _smallIcon,
          color: _accent,
          colorized: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'] as String?,
    );
  }

  void _handlePayload(String payload) {
    if (payload.startsWith('/')) _onNavigate?.call(payload);
  }

  String _platform() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}
