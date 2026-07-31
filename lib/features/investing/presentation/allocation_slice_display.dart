import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/widgets.dart';

/// Presentation view over an [AllocationClassSlice]: the four derived values
/// the allocation list and the class-detail hero both render.
///
/// Both screens computed these inline, identically — same threshold, same
/// colour ternary, same label ternary, same progress formula — and the two
/// copies were introduced in the same commit, so they were already one edit
/// away from disagreeing about what "on target" means.
///
/// Example:
/// ```dart
/// final display = AllocationSliceDisplay(slice, context.appColors);
/// Text(display.deltaLabel, style: TextStyle(color: display.deltaColor));
/// LinearProgressIndicator(value: display.progress);
/// ```
extension AllocationSliceDisplay on AllocationClassSlice {
  /// Whether the gap to target is small enough to call it balanced. Uses the
  /// same minor-unit threshold the rebalance suggestions use, so a slice never
  /// reads "on target" while still generating a rebalance action.
  bool get isOnTarget =>
      delta.minorUnits.abs() < AllocationService.rebalanceThresholdMinor;

  /// Current share as a whole percent, no suffix: `0.451` → `45`.
  String get actualPercentLabel => percentWhole(currentPercent);

  /// Target share as a whole percent, no suffix.
  String get targetPercentLabel => percentWhole(targetPercent);

  /// Muted when balanced; income green when under target (buy to close the
  /// gap), expense red when over.
  Color deltaColor(AppColorsData colors) => isOnTarget
      ? colors.onBackgroundLight
      : (isUnderTarget ? colors.income : colors.expense);

  /// "Na meta" / "Faltam R$X" / "R$X acima", already localized.
  String get deltaLabel => isOnTarget
      ? t.investing.allocation.onTarget
      : (isUnderTarget
            ? t.investing.allocation.below(amount: absMoney(delta))
            : t.investing.allocation.above(amount: absMoney(delta)));

  /// Progress toward the target, clamped to 0–1 for a progress bar.
  ///
  /// With no target set there is nothing to progress *towards*, so the bar
  /// falls back to the slice's share of the portfolio — which is what the user
  /// is actually looking at in that state.
  double get progress => targetPercent <= 0
      ? currentPercent.clamp(0.0, 1.0)
      : (currentPercent / targetPercent).clamp(0.0, 1.0);
}
