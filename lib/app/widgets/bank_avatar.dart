import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class BankAvatar extends StatelessWidget {
  const BankAvatar({required this.bank, this.size = 40, super.key});

  final BankType bank;
  final double size;

  String get _iconPath {
    if (bank == BankType.nubank) {
      return Assets.lib.app.assets.images.banks.nubank.path;
    }
    return Assets.lib.app.assets.images.banks.bank.path;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipOval(
      child: Image.asset(
        _iconPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: size,
          height: size,
          color: colors.surfaceVariant,
          child: Icon(
            Icons.account_balance,
            size: size * 0.5,
            color: colors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
