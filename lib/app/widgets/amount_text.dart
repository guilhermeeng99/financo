import 'package:financo/app/theme/app_typography.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class AmountText extends StatelessWidget {
  const AmountText({
    required this.amount,
    this.fontSize = 18,
    this.showSign = false,
    this.isIncome,
    super.key,
  });

  final double amount;
  final double fontSize;
  final bool showSign;
  final bool? isIncome;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final positive = isIncome ?? amount >= 0;
    final color = positive ? colors.income : colors.expense;
    final text = showSign
        ? formatCurrencySigned(amount)
        : formatCurrency(amount.abs());

    return Text(
      text,
      style: AppTypography.amount(color: color, fontSize: fontSize),
    );
  }
}
