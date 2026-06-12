import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/services/compute_investment_overview.dart';
import 'package:financo/features/investments/domain/usecases/get_investment_overview_usecase.dart';
import 'package:financo/features/investments/presentation/cubit/investments_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/factories/asset_holding_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetInvestmentOverviewUseCase getOverview;

  const userId = 'user-1';

  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    getOverview = MockGetInvestmentOverviewUseCase();
  });

  InvestmentsCubit build() => InvestmentsCubit(
    getOverview: getOverview,
    userId: userId,
  );

  InvestmentSnapshot snapshotFixture() {
    final accounts = [AccountFactory.investment(currentBalance: 10000)];
    final classes = [AssetClassFactory.stocks()];
    final holdings = [
      AssetHoldingFactory.holding(amount: 4000),
    ];
    return InvestmentSnapshot(
      overview: computeInvestmentOverview(
        accounts: accounts,
        classes: classes,
        holdings: holdings,
      ),
      accounts: accounts,
      classes: classes,
      holdings: holdings,
    );
  }

  group('InvestmentsCubit', () {
    test('initial state is InvestmentsInitial', () {
      final cubit = build();
      addTearDown(cubit.close);
      expect(cubit.state, isA<InvestmentsInitial>());
    });

    blocTest<InvestmentsCubit, InvestmentsState>(
      'refresh emits Loading then Loaded on success',
      setUp: () {
        when(
          () => getOverview(
            userId: userId,
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async =>
              Right<Failure, InvestmentSnapshot>(snapshotFixture()),
        );
      },
      build: build,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<InvestmentsLoading>(),
        isA<InvestmentsLoaded>(),
      ],
    );

    blocTest<InvestmentsCubit, InvestmentsState>(
      'refresh emits Loading then Error on failure',
      setUp: () {
        when(
          () => getOverview(
            userId: userId,
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, InvestmentSnapshot>(
            ServerFailure('boom'),
          ),
        );
      },
      build: build,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<InvestmentsLoading>(),
        isA<InvestmentsError>(),
      ],
    );
  });
}
