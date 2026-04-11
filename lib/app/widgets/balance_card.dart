import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.label,
    required this.amount,
    this.icon,
    this.isIncome,
    super.key,
  });

  final String label;
  final double amount;
  final IconData? icon;
  final bool? isIncome;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: colors.onBackgroundLight),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.onBackgroundLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AmountText(
              amount: amount,
              fontSize: 22,
              isIncome: isIncome,
            ),
          ],
        ),
      ),
    );
  }
}
