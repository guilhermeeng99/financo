import 'package:flutter/material.dart';

/// Notification channel + visual identity used by both
/// `NotificationService` (foreground isolate) and
/// `notificationBackgroundHandler` (FCM background isolate).
///
/// Kept in a top-level file so the constants survive isolate boundaries
/// without an import cycle. Drifting any value here from the AndroidManifest
/// meta-data (`default_notification_icon`, `default_notification_color`,
/// `default_notification_channel_id`) breaks the visual parity between
/// cold-start FCM notifications and warm in-app foreground deliveries.
class NotificationConstants {
  const NotificationConstants._();

  static const channelId = 'bills_due';
  static const channelName = 'Bill reminders';
  static const channelDescription = 'Alerts when a bill is due or overdue.';

  /// Drawable resource name (no `@drawable/` prefix). Must match
  /// `ic_notification.xml` and the AndroidManifest meta-data so cold
  /// FCM and warm foreground deliveries render the same icon.
  static const smallIcon = 'ic_notification';

  /// Tint applied to [smallIcon]. Matches the launcher background and
  /// the `notification_color` resource.
  static const accent = Color(0xFF6366F1);
}
