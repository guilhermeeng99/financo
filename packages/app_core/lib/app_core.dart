import 'dart:io';

import 'package:app_widgets/app_widgets.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:logger/logger.dart';

export 'package:flutter/material.dart';
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:flutter_modular/flutter_modular.dart';
export 'package:get/get.dart'
    hide CustomTransition, RouterOutlet, RouterOutletState, Translations;

export 'src/index.dart';

bool get isMobile => Platform.isAndroid || Platform.isIOS;

bool get isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

BuildContext get currentContext =>
    Modular.routerDelegate.navigatorKey.currentContext!;

$LibAppAssetsSvgsGen get svgs => Assets.lib.app.assets.svgs;

final Logger logger = Logger();
