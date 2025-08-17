/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

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

  /// Directory path: lib/app/assets/fonts
  $LibAppAssetsFontsGen get fonts => const $LibAppAssetsFontsGen();

  /// Directory path: lib/app/assets/i18n
  $LibAppAssetsI18nGen get i18n => const $LibAppAssetsI18nGen();

  /// Directory path: lib/app/assets/images
  $LibAppAssetsImagesGen get images => const $LibAppAssetsImagesGen();

  /// Directory path: lib/app/assets/svgs
  $LibAppAssetsSvgsGen get svgs => const $LibAppAssetsSvgsGen();
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

  /// File path: lib/app/assets/i18n/strings.i18n.json
  String get stringsI18n => 'lib/app/assets/i18n/strings.i18n.json';

  /// File path: lib/app/assets/i18n/strings_en.i18n.json
  String get stringsEnI18n => 'lib/app/assets/i18n/strings_en.i18n.json';

  /// File path: lib/app/assets/i18n/strings_pt.i18n.json
  String get stringsPtI18n => 'lib/app/assets/i18n/strings_pt.i18n.json';

  /// List of all assets
  List<String> get values => [stringsI18n, stringsEnI18n, stringsPtI18n];
}

class $LibAppAssetsImagesGen {
  const $LibAppAssetsImagesGen();

  /// Directory path: lib/app/assets/images/banks
  $LibAppAssetsImagesBanksGen get banks => const $LibAppAssetsImagesBanksGen();

  /// Directory path: lib/app/assets/images/flags
  $LibAppAssetsImagesFlagsGen get flags => const $LibAppAssetsImagesFlagsGen();
}

class $LibAppAssetsSvgsGen {
  const $LibAppAssetsSvgsGen();

  /// File path: lib/app/assets/svgs/calc.svg
  String get calc => 'lib/app/assets/svgs/calc.svg';

  /// File path: lib/app/assets/svgs/calendar.svg
  String get calendar => 'lib/app/assets/svgs/calendar.svg';

  /// File path: lib/app/assets/svgs/chart_pie.svg
  String get chartPie => 'lib/app/assets/svgs/chart_pie.svg';

  /// File path: lib/app/assets/svgs/clip.svg
  String get clip => 'lib/app/assets/svgs/clip.svg';

  /// File path: lib/app/assets/svgs/credit_card.svg
  String get creditCard => 'lib/app/assets/svgs/credit_card.svg';

  /// File path: lib/app/assets/svgs/filter.svg
  String get filter => 'lib/app/assets/svgs/filter.svg';

  /// File path: lib/app/assets/svgs/question.svg
  String get question => 'lib/app/assets/svgs/question.svg';

  /// File path: lib/app/assets/svgs/search.svg
  String get search => 'lib/app/assets/svgs/search.svg';

  /// File path: lib/app/assets/svgs/settings.svg
  String get settings => 'lib/app/assets/svgs/settings.svg';

  /// File path: lib/app/assets/svgs/simple_arrow.svg
  String get simpleArrow => 'lib/app/assets/svgs/simple_arrow.svg';

  /// File path: lib/app/assets/svgs/tag.svg
  String get tag => 'lib/app/assets/svgs/tag.svg';

  /// File path: lib/app/assets/svgs/triangle.svg
  String get triangle => 'lib/app/assets/svgs/triangle.svg';

  /// File path: lib/app/assets/svgs/wallet.svg
  String get wallet => 'lib/app/assets/svgs/wallet.svg';

  /// File path: lib/app/assets/svgs/x.svg
  String get x => 'lib/app/assets/svgs/x.svg';

  /// List of all assets
  List<String> get values => [
    calc,
    calendar,
    chartPie,
    clip,
    creditCard,
    filter,
    question,
    search,
    settings,
    simpleArrow,
    tag,
    triangle,
    wallet,
    x,
  ];
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
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

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
