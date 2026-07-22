import 'package:financo/features/investing/data/models/asset_transaction_model.dart';
import 'package:financo/features/investing/data/repositories/asset_transaction_repository_impl.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      AssetTransactionModel.fromEntity(AssetTransactionFactory.buy()),
    );
    registerFallbackValue(AssetTransactionFactory.buy());
    registerFallbackValue(<AssetTransaction>[]);
  });

  late MockAssetTransactionRemoteDataSource remote;
  late MockInvestmentTransactionsDao dao;
  late AssetTransactionRepositoryImpl repo;

  setUp(() {
    remote = MockAssetTransactionRemoteDataSource();
    dao = MockInvestmentTransactionsDao();
    repo = AssetTransactionRepositoryImpl(
      remoteDataSource: remote,
      transactionsDao: dao,
    );
  });

  test('saveTransaction with an empty id creates remotely', () async {
    final created = AssetTransactionModel.fromEntity(
      AssetTransactionFactory.buy(),
    );
    when(
      () => remote.createTransaction(any()),
    ).thenAnswer((_) async => created);
    when(() => dao.upsertTransaction(any())).thenAnswer((_) async {});

    final result = await repo.saveTransaction(
      AssetTransactionFactory.buy(id: ''),
    );

    expect(result.isRight(), isTrue);
    verify(() => remote.createTransaction(any())).called(1);
    verifyNever(() => remote.updateTransaction(any()));
    verify(() => dao.upsertTransaction(created)).called(1);
  });

  test('saveTransaction with an id updates remotely', () async {
    final updated = AssetTransactionModel.fromEntity(
      AssetTransactionFactory.buy(),
    );
    when(
      () => remote.updateTransaction(any()),
    ).thenAnswer((_) async => updated);
    when(() => dao.upsertTransaction(any())).thenAnswer((_) async {});

    final result = await repo.saveTransaction(
      AssetTransactionFactory.buy(id: 'tx-1'),
    );

    expect(result.isRight(), isTrue);
    verify(() => remote.updateTransaction(any())).called(1);
    verifyNever(() => remote.createTransaction(any()));
  });

  test('deleteTransaction deletes remote then local', () async {
    when(() => remote.deleteTransaction('tx-1')).thenAnswer((_) async {});
    when(() => dao.deleteTransaction('tx-1')).thenAnswer((_) async {});

    final result = await repo.deleteTransaction('tx-1');

    expect(result.isRight(), isTrue);
    verify(() => remote.deleteTransaction('tx-1')).called(1);
    verify(() => dao.deleteTransaction('tx-1')).called(1);
  });
}
