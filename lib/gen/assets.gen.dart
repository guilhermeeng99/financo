// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $LibGen {
  const $LibGen();

  /// Directory path: lib/app
  $LibAppGen get app => const $LibAppGen();
}

class $LibAppGen {
  const $LibAppGen();

  /// Directory path: lib/app/assets
  $LibAppAssetsGen get assets => const $LibAppAssetsGen();
}

class $LibAppAssetsGen {
  const $LibAppAssetsGen();

  /// Directory path: lib/app/assets/excels
  $LibAppAssetsExcelsGen get excels => const $LibAppAssetsExcelsGen();

  /// Directory path: lib/app/assets/fonts
  $LibAppAssetsFontsGen get fonts => const $LibAppAssetsFontsGen();

  /// Directory path: lib/app/assets/i18n
  $LibAppAssetsI18nGen get i18n => const $LibAppAssetsI18nGen();

  /// Directory path: lib/app/assets/images
  $LibAppAssetsImagesGen get images => const $LibAppAssetsImagesGen();
}

class $LibAppAssetsExcelsGen {
  const $LibAppAssetsExcelsGen();

  /// File path: lib/app/assets/excels/default_categories_import_model.xlsx
  String get defaultCategoriesImportModel =>
      'lib/app/assets/excels/default_categories_import_model.xlsx';

  /// File path: lib/app/assets/excels/default_transactions_import_model.xlsx
  String get defaultTransactionsImportModel =>
      'lib/app/assets/excels/default_transactions_import_model.xlsx';

  /// List of all assets
  List<String> get values => [
    defaultCategoriesImportModel,
    defaultTransactionsImportModel,
  ];
}

class $LibAppAssetsFontsGen {
  const $LibAppAssetsFontsGen();

  /// File path: lib/app/assets/fonts/Inter_Bold.ttf
  String get interBold => 'lib/app/assets/fonts/Inter_Bold.ttf';

  /// File path: lib/app/assets/fonts/Inter_Regular.ttf
  String get interRegular => 'lib/app/assets/fonts/Inter_Regular.ttf';

  /// List of all assets
  List<String> get values => [interBold, interRegular];
}

class $LibAppAssetsI18nGen {
  const $LibAppAssetsI18nGen();

  /// File path: lib/app/assets/i18n/strings_en.i18n.json
  String get stringsEnI18n => 'lib/app/assets/i18n/strings_en.i18n.json';

  /// File path: lib/app/assets/i18n/strings_pt.i18n.json
  String get stringsPtI18n => 'lib/app/assets/i18n/strings_pt.i18n.json';

  /// List of all assets
  List<String> get values => [stringsEnI18n, stringsPtI18n];
}

class $LibAppAssetsImagesGen {
  const $LibAppAssetsImagesGen();

  /// Directory path: lib/app/assets/images/banks
  $LibAppAssetsImagesBanksGen get banks => const $LibAppAssetsImagesBanksGen();

  /// Directory path: lib/app/assets/images/flags
  $LibAppAssetsImagesFlagsGen get flags => const $LibAppAssetsImagesFlagsGen();
}

class $LibAppAssetsImagesBanksGen {
  const $LibAppAssetsImagesBanksGen();

  /// File path: lib/app/assets/images/banks/bank.webp
  AssetGenImage get bank =>
      const AssetGenImage('lib/app/assets/images/banks/bank.webp');

  /// File path: lib/app/assets/images/banks/nubank.webp
  AssetGenImage get nubank =>
      const AssetGenImage('lib/app/assets/images/banks/nubank.webp');

  /// List of all assets
  List<AssetGenImage> get values => [bank, nubank];
}

class $LibAppAssetsImagesFlagsGen {
  const $LibAppAssetsImagesFlagsGen();

  /// File path: lib/app/assets/images/flags/brazil.webp
  AssetGenImage get brazil =>
      const AssetGenImage('lib/app/assets/images/flags/brazil.webp');

  /// File path: lib/app/assets/images/flags/united_kingdom.webp
  AssetGenImage get unitedKingdom =>
      const AssetGenImage('lib/app/assets/images/flags/united_kingdom.webp');

  /// File path: lib/app/assets/images/flags/united_states.webp
  AssetGenImage get unitedStates =>
      const AssetGenImage('lib/app/assets/images/flags/united_states.webp');

  /// List of all assets
  List<AssetGenImage> get values => [brazil, unitedKingdom, unitedStates];
}

class Assets {
  const Assets._();

  static const $LibGen lib = $LibGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
