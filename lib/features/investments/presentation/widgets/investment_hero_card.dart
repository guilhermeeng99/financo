import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class InvestmentHeroCard extends StatelessWidget {
  const InvestmentHeroCard({
    required this.totalInvested,
    required this.totalAllocated,
    required this.totalPending,
    super.key,
  });

  final double totalInvested;
  final double totalAllocated;
  final double totalPending;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasInvestments = totalInvested > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.investments.heroTitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(totalInvested),
            style: context.textTheme.headlineMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasInvestments) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat(
                  label: t.investments.heroAllocated,
                  value: totalAllocated,
                  color: colors.success,
                ),
                const SizedBox(width: 20),
                _Stat(
                  label: t.investments.heroPending,
                  value: totalPending,
                  color: totalPending > 0
                      ? colors.warning
                      : colors.onBackgroundLight,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatCurrency(value),
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
