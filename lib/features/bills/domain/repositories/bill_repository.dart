import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';

abstract class BillRepository {
  Future<Either<Failure, List<BillEntity>>> getBills({
    required String userId,
    BillStatus? status,
    bool forceRefresh = false,
  });

  Future<Either<Failure, BillEntity>> getBill(String id);

  Future<Either<Failure, BillEntity>> createBill(BillEntity bill);

  Future<Either<Failure, BillEntity>> updateBill(BillEntity bill);

  /// Updates `bill` and propagates non-temporal fields (`description`,
  /// `amount`, `categoryId`, `notes`, `type`) plus the `dueDate.day` to
  /// every real bill in its monthly chain whose `dueDate` is strictly
  /// after the edited bill's `dueDate`. Paid descendants are walked to
  /// find further descendants but their own fields are not mutated.
  ///
  /// See `docs/specs/bills.md` → "Editing Recurrent Bills".
  Future<Either<Failure, BillEntity>> updateBillAndSubsequents(
    BillEntity bill,
  );

  Future<Either<Failure, void>> deleteBill(String id);

  Future<Either<Failure, BillPaymentResult>> payBill({
    required String billId,
    required String accountId,
    required String categoryId,
  });

  /// Settles a pending bill against a transaction that already exists
  /// (no new transaction is created). Used by the match-suggestion flow
  /// when the user confirms "yes, that recorded transaction was this bill".
  /// Same monthly-recurrence side-effects as `payBill`.
  Future<Either<Failure, BillPaymentResult>> linkBillToExistingTransaction({
    required String billId,
    required String transactionId,
  });

  /// Records that the user said "no, that transaction is NOT this bill"
  /// for a given suggestion. The pair is silenced on every future scan.
  Future<Either<Failure, BillEntity>> rejectBillTransactionMatch({
    required String billId,
    required String transactionId,
  });
}
