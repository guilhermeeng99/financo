import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/notifications/notification_background_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
///
/// Cross-account isolation: every push is matched against the currently
/// signed-in `FirebaseAuth.uid` via [shouldDeliver]. Messages whose
/// `data.userId` does not equal the local uid are silently dropped — they
/// belong to a different account that ever logged into this device (its
/// FCM token remained registered under that uid even after sign-out).
class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    void Function(String route)? onNavigate,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _local = localNotifications ?? FlutterLocalNotificationsPlugin(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _onNavigate = onNavigate;

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
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

  /// Pure predicate: should a message tagged with [messageUserId] reach
  /// the device that is currently signed in as [currentUid]?
  ///
  /// Rules:
  /// - Messages without `userId` in the data payload are delivered
  ///   (backwards-compatible with un-scoped pushes; today there are none,
  ///   but keeps the door open for system-wide announcements).
  /// - Messages with a `userId` are delivered iff it equals the local
  ///   uid. A signed-out device drops every scoped push.
  ///
  /// Why this exists: an FCM token survives across sign-ins on the same
  /// device. If account A and account B both ever logged in here, the
  /// token sits under `users/A/fcmTokens` AND `users/B/fcmTokens`. The
  /// daily `notifyBillsDue` Cloud Function would then push *both*
  /// accounts' reminders to a device currently logged into only one of
  /// them. This filter is the client side of the fix; the server side
  /// includes `userId` in the data payload so the client can decide.
  ///
  /// Called from both the foreground handler (here) and the top-level
  /// `notificationBackgroundHandler` — kept public so both isolates can
  /// share the same predicate without duplicating the rules.
  static bool shouldDeliver({
    required String? messageUserId,
    required String? currentUid,
  }) {
    if (messageUserId == null || messageUserId.isEmpty) return true;
    if (currentUid == null || currentUid.isEmpty) return false;
    return messageUserId == currentUid;
  }

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
    // via the local plugin after the uid check passes.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background/terminated messages: registered as a top-level handler
    // since FCM spawns a separate isolate that can't capture `this`. The
    // server now sends data-only pushes precisely so this handler can
    // filter by uid before deciding whether to display.
    FirebaseMessaging.onBackgroundMessage(notificationBackgroundHandler);

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

  /// Deletes the device's FCM token from `users/{userId}/fcmTokens`.
  ///
  /// Fetches the token directly from FCM rather than relying on any
  /// cached in-memory value — that cache is empty after an app restart,
  /// which is exactly when the cross-account leak surfaces (the user
  /// signs out before the app process holds a token reference).
  Future<void> removeTokenOnSignOut(String userId) async {
    if (userId.isEmpty) return;
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
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
    final messageUserId = message.data['userId'] as String?;
    final currentUid = _auth.currentUser?.uid;
    if (!shouldDeliver(messageUserId: messageUserId, currentUid: currentUid)) {
      log(
        'Dropping foreground push for foreign uid '
        '(message=$messageUserId, current=$currentUid)',
        name: 'NotificationService',
      );
      return;
    }

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
