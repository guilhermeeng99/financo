import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';

/// Dashboard data contract — single method by design.
abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    required String userId,
    required DateTime month,
    bool forceRefresh = false,
  });
}
