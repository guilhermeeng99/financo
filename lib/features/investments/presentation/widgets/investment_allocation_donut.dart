import 'dart:math' as math;

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Donut chart of the current allocation. Each slice spans a
/// fraction of the circle equal to `slice.currentPercent`, drawn
/// with rounded caps and a small gap between slices so the
/// individual chunks read as distinct chips rather than a single
/// gradient ring.
///
/// The center carries the total invested amount + the section
/// label, replacing the inner target ring which read as noise on
/// the first pass.
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
    final colors = context.appColors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              slices: slices,
              trackColor: colors.surfaceVariant,
              gapColor: colors.background,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.investments.heroTitle,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.onBackgroundLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(totalInvested),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.trackColor,
    required this.gapColor,
  });

  final List<InvestmentClassSlice> slices;
  final Color trackColor;
  final Color gapColor;

  static const double _ringWidth = 22;

  /// Visual gap (in radians) between consecutive slices. Small but
  /// big enough to read at the default 220px diameter.
  static const double _gap = 0.04;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _ringWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track ring: full circle in a muted tone behind the slices so
    // partial allocations still suggest the full pie shape.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, trackPaint);

    // Visible slices = those with any current allocation. We compute
    // the gap budget from the visible slice count so a single slice
    // doesn't get clipped by phantom gaps.
    final visible = slices
        .where((s) => s.currentPercent > 0.0001)
        .toList();
    if (visible.isEmpty) return;

    final totalGap = visible.length == 1 ? 0.0 : _gap * visible.length;
    final available = 2 * math.pi - totalGap;
    var startAngle = -math.pi / 2 + (visible.length == 1 ? 0 : _gap / 2);

    for (final slice in visible) {
      final sweep = available * slice.currentPercent.clamp(0.0, 1.0);
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = Color(slice.color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices ||
      old.trackColor != trackColor ||
      old.gapColor != gapColor;
}
