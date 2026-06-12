import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Summary card at the top of the asset-class detail page: class icon,
/// current amount, actual vs target share, a progress bar toward the
/// class target, and the on/under/over-target delta. [actualPercent] and
/// [targetPercent] arrive pre-formatted (integer strings, no `%`).
class AssetClassHeroCard extends StatelessWidget {
  const AssetClassHeroCard({
    required this.slice,
    required this.tint,
    required this.actualPercent,
    required this.targetPercent,
    super.key,
  });

  final InvestmentClassSlice slice;
  final Color tint;
  final String actualPercent;
  final String targetPercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final deltaColor = slice.deltaAmount.abs() < 1
        ? colors.success
        : (slice.isUnderTarget ? colors.warning : colors.expense);
    final deltaLabel = slice.deltaAmount.abs() < 1
        ? t.investments.classRowOnTarget
        : (slice.isUnderTarget
            ? t.investments.classRowUnderTarget(
                amount: formatCurrency(slice.deltaAmount.abs()),
              )
            : t.investments.classRowOverTarget(
                amount: formatCurrency(slice.deltaAmount.abs()),
              ));
    final targetFraction = slice.targetPercent / 100;
    final progress = targetFraction <= 0
        ? slice.currentPercent.clamp(0.0, 1.0)
        : (slice.currentPercent / targetFraction).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    materialIconFor(slice.icon),
                    size: 22,
                    color: tint,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCurrency(slice.currentAmount),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.investments.classRowSubtitle(
                        actual: '$actualPercent%',
                        target: '$targetPercent%',
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(tint),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.investments.detailTargetAmount(
                  amount: formatCurrency(slice.targetAmount),
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackgroundLight,
                ),
              ),
              Text(
                deltaLabel,
                style: context.textTheme.bodySmall?.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
