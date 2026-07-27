import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Donut of the current allocation by class: one colored arc per class sized by
/// its market value, the unallocated remainder as a muted slice, and the
/// invested net worth in the center. Ported from Investanco's
/// `AllocationClassDonut`. See `docs/specs/allocation.md`.
class AllocationClassDonut extends StatelessWidget {
  const AllocationClassDonut({required this.overview, super.key});

  final AllocationOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sections = <PieChartSectionData>[
      for (final slice in overview.slices)
        if (slice.currentValue.minorUnits > 0)
          PieChartSectionData(
            value: slice.currentValue.minorUnits.toDouble(),
            color: Color(slice.color),
            radius: 18,
            showTitle: false,
          ),
    ];
    if (overview.unallocatedValue.minorUnits > 0) {
      sections.add(
        PieChartSectionData(
          value: overview.unallocatedValue.minorUnits.toDouble(),
          color: colors.surfaceVariant,
          radius: 18,
          showTitle: false,
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (sections.isNotEmpty)
            PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 78,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.investing.allocation.investedNetWorth,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.onBackgroundLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatMoney(overview.totalValue),
                style: context.textTheme.headlineSmall?.copyWith(
                  color: colors.onBackground,
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
