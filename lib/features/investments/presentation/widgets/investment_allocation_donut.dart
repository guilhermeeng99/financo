import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/features/investments/presentation/widgets/allocation_donut.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Portfolio allocation donut: one slice per class, each spanning a
/// fraction of the circle equal to `slice.currentPercent`. The centre
/// carries the total invested amount. Thin wrapper over the reusable
/// [AllocationDonut] — the class-detail page renders its subclass donut
/// from the same primitive.
class InvestmentAllocationDonut extends StatelessWidget {
  const InvestmentAllocationDonut({
    required this.slices,
    required this.totalInvested,
    this.size = 220,
    super.key,
  });

  final List<InvestmentClassSlice> slices;
  final double totalInvested;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AllocationDonut(
      slices: [
        for (final slice in slices)
          DonutSlice(color: Color(slice.color), fraction: slice.currentPercent),
      ],
      centerLabel: t.investments.heroTitle,
      centerValue: formatCurrency(totalInvested),
      size: size,
    );
  }
}
