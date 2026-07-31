import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter/material.dart';

/// Stable colour per asset class, used by position avatars, the allocation-by-
/// class donut and its legend. Ported from Investanco's `asset_visuals`.
Color assetKindColor(AssetKind kind) => switch (kind) {
  AssetKind.stockBr => const Color(0xFF1565C0),
  AssetKind.fiiBr => const Color(0xFF6A1B9A),
  AssetKind.etfBr => const Color(0xFF00838F),
  AssetKind.bdrBr => const Color(0xFF4527A0),
  AssetKind.stockUs => const Color(0xFF2E7D32),
  AssetKind.etfUs => const Color(0xFF558B2F),
  AssetKind.crypto => const Color(0xFFEF6C00),
  AssetKind.treasury => const Color(0xFF00695C),
  AssetKind.fixedIncome => const Color(0xFF283593),
  AssetKind.fund => const Color(0xFFAD1457),
  AssetKind.cash => const Color(0xFF546E7A),
};

/// First letters of a [ticker] for avatar display: up to 4 upper-cased chars.
/// Example: `tickerInitials('petr4') // 'PETR'`.
String tickerInitials(String ticker) {
  final clean = ticker.trim().toUpperCase();
  return clean.length <= 4 ? clean : clean.substring(0, 4);
}

/// Circular avatar for a position: a disc filled with the asset class colour
/// and the ticker's initials, with the foreground picked for contrast.
class AssetAvatar extends StatelessWidget {
  const AssetAvatar({
    required this.kind,
    required this.ticker,
    this.size = 40,
    super.key,
  });

  final AssetKind kind;
  final String ticker;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = assetKindColor(kind);
    final foreground = foregroundOn(background);
    final initials = tickerInitials(ticker);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: initials.length <= 2 ? size * 0.34 : size * 0.26,
        ),
      ),
    );
  }
}
