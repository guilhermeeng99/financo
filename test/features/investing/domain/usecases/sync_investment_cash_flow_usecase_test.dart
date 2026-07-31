import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/usecases/sync_investment_cash_flow_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockTransactionRepository transactions;
  late SyncInvestmentCashFlowUseCase useCase;

  setUpAll(() {
    registerFallbackValue(TransactionFactory.expense());
  });

  setUp(() {
    transactions = MockTransactionRepository();
    useCase = SyncInvestmentCashFlowUseCase(transactions);
    when(
      () => transactions.createTransaction(any()),
    ).thenAnswer(
      (i) async => Right(i.positionalArguments.first as TransactionEntity),
    );
    when(
      () => transactions.updateTransaction(any()),
    ).thenAnswer(
      (i) async => Right(i.positionalArguments.first as TransactionEntity),
    );
    when(
      () => transactions.deleteTransactions(any()),
    ).thenAnswer((_) async => const Right(null));
  });

  void stubLedger(List<TransactionEntity> rows) {
    when(
      () => transactions.getTransactions(userId: any(named: 'userId')),
    ).thenAnswer((_) async => Right(rows));
  }

  TransactionEntity pairedRow({
    String id = 'cash-1',
    String investingId = 'tx-buy-1',
    double amount = 100,
  }) =>
      TransactionFactory.expense(
        id: id,
        amount: amount,
      ).copyWith(
        institutionId: 'inst-avenue',
        linkedInvestmentTransactionId: investingId,
      );

  group('no cash row wanted', () {
    test('skips the ledger read for an unfunded new transaction', () async {
      final result = await useCase(AssetTransactionFactory.buy(id: ''));

      expect(result.getOrElse(pairedRow), isNull);
      verifyNever(
        () => transactions.getTransactions(userId: any(named: 'userId')),
      );
    });

    test('deletes the paired row when the account is cleared', () async {
      stubLedger([pairedRow()]);

      await useCase(AssetTransactionFactory.buy());

      verify(() => transactions.deleteTransactions(['cash-1'])).called(1);
    });

    test('deletes the paired row when the investing row is deleted', () async {
      stubLedger([pairedRow()]);

      await useCase(
        AssetTransactionFactory.buy(fundingAccountId: 'acc-1'),
        investingDeleted: true,
      );

      verify(() => transactions.deleteTransactions(['cash-1'])).called(1);
      verifyNever(() => transactions.createTransaction(any()));
    });

    test('ignores a dividend even when an account is set', () async {
      stubLedger(const []);

      await useCase(AssetTransactionFactory.dividend());

      verifyNever(() => transactions.createTransaction(any()));
    });
  });

  group('aporte (buy)', () {
    test('creates an expense tagged with the institution', () async {
      stubLedger(const []);

      await useCase(
        AssetTransactionFactory.buy(
          quantity: 2,
          unitPrice: Money.fromMajor(100, Currency.usd),
          fundingAccountId: 'acc-nubank-gui',
          cashAmount: Money.fromMajor(1090.40, Currency.brl),
        ),
      );

      final created =
          verify(
                () => transactions.createTransaction(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(created.type, TransactionType.expense);
      expect(created.accountId, 'acc-nubank-gui');
      // The BRL that actually left the account, not the US$200 native amount.
      expect(created.amount, 1090.40);
      expect(created.institutionId, 'inst-avenue');
      expect(created.linkedInvestmentTransactionId, 'tx-buy-1');
      expect(created.description, 'Aporte');
    });

    test('falls back to the native amount without a cash amount', () async {
      stubLedger(const []);

      await useCase(
        AssetTransactionFactory.buy(
          quantity: 3,
          unitPrice: Money.fromMajor(50, Currency.brl),
          currency: Currency.brl,
          fundingAccountId: 'acc-1',
        ),
      );

      final created =
          verify(
                () => transactions.createTransaction(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(created.amount, 150);
    });
  });

  group('resgate (sell)', () {
    test('creates an income for the payout', () async {
      stubLedger(const []);

      await useCase(
        AssetTransactionFactory.sell(
          quantity: 1,
          unitPrice: Money.fromMajor(7000, Currency.brl),
          currency: Currency.brl,
          fundingAccountId: 'acc-nubank-gui',
        ),
      );

      final created =
          verify(
                () => transactions.createTransaction(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(created.type, TransactionType.income);
      expect(created.amount, 7000);
      expect(created.description, 'Resgate');
    });

    test('uses the notes as the description when present', () async {
      stubLedger(const []);

      await useCase(
        AssetTransactionFactory.sell(
          fundingAccountId: 'acc-1',
          notes: 'Resgate caixinha',
        ),
      );

      final created =
          verify(
                () => transactions.createTransaction(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(created.description, 'Resgate caixinha');
    });
  });

  group('editing', () {
    test('updates the existing row instead of creating a second', () async {
      stubLedger([pairedRow()]);

      await useCase(
        AssetTransactionFactory.buy(
          quantity: 1,
          unitPrice: Money.fromMajor(250, Currency.brl),
          currency: Currency.brl,
          fundingAccountId: 'acc-2',
        ),
      );

      verifyNever(() => transactions.createTransaction(any()));
      final updated =
          verify(
                () => transactions.updateTransaction(captureAny()),
              ).captured.single
              as TransactionEntity;
      expect(updated.id, 'cash-1');
      expect(updated.amount, 250);
      expect(updated.accountId, 'acc-2');
    });

    test('drops duplicate rows left by a partial failure', () async {
      stubLedger([pairedRow(), pairedRow(id: 'cash-2')]);

      await useCase(AssetTransactionFactory.buy(fundingAccountId: 'acc-1'));

      verify(() => transactions.deleteTransactions(['cash-2'])).called(1);
      verify(() => transactions.updateTransaction(any())).called(1);
    });
  });

  test('surfaces a ledger read failure', () async {
    when(
      () => transactions.getTransactions(userId: any(named: 'userId')),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(
      AssetTransactionFactory.buy(fundingAccountId: 'acc-1'),
    );

    expect(result.isLeft(), isTrue);
  });
}
