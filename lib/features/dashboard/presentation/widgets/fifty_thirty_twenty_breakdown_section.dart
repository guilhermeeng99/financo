import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty_breakdown.dart';
import 'package:financo/features/dashboard/presentation/widgets/category_details_dialog.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Three stacked `DashboardSection`s — one per bucket (Needs / Wants /
/// Unclassified) — each listing the period's root categories sorted by
/// spend. Hides the unclassified section when empty so the page is
/// clean for users who have already classified everything.
class FiftyThirtyTwentyBreakdownSection extends StatelessWidget {
  const FiftyThirtyTwentyBreakdownSection({
    required this.breakdown,
    required this.overview,
    required this.periodTransactions,
    super.key,
  });

  final FiftyThirtyTwentyBreakdown breakdown;
  final FiftyThirtyTwentyOverview overview;

  /// Period transactions feed the per-row drill-down dialog so it can
  /// list subcategory contributions without an extra fetch.
  final List<TransactionEntity> periodTransactions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Total period expenses used for the % column inside the drill-down
    // dialog (same denominator the dashboard uses).
    final totalExpenses = overview.needsSpent +
        overview.wantsSpent +
        overview.unclassifiedSpent;
    final sections = <Widget>[
      _BucketSection(
        label: t.fiftyThirtyTwenty.needsLabel,
        accent: colors.primary,
        rows: breakdown.needs,
        totalSpent: overview.needsSpent,
        targetAmount: overview.needsTarget,
        periodTransactions: periodTransactions,
        totalExpenses: totalExpenses,
      ),
      _BucketSection(
        label: t.fiftyThirtyTwenty.wantsLabel,
        accent: colors.warning,
        rows: breakdown.wants,
        totalSpent: overview.wantsSpent,
        targetAmount: overview.wantsTarget,
        periodTransactions: periodTransactions,
        totalExpenses: totalExpenses,
      ),
      if (breakdown.unclassified.isNotEmpty)
        _BucketSection(
          label: t.fiftyThirtyTwenty.unclassifiedLabel,
          accent: colors.onBackgroundLight,
          rows: breakdown.unclassified,
          totalSpent: overview.unclassifiedSpent,
          targetAmount: null,
          periodTransactions: periodTransactions,
          totalExpenses: totalExpenses,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          sections[i],
        ],
      ],
    );
  }
}

class _BucketSection extends StatelessWidget {
  const _BucketSection({
    required this.label,
    required this.accent,
    required this.rows,
    required this.totalSpent,
    required this.targetAmount,
    required this.periodTransactions,
    required this.totalExpenses,
  });

  final String label;
  final Color accent;
  final List<FiftyThirtyTwentyBreakdownRow> rows;
  final double totalSpent;
  final double? targetAmount;
  final List<TransactionEntity> periodTransactions;
  final double totalExpenses;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DashboardSection(
      label: label,
      accent: accent,
      count: rows.length,
      trailing: Text(
        targetAmount == null
            ? formatCurrency(totalSpent)
            : t.fiftyThirtyTwenty.spentOfTarget(
                spent: formatCurrency(totalSpent),
                target: formatCurrency(targetAmount!),
              ),
        style: context.textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: rows.isEmpty
          ? _EmptyHint(message: t.fiftyThirtyTwenty.bucketEmpty)
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        height: 0.5,
                        color: colors.surfaceVariant,
                      ),
                    ),
                  _CategoryRow(
                    row: rows[i],
                    totalSpent: totalSpent,
                    periodTransactions: periodTransactions,
                    totalExpenses: totalExpenses,
                  ),
                ],
              ],
            ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.row,
    required this.totalSpent,
    required this.periodTransactions,
    required this.totalExpenses,
  });

  final FiftyThirtyTwentyBreakdownRow row;
  final double totalSpent;
  final List<TransactionEntity> periodTransactions;
  final double totalExpenses;

  void _openDrillDown(BuildContext context) {
    showCategoryDetailsDialog(
      context: context,
      parent: CategoryAmount(
        categoryId: row.categoryId,
        categoryName: row.categoryName,
        categoryColor: row.categoryColor,
        amount: row.amount,
      ),
      totalExpenses: totalExpenses,
      periodTransactions: periodTransactions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(row.categoryColor);
    final share = totalSpent == 0 ? 0.0 : row.amount / totalSpent;
    return InkWell(
      onTap: () => _openDrillDown(context),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                materialIconFor(row.categoryIcon),
                size: 16,
                color: tint,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  row.categoryName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: share.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(tint),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatCurrency(row.amount),
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.circleInfo,
            size: 12,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
