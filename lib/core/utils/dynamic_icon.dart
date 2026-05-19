import 'package:flutter/material.dart';

/// Builds an [IconData] from a **runtime** code point — typically a
/// value the user picked in the category icon picker and the app
/// persisted to Firestore / Drift.
///
/// Flutter's icon tree-shaker requires `codePoint` to be a compile-
/// time constant so unused glyphs can be stripped from the final
/// `MaterialIcons` font. Apps with user-selectable icons can't honour
/// that constraint — the code point is only known at runtime. We
/// suppress the lint here so every call site doesn't have to repeat
/// the same `// ignore` comment, and we trade the size win for the
/// feature.
///
/// Pair with `flutter build --no-tree-shake-icons` so the production
/// build actually ships the glyphs.
IconData materialIconFor(int codePoint) {
  // ignore: non_const_argument_for_const_parameter
  return IconData(codePoint, fontFamily: 'MaterialIcons');
}
