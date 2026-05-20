import 'dart:math' as math;

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// One arc of an [AllocationDonut]. [fraction] is the share of the full
/// circle in `[0, 1]`; the slices need not sum to 1 — any remainder is
/// left as the muted track ring (so partial allocations still read as a
/// pie shape).
class DonutSlice {
  const DonutSlice({required this.color, required this.fraction});

  final Color color;
  final double fraction;
}

/// Reusable donut chart: coloured arcs over a muted track ring, with a
/// label + value stacked in the centre. Used both for the portfolio's
/// class allocation (`InvestmentAllocationDonut`) and the per-class
/// subclass allocation on the class detail page — same visual language
/// so the two screens read as a set.
class AllocationDonut extends StatelessWidget {
  const AllocationDonut({
    required this.slices,
    required this.centerLabel,
    required this.centerValue,
    this.size = 220,
    super.key,
  });

  final List<DonutSlice> slices;
  final String centerLabel;
  final String centerValue;
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
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.onBackgroundLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                centerValue,
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
  _DonutPainter({required this.slices, required this.trackColor});

  final List<DonutSlice> slices;
  final Color trackColor;

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

    // Visible slices = those with any allocation. We compute the gap
    // budget from the visible slice count so a single slice doesn't get
    // clipped by phantom gaps.
    final visible = slices.where((s) => s.fraction > 0.0001).toList();
    if (visible.isEmpty) return;

    final totalGap = visible.length == 1 ? 0.0 : _gap * visible.length;
    final available = 2 * math.pi - totalGap;
    var startAngle = -math.pi / 2 + (visible.length == 1 ? 0 : _gap / 2);

    for (final slice in visible) {
      final sweep = available * slice.fraction.clamp(0.0, 1.0);
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices || old.trackColor != trackColor;
}
