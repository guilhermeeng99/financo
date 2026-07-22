import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/presentation/cubit/investing_transactions_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAssetTransactionsUseCase getTransactions;
  late MockGetAssetsUseCase getAssets;
  late MockGetInstitutionsUseCase getInstitutions;

  setUp(() {
    getTransactions = MockGetAssetTransactionsUseCase();
    getAssets = MockGetAssetsUseCase();
    getInstitutions = MockGetInstitutionsUseCase();
  });

  InvestingTransactionsCubit build() => InvestingTransactionsCubit(
    getTransactions: getTransactions,
    getAssets: getAssets,
    getInstitutions: getInstitutions,
    userId: 'user-1',
  );

  blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
    'emits [Loading, Loaded] merging transactions, assets and institutions',
    build: () {
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => Right([AssetTransactionFactory.buy()]));
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
      when(
        () => getInstitutions(userId: 'user-1'),
      ).thenAnswer((_) async => Right([InstitutionFactory.avenue()]));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingTransactionsLoading(),
      InvestingTransactionsLoaded(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        institutions: [InstitutionFactory.avenue()],
      ),
    ],
  );

  blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
    'emits [Error] when any dependency load fails',
    build: () {
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingTransactionsLoading(),
      const InvestingTransactionsError(ServerFailure()),
    ],
  );
}
