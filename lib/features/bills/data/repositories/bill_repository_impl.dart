import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/bills_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/data/datasources/bill_remote_datasource.dart';
import 'package:financo/features/bills/data/models/bill_model.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';
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
      return txResult.fold(Left.new, (createdTx) async {
        // 2. Mark bill as paid.
        final paidBill = bill.copyWith(
          status: BillStatus.paid,
          paidAt: now,
          paidTransactionId: createdTx.id,
          updatedAt: now,
        );
        final paidResult = await updateBill(paidBill);
        return paidResult.fold(Left.new, (updatedBill) async {
          // 3. Generate next occurrence for monthly recurrence.
          BillEntity? nextOccurrence;
          if (updatedBill.recurrence == BillRecurrence.monthly) {
            final nextDue = _nextMonthlyDueDate(updatedBill.dueDate);
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
              transaction: createdTx,
              nextOccurrence: nextOccurrence,
            ),
          );
        });
      });
    });
  }

  /// Returns `dueDate` shifted by one calendar month, clamping the day to the
  /// last valid day of the resulting month (Jan 31 → Feb 28/29).
  static DateTime _nextMonthlyDueDate(DateTime dueDate) {
    final nextMonth = dueDate.month == 12 ? 1 : dueDate.month + 1;
    final nextYear = dueDate.month == 12 ? dueDate.year + 1 : dueDate.year;
    final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
    final day = math.min(dueDate.day, lastDay);
    return DateTime(nextYear, nextMonth, day);
  }
}
