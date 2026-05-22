import 'package:financo/app/app_widget.dart';
import 'package:financo/app/di/injection_container.dart';
import 'package:financo/core/notifications/notification_service.dart';
import 'package:financo/firebase_options.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobile is portrait-only — the layouts are tuned for a single column and
  // landscape would stretch them awkwardly. No-op on web (orientation is
  // driven by the browser window there).
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Pre-resolve to the device locale so the very first frame already
  // renders translated text. AppLocaleCubit (built inside initDependencies)
  // overrides this with the user's saved choice if any.
  await LocaleSettings.useDeviceLocale();
  await initDependencies();

  // Push notifications are not supported on web in this app.
  if (!kIsWeb) {
    await sl<NotificationService>().init();
  }

  runApp(TranslationProvider(child: const FinancoApp()));
}
