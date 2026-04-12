import 'dart:developer';

import 'package:financo/app/app_widget.dart';
import 'package:financo/app/di/injection_container.dart';
import 'package:financo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  const googleClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  log(
    'GEMINI_API_KEY set: ${geminiKey.isNotEmpty} '
    '| GOOGLE_WEB_CLIENT_ID set: ${googleClientId.isNotEmpty}',
    name: 'main',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initDependencies();
  runApp(const FinancoApp());
}
