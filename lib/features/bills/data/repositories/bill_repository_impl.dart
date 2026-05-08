import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/bills_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/data/datasources/bill_remote_datasource.dart';
import 'package:financo/features/bills/data/models/bill_model.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';
import 'package:financo/features/bills/domain/utils/monthly_due_date.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class BillRepositoryImpl implements BillRepository {
  BillRepositoryImpl({
    required BillRemoteDataSource remoteDataSource,
    required BillsDao billsDao,
    required TransactionRepository transactionRepository,
  }) : _remote = remoteDataSource,
       _dao = billsDao,
       _transactionRepository = transactionRepository;

  final BillRemoteDataSource _remote;
  final BillsDao _dao;
  final TransactionRepository _transactionRepository;

  @override
  Future<Either<Failure, List<BillEntity>>> getBills({
    required String userId,
    BillStatus? status,
    bool forceRefresh = false,
  }) async {
    try {
      if (forceRefresh) {
        final remote = await _remote.getBills(
          userId: userId,
          status: status,
        );
        await _dao.insertAllBills(remote);
      }
      final local = await _dao.getBills(userId: userId, status: status);
      return Right(local);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> getBill(String id) async {
    try {
      final local = await _dao.getBillById(id);
      if (local != null) return Right(local);
      final result = await _remote.getBill(id);
      await _dao.upsertBill(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> createBill(BillEntity bill) async {
    try {
      final model = BillModel.fromEntity(bill);
      final result = await _remote.createBill(model);
      await _dao.upsertBill(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> updateBill(BillEntity bill) async {
    try {
      final model = BillModel.fromEntity(bill);
      final result = await _remote.updateBill(model);
      await _dao.upsertBill(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> updateBillAndSubsequents(
    BillEntity bill,
  ) async {
    final primary = await updateBill(bill);
    return primary.fold(Left.new, (saved) async {
      try {
        final all = await _dao.getBills(userId: saved.userId);
        final descendants = _descendantsOf(saved.id, all);
        final now = DateTime.now();
        for (final desc in descendants) {
          if (!desc.dueDate.isAfter(saved.dueDate)) continue;
          // Paid bills are immutable history — walked through to find
          // further descendants but never mutated themselves.
          if (desc.isPaid) continue;
          final clampedDay = clampDayToMonth(
            desc.dueDate.year,
            desc.dueDate.month,
            saved.dueDate.day,
          );
          // Build the propagated entity explicitly instead of via
          // copyWith — copyWith uses `?? this.field` and can't tell a
          // null override from "left untouched", so it would silently
          // preserve the descendant's old `categoryId`/`notes` when the
          // user just cleared them on the source.
          final propagated = BillEntity(
            id: desc.id,
            userId: desc.userId,
            type: saved.type,
            description: saved.description,
            amount: saved.amount,
            dueDate: DateTime(
              desc.dueDate.year,
              desc.dueDate.month,
              clampedDay,
            ),
            status: desc.status,
            recurrence: desc.recurrence,
            categoryId: saved.categoryId,
            notes: saved.notes,
            paidAt: desc.paidAt,
            paidTransactionId: desc.paidTransactionId,
            parentBillId: desc.parentBillId,
            rejectedTransactionIds: desc.rejectedTransactionIds,
            createdAt: desc.createdAt,
            updatedAt: now,
          );
          final propResult = await updateBill(propagated);
          if (propResult.isLeft()) {
            // Bail on first failure — partial propagation is acceptable
            // because each `updateBill` is independent (already-written
            // descendants stay updated) and the user can retry.
            return propResult;
          }
        }
        return Right(saved);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    });
  }

  /// BFS walk over `parentBillId` to collect every descendant of `rootId`
  /// in the loaded set. The root itself is not included.
  List<BillEntity> _descendantsOf(String rootId, List<BillEntity> all) {
    final byParent = <String, List<BillEntity>>{};
    for (final b in all) {
      final pid = b.parentBillId;
      if (pid != null) byParent.putIfAbsent(pid, () => []).add(b);
    }
    final out = <BillEntity>[];
    final queue = <String>[rootId];
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      final children = byParent[id] ?? const [];
      out.addAll(children);
      queue.addAll(children.map((c) => c.id));
    }
    return out;
  }

  @override
  Future<Either<Failure, void>> deleteBill(String id) async {
    try {
      await _remote.deleteBill(id);
      await _dao.deleteBill(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BillPaymentResult>> payBill({
    required String billId,
    required String accountId,
    required String categoryId,
  }) async {
    final billResult = await getBill(billId);
    return billResult.fold(Left.new, (bill) async {
      if (bill.status == BillStatus.paid) {
        return const Left(ValidationFailure('Bill already paid.'));
      }

      final now = DateTime.now();

      // 1. Create the linked transaction. Payable bills produce expenses,
      // receivable bills produce income.
      final txType = bill.type == BillType.receivable
          ? TransactionType.income
          : TransactionType.expense;
      final tx = TransactionEntity(
        id: '',
        userId: bill.userId,
        accountId: accountId,
        categoryId: categoryId,
        type: txType,
        amount: bill.amount,
        description: bill.description,
        date: DateTime(now.year, now.month, now.day),
        notes: bill.notes,
        createdAt: now,
        updatedAt: now,
      );
      final txResult = await _transactionRepository.createTransaction(tx);
      return txResult.fold(
        Left.new,
        (createdTx) => _settleBillAgainstTransaction(bill: bill, tx: createdTx),
      );
    });
  }

  @override
  Future<Either<Failure, BillPaymentResult>> linkBillToExistingTransaction({
    required String billId,
    required String transactionId,
  }) async {
    final billResult = await getBill(billId);
    return billResult.fold(Left.new, (bill) async {
      if (bill.status == BillStatus.paid) {
        return const Left(ValidationFailure('Bill already paid.'));
      }
      final txResult = await _transactionRepository.getTransaction(
        transactionId,
      );
      return txResult.fold(
        Left.new,
        (tx) => _settleBillAgainstTransaction(bill: bill, tx: tx),
      );
    });
  }

  @override
  Future<Either<Failure, BillEntity>> rejectBillTransactionMatch({
    required String billId,
    required String transactionId,
  }) async {
    final billResult = await getBill(billId);
    return billResult.fold(Left.new, (bill) async {
      if (bill.rejectedTransactionIds.contains(transactionId)) {
        // Idempotent: already rejected, no need to write again.
        return Right(bill);
      }
      final updated = bill.copyWith(
        rejectedTransactionIds: [
          ...bill.rejectedTransactionIds,
          transactionId,
        ],
        updatedAt: DateTime.now(),
      );
      return updateBill(updated);
    });
  }

  /// Marks `bill` as paid against `tx` (no new transaction is created)
  /// and, if monthly, creates the next occurrence. Shared between the
  /// "pay now" flow (which creates a fresh tx first) and the link-existing
  /// flow.
  Future<Either<Failure, BillPaymentResult>> _settleBillAgainstTransaction({
    required BillEntity bill,
    required TransactionEntity tx,
  }) async {
    final now = DateTime.now();
    final paidBill = bill.copyWith(
      status: BillStatus.paid,
      paidAt: now,
      paidTransactionId: tx.id,
      updatedAt: now,
    );
    final paidResult = await updateBill(paidBill);
    return paidResult.fold(Left.new, (updatedBill) async {
      BillEntity? nextOccurrence;
      if (updatedBill.recurrence == BillRecurrence.monthly) {
        // Fast-forward to the first dueDate >= today so a late settlement
        // doesn't spawn a "born overdue" occurrence (which would trigger
        // tomorrow's notifyBillsDue notification and force the user to
        // settle again the next day, indefinitely on long-stale chains).
        final nextDue = nextMonthlyDueDateAfter(updatedBill.dueDate, now);
        final next = BillEntity(
          id: '',
          userId: updatedBill.userId,
          type: updatedBill.type,
          description: updatedBill.description,
          amount: updatedBill.amount,
          dueDate: nextDue,
          status: BillStatus.pending,
          recurrence: BillRecurrence.monthly,
          categoryId: updatedBill.categoryId,
          notes: updatedBill.notes,
          parentBillId: updatedBill.id,
          createdAt: now,
          updatedAt: now,
        );
        final nextResult = await createBill(next);
        // Don't fail the whole flow if next occurrence creation fails —
        // the user can manually re-create it. Log via Left silently.
        nextResult.fold(
          (_) => nextOccurrence = null,
          (created) => nextOccurrence = created,
        );
      }
      return Right(
        BillPaymentResult(
          paidBill: updatedBill,
          transaction: tx,
          nextOccurrence: nextOccurrence,
        ),
      );
    });
  }

}
