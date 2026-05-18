import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_history_entry.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Compact stacked-bar history rendered as a row of columns — one per
/// month. Each column shows three stacked segments (needs / wants /
/// savings) sized by the period's actual percentages, capped at 100%
/// so an over-spent month tops out at the full column rather than
/// blowing through it.
///
/// Intentionally hand-painted with `Container`s and `Expanded` flex —
/// the project doesn't pull in a chart library and a 3-bar widget
/// doesn't justify one.
class FiftyThirtyTwentyHistoryChart extends StatelessWidget {
  const FiftyThirtyTwentyHistoryChart({required this.history, super.key});

  final List<FiftyThirtyTwentyHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (history.isEmpty) {
      return DashboardSection(
        label: t.fiftyThirtyTwenty.historyTitle,
        accent: colors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.fiftyThirtyTwenty.historyEmpty,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
        ),
      );
    }
    return DashboardSection(
      label: t.fiftyThirtyTwenty.historyTitle,
      accent: colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < history.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: _MonthColumn(entry: history[i])),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

/// Which segment the user tapped on a given month. `null` means "no
/// segment open" — the column renders plain.
enum _BucketKind { needs, wants, savings }

class _MonthColumn extends StatefulWidget {
  const _MonthColumn({required this.entry});

  final FiftyThirtyTwentyHistoryEntry entry;

  @override
  State<_MonthColumn> createState() => _MonthColumnState();
}

class _MonthColumnState extends State<_MonthColumn> {
  _BucketKind? _selected;

  void _toggle(_BucketKind kind) {
    setState(() => _selected = _selected == kind ? null : kind);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ov = widget.entry.overview;
    // Cap each component visually at 100% so an over-spent month doesn't
    // visually escape the column. The card and breakdown carry the raw
    // numbers — this is just a trend at-a-glance.
    // Each component clamped to its own [0,1] window first, then the
    // *sum* is renormalised when it overshoots — without this the
    // segments visually overflow the column (e.g. needs 1.0 + wants
    // 0.5 + savings 0.5 = 2.0 → twice the column height).
    final rawNeeds = ov.needsPercent.clamp(0.0, 1.0);
    final rawWants = ov.wantsPercent.clamp(0.0, 1.0);
    final rawSavings = ov.savingsPercent.clamp(0.0, 1.0);
    final rawSum = rawNeeds + rawWants + rawSavings;
    final scale = rawSum > 1.0 ? 1.0 / rawSum : 1.0;
    final needs = rawNeeds * scale;
    final wants = rawWants * scale;
    final savings = rawSavings * scale;
    // Total height must visually fit one "month of income" — show the
    // three segments scaled by their respective percent against income,
    // capped at 1.0. Trailing empty space reflects "uncommitted income".
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxH = constraints.maxHeight;
              // The bars sum to the user's spent + saved share of income;
              // anything left over is empty space at the top. Empty
              // months render as a faint placeholder.
              final hasData = needs + wants + savings > 0;
              if (!hasData) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                        bottom: Radius.circular(2),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: colors.surfaceVariant,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _Segment(
                              height: needs * maxH,
                              color: colors.primary,
                              onTap: () => _toggle(_BucketKind.needs),
                            ),
                            _Segment(
                              height: wants * maxH,
                              color: colors.warning,
                              onTap: () => _toggle(_BucketKind.wants),
                            ),
                            _Segment(
                              height: savings * maxH,
                              color: colors.income,
                              onTap: () => _toggle(_BucketKind.savings),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selected != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _ValuePill(
                        kind: _selected!,
                        overview: ov,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _shortMonthLabel(widget.entry.month),
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _shortMonthLabel(DateTime month) {
    // Reuses the project's locale-aware month formatter, then trims to
    // the first 3 chars for a compact column label.
    final raw = formatMonthYear(month);
    final spaceIdx = raw.indexOf(' ');
    final monthName = spaceIdx < 0 ? raw : raw.substring(0, spaceIdx);
    final clean = monthName.replaceAll(RegExp('[.,]'), '');
    return clean.length <= 3
        ? clean.toUpperCase()
        : clean.substring(0, 3).toUpperCase();
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.height,
    required this.color,
    required this.onTap,
  });

  final double height;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (height <= 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ColoredBox(color: color),
      ),
    );
  }
}

/// Small inline pill anchored to the top of the column that surfaces
/// the bucket's actual amount + percent for that month when the user
/// taps a segment. Tapping the same segment again dismisses.
class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.kind, required this.overview});

  final _BucketKind kind;
  final FiftyThirtyTwentyOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (label, amount, percent, tint) = switch (kind) {
      _BucketKind.needs => (
        t.fiftyThirtyTwenty.needsLabel,
        overview.needsSpent,
        overview.needsPercent,
        colors.primary,
      ),
      _BucketKind.wants => (
        t.fiftyThirtyTwenty.wantsLabel,
        overview.wantsSpent,
        overview.wantsPercent,
        colors.warning,
      ),
      _BucketKind.savings => (
        t.fiftyThirtyTwenty.savingsLabel,
        overview.savingsAmount,
        overview.savingsPercent,
        colors.income,
      ),
    };
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tint.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
                height: 1,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(amount),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${(percent * 100).round()}%',
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackgroundLight,
                fontWeight: FontWeight.w600,
                height: 1,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendChip(
          label: t.fiftyThirtyTwenty.needsLabel,
          color: colors.primary,
        ),
        _LegendChip(
          label: t.fiftyThirtyTwenty.wantsLabel,
          color: colors.warning,
        ),
        _LegendChip(
          label: t.fiftyThirtyTwenty.savingsLabel,
          color: colors.income,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
