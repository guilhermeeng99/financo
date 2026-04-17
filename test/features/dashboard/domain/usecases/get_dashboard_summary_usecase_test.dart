import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/dashboard_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockDashboardRepository mockRepository;
  late GetDashboardSummaryUseCase useCase;

  setUpAll(registerDashboardFallbackValues);

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardSummaryUseCase(mockRepository);
  });

  const userId = 'user-1';
  final month = DateTime(2024, 6);

  test('should delegate to repository and return summary', () async {
    final summary = DashboardFactory.summary();
    when(
      () => mockRepository.getDashboardSummary(
        userId: any(named: 'userId'),
        month: any(named: 'month'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, DashboardSummary>(summary),
    );

    final result = await useCase(userId: userId, month: month);

    expect(result, Right<Failure, DashboardSummary>(summary));
    verify(
      () => mockRepository.getDashboardSummary(
        userId: userId,
        month: month,
      ),
    ).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.getDashboardSummary(
        userId: any(named: 'userId'),
        month: any(named: 'month'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, DashboardSummary>(
        ServerFailure(),
      ),
    );

    final result = await useCase(userId: userId, month: month);

    expect(result, isA<Left<Failure, DashboardSummary>>());
  });
}
