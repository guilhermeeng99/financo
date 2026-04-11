import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, DashboardSummary>> call({
    required String userId,
    required DateTime month,
    bool forceRefresh = false,
  }) => _repository.getDashboardSummary(
    userId: userId,
    month: month,
    forceRefresh: forceRefresh,
  );
}
