import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Circular bank avatar: a coloured disc filled with the bank's brand
/// color and either its abbreviation (regular banks) or a generic bank
/// icon (`BankType.others`). Foreground color is picked from background
/// luminance so light brands (BB yellow, Neon, XP) get black text and
/// dark brands (Itaú, Bradesco, C6) get white text.
class BankAvatar extends StatelessWidget {
  const BankAvatar({required this.bank, this.size = 40, super.key});

  final BankType bank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = BankBrand.of(bank);
    final background = Color(brand.color);
    final foreground = background.computeLuminance() > 0.55
        ? Colors.black
        : Colors.white;
    final isOthers = bank == BankType.others;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: isOthers
          ? FaIcon(
              FontAwesomeIcons.buildingColumns,
              size: size * 0.42,
              color: foreground,
            )
          : Text(
              brand.abbreviation,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: _fontSize(brand.abbreviation, size),
              ),
            ),
    );
  }

  /// Scale the abbreviation down as it gets longer so 4-letter strings
  /// like "Itaú" / "Will" still fit a 40px circle without clipping.
  double _fontSize(String abbreviation, double size) {
    final length = abbreviation.length;
    if (length <= 2) return size * 0.42;
    if (length == 3) return size * 0.32;
    return size * 0.26;
  }
}
