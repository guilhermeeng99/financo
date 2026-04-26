import 'package:financo/app/app_widget.dart';
import 'package:financo/app/di/injection_container.dart';
import 'package:financo/core/notifications/notification_service.dart';
import 'package:financo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initDependencies();

  // Push notifications are not supported on web in this app.
  if (!kIsWeb) {
    await sl<NotificationService>().init();
  }

  runApp(const FinancoApp());
}
