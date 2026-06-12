import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/settle_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockTransactionRepository repository;
  late SettleTransactionUseCase usecase;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    repository = MockTransactionRepository();
    usecase = SettleTransactionUseCase(repository);
  });

  TransactionEntity pendingPayable() => TransactionFactory.expense(
    settlementStatus: TransactionSettlementStatus.pending,
    dueDate: DateTime(2026, 6, 20),
  );

  void stubUpdateEcho() {
    when(() => repository.updateTransaction(any())).thenAnswer(
      (invocation) async => Right(
        invocation.positionalArguments.first as TransactionEntity,
      ),
    );
  }

  TransactionEntity capturedUpdate() =>
      verify(() => repository.updateTransaction(captureAny()))
          .captured
          .single as TransactionEntity;

  group('SettleTransactionUseCase', () {
    test('marks a pending transaction as paid with an explicit settledAt',
        () async {
      stubUpdateEcho();
      final explicit = DateTime(2026, 6, 15, 14, 30);

      final result = await usecase(pendingPayable(), settledAt: explicit);

      expect(result.isRight(), isTrue);
      final updated = capturedUpdate();
      expect(updated.settlementStatus, TransactionSettlementStatus.paid);
      // The settlement date becomes the effective cash-flow date: the
      // transaction moves from "due on dueDate" to "happened on date".
      expect(updated.date, explicit);
      expect(updated.settledAt, explicit);
      expect(updated.updatedAt, explicit);
    });

    test('defaults settledAt to now when omitted', () async {
      stubUpdateEcho();
      final before = DateTime.now();

      await usecase(pendingPayable());

      final after = DateTime.now();
      final updated = capturedUpdate();
      expect(updated.settledAt, isNotNull);
      expect(updated.settledAt!.isBefore(before), isFalse);
      expect(updated.settledAt!.isAfter(after), isFalse);
      // date / settledAt / updatedAt must be the exact same instant so
      // ledgers and sync ordering agree on when the settlement happened.
      expect(updated.date, updated.settledAt);
      expect(updated.updatedAt, updated.settledAt);
    });

    test('preserves identity fields of the settled transaction', () async {
      stubUpdateEcho();
      final pending = pendingPayable();

      await usecase(pending, settledAt: DateTime(2026, 6, 15));

      final updated = capturedUpdate();
      expect(updated.id, pending.id);
      expect(updated.accountId, pending.accountId);
      expect(updated.categoryId, pending.categoryId);
      expect(updated.amount, pending.amount);
      expect(updated.description, pending.description);
    });

    test('settles pending receivables too', () async {
      stubUpdateEcho();
      final receivable = TransactionFactory.income(
        settlementStatus: TransactionSettlementStatus.pending,
        dueDate: DateTime(2026, 6, 25),
      );

      final result = await usecase(receivable, settledAt: DateTime(2026, 6));

      expect(result.isRight(), isTrue);
      expect(
        capturedUpdate().settlementStatus,
        TransactionSettlementStatus.paid,
      );
    });

    test('rejects transfers with a ValidationFailure and never hits the repo',
        () async {
      final transferLeg = TransactionFactory.transfer().expense;

      final result = await usecase(transferLeg);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => repository.updateTransaction(any()));
    });

    test('forwards repository failures unchanged', () async {
      const failure = ServerFailure('update exploded');
      when(() => repository.updateTransaction(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(pendingPayable());

      result.fold(
        (forwarded) => expect(forwarded, same(failure)),
        (_) => fail('Expected Left'),
      );
    });
  });
}
