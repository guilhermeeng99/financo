import 'dart:io';

import 'package:financo/gen/assets.gen.dart';

export 'package:flutter/material.dart';
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:flutter_modular/flutter_modular.dart';

export 'src/index.dart';

bool get isMobile => Platform.isAndroid || Platform.isIOS;

bool get isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

$LibAppAssetsSvgsGen get svgs => Assets.lib.app.assets.svgs;
