import 'package:financo/app/theme/app_typography.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Displays a formatted currency value with automatic coloring:
/// - Negative values → red (expense color) with "−" prefix
/// - Zero or positive → green (income color)
///
/// The [amount] must be a signed double. Use negative values to
/// represent expenses or debts (e.g. −10.0).
class AmountText extends StatelessWidget {
  const AmountText({
    required this.amount,
    this.fontSize = 18,
    super.key,
  });

  final double amount;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isNegative = amount < 0;
    final color = isNegative ? colors.expense : colors.income;
    final text = isNegative
        ? '-${formatCurrency(amount.abs())}'
        : formatCurrency(amount);

    return Text(
      text,
      style: AppTypography.amount(color: color, fontSize: fontSize),
    );
  }
}
