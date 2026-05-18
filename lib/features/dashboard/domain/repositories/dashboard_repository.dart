import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';

/// Dashboard data contract — single method by design.
abstract class DashboardRepository {
  /// [fiftyThirtyTwentyTargets] feeds the 50/30/20 overview slice. Pass
  /// the user's saved targets to keep the dashboard card consistent with
  /// the detail page; defaults to [FiftyThirtyTwentyTargets.classic] so
  /// legacy callers (and unit tests) don't need to plumb it through.
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    required String userId,
    required DateTime month,
    bool forceRefresh = false,
    FiftyThirtyTwentyTargets fiftyThirtyTwentyTargets =
        FiftyThirtyTwentyTargets.classic,
  });
}
