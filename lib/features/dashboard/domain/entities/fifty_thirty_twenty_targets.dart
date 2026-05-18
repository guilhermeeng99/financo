import 'package:equatable/equatable.dart';

/// User-configurable target split for the 50/30/20 rule. Defaults to the
/// classic 50/30/20 (the spec name); persisted on the user document so it
/// follows the user across devices.
///
/// Stored as three doubles in `[0, 1]` that **must sum to 1.0** (tolerance
/// `kSumTolerance`). The constructor itself does not enforce the
/// invariant — call [isValid] before persisting — because the editor
/// passes drafts mid-input that may not yet sum to 1.
class FiftyThirtyTwentyTargets extends Equatable {
  const FiftyThirtyTwentyTargets({
    required this.needs,
    required this.wants,
    required this.savings,
  });

  /// Classic 50/30/20 split. Surfaced for users who haven't customised
  /// their targets and as the "reset" button on the editor.
  static const FiftyThirtyTwentyTargets classic = FiftyThirtyTwentyTargets(
    needs: 0.5,
    wants: 0.3,
    savings: 0.2,
  );

  /// Doubles are messy across (de)serialisation hops — allow a one-cent
  /// drift on the sum check rather than rejecting valid input.
  static const double kSumTolerance = 0.001;

  /// Each component is a fraction of income (e.g. `0.5` = 50%).
  final double needs;
  final double wants;
  final double savings;

  /// True when all three values are non-negative and their sum is within
  /// [kSumTolerance] of 1.0. Editor consumers should disable submit
  /// until this returns true.
  bool get isValid {
    if (needs < 0 || wants < 0 || savings < 0) return false;
    final sum = needs + wants + savings;
    return (sum - 1.0).abs() <= kSumTolerance;
  }

  FiftyThirtyTwentyTargets copyWith({
    double? needs,
    double? wants,
    double? savings,
  }) {
    return FiftyThirtyTwentyTargets(
      needs: needs ?? this.needs,
      wants: wants ?? this.wants,
      savings: savings ?? this.savings,
    );
  }

  @override
  List<Object?> get props => [needs, wants, savings];
}
