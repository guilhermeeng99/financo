import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/presentation/asset_visuals.dart';
import 'package:financo/features/investing/presentation/pages/assets_page.dart'
    show assetKindLabel;
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Donut + legend of portfolio value split by [AssetKind]. Slices/legend rows
/// are sorted by value (biggest first); zero-value classes are dropped.
class OverviewAllocationByClass extends StatelessWidget {
  const OverviewAllocationByClass({required this.byClass, super.key});

  final Map<AssetKind, Money> byClass;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final entries =
        byClass.entries.where((e) => e.value.minorUnits > 0).toList()
          ..sort((a, b) => b.value.minorUnits.compareTo(a.value.minorUnits));
    if (entries.isEmpty) return const SizedBox.shrink();
    final totalMinor = entries.fold<int>(0, (s, e) => s + e.value.minorUnits);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.investing.overview.allocationByClass,
            style: context.textTheme.titleSmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 42,
                    sections: [
                      for (final e in entries)
                        PieChartSectionData(
                          value: e.value.minorUnits.toDouble(),
                          color: assetKindColor(e.key),
                          radius: 22,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final e in entries)
                      _LegendRow(
                        color: assetKindColor(e.key),
                        label: assetKindLabel(e.key),
                        fraction: totalMinor == 0
                            ? 0
                            : e.value.minorUnits / totalMinor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.fraction,
  });

  final Color color;
  final String label;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          Text(
            '${(fraction * 100).toStringAsFixed(0)}%',
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
