import 'dart:developer';

import 'package:financo/core/notifications/notification_constants.dart';
import 'package:financo/core/notifications/notification_service.dart';
import 'package:financo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level FCM background handler. Must be top-level (or static) so
/// `FirebaseMessaging.onBackgroundMessage` can register it across the
/// isolate boundary FCM uses for background delivery. Lives in its own
/// file to keep `NotificationService` purely class-based — mixing a
/// top-level entry-point in the same file as the service confuses the
/// `unreachable_from_main` lint into flagging the class members as dead.
///
/// Reuses [NotificationService.shouldDeliver] for the uid filter, then
/// renders via a freshly initialized `flutter_local_notifications` plugin
/// in this isolate. Reachable cold-start paths: app killed by OS, device
/// booted, app updated — each spawns a new Dart isolate with no DI graph,
/// hence the manual Firebase + plugin init below.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(RemoteMessage message) async {
  if (NotificationService.isLegacyBillsPush(message.data)) {
    log(
      'Dropping legacy Bills background push',
      name: 'NotificationService',
    );
    return;
  }

  // Idempotent: returns the existing app if one is already initialized
  // (foreground isolate path) and otherwise bootstraps one here.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messageUserId = message.data['userId'] as String?;
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (!NotificationService.shouldDeliver(
    messageUserId: messageUserId,
    currentUid: currentUid,
  )) {
    log(
      'Dropping background push for foreign uid '
      '(message=$messageUserId, current=$currentUid)',
      name: 'NotificationService',
    );
    return;
  }

  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] as String?;
  final body = notification?.body ?? message.data['body'] as String?;
  if (title == null && body == null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings(NotificationConstants.smallIcon),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await plugin.show(
    id: message.messageId.hashCode,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        channelDescription: NotificationConstants.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: NotificationConstants.smallIcon,
        color: NotificationConstants.accent,
        colorized: true,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: message.data['route'] as String?,
  );
}
