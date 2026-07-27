import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// The invested / unrealized-P&L / day-change row shown under the hero. P&L and
/// day-change tint green (gain) or red (loss).
class OverviewMetrics extends StatelessWidget {
  const OverviewMetrics({required this.portfolio, super.key});

  final PortfolioValuation portfolio;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricTile(
              label: t.investing.overview.invested,
              value: formatMoney(portfolio.totalInvestedBase),
            ),
          ),
          _divider(colors.surfaceVariant),
          Expanded(
            child: _MetricTile(
              label: t.investing.overview.unrealizedPl,
              value: signedMoney(portfolio.totalUnrealizedPL),
              valueColor: portfolio.totalUnrealizedPL.isNegative
                  ? colors.expense
                  : colors.income,
            ),
          ),
          _divider(colors.surfaceVariant),
          Expanded(
            child: _MetricTile(
              label: t.investing.overview.dayChange,
              value: signedMoney(portfolio.totalDayChangeBase),
              valueColor: portfolio.totalDayChangeBase.isNegative
                  ? colors.expense
                  : colors.income,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) => Container(
    width: 1,
    height: 36,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: color,
  );
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            color: valueColor ?? colors.onBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
