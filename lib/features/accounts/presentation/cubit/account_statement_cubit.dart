import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountStatementCubit extends Cubit<AccountStatementState> {
  AccountStatementCubit({
    required GetTransactionsUseCase getTransactions,
    required GetTransactionUseCase getTransaction,
    required String accountId,
  }) : _getTransactions = getTransactions,
       _getTransaction = getTransaction,
       _accountId = accountId,
       super(const AccountStatementInitial());

  final GetTransactionsUseCase _getTransactions;
  final GetTransactionUseCase _getTransaction;
  final String _accountId;

  Future<void> load(AccountEntity account, int year, int month) async {
    log(
      'Loading statement: accountId=$_accountId, '
      'userId=${account.userId}, year=$year, month=$month',
      name: 'AccountStatementCubit',
    );
    emit(const AccountStatementLoading());

    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    // Fetch all-time transactions (for running balance) and period transactions
    // in parallel.
    final results = await Future.wait([
      _getTransactions(
        userId: account.userId,
        accountId: _accountId,
        forceRefresh: true,
      ),
      _getTransactions(
        userId: account.userId,
        accountId: _accountId,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: true,
      ),
    ]);

    final allTimeResult = results[0];
    final periodResult = results[1];

    if (allTimeResult.isLeft()) {
      final failure = allTimeResult.fold((f) => f, (_) => null)!;
      log(
        'Failed to load transactions: ${failure.message}',
        name: 'AccountStatementCubit',
      );
      emit(AccountStatementError(failure));
      return;
    }

    if (periodResult.isLeft()) {
      final failure = periodResult.fold((f) => f, (_) => null)!;
      log(
        'Failed to load period transactions: ${failure.message}',
        name: 'AccountStatementCubit',
      );
      emit(AccountStatementError(failure));
      return;
    }

    final allTransactions = allTimeResult.fold(
      (_) => <TransactionEntity>[],
      (t) => t,
    );
    final periodTransactions = periodResult.fold(
      (_) => <TransactionEntity>[],
      (t) => t,
    );

    // Running balance = seed balance + all income - all expenses
    var runningBalance = account.initialBalance;
    for (final tx in allTransactions) {
      if (tx.type == TransactionType.income) {
        runningBalance += tx.amount;
      } else {
        runningBalance -= tx.amount;
      }
    }

    // Period summary
    final sorted = List<TransactionEntity>.from(periodTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    var totalIncome = 0.0;
    var totalExpenses = 0.0;
    for (final tx in sorted) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }

    // Resolve the other side of each transfer so the view can render
    // "SourceAccount → DestinationAccount" labels. A failed lookup is
    // skipped silently — the tile just falls back to no label.
    final transferCounterpartAccountIds = <String, String>{};
    final transfers = sorted.where((tx) => tx.isTransfer).toList();
    if (transfers.isNotEmpty) {
      final results = await Future.wait(
        transfers.map(
          (tx) => _getTransaction(tx.linkedTransactionId!),
        ),
      );
      for (var i = 0; i < transfers.length; i++) {
        results[i].fold(
          (_) {},
          (linked) =>
              transferCounterpartAccountIds[transfers[i].id] = linked.accountId,
        );
      }
    }

    emit(
      AccountStatementLoaded(
        account: account,
        runningBalance: runningBalance,
        transactions: sorted,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        year: year,
        month: month,
        transferCounterpartAccountIds: transferCounterpartAccountIds,
      ),
    );
  }
}

sealed class AccountStatementState extends Equatable {
  const AccountStatementState();

  @override
  List<Object?> get props => [];
}

final class AccountStatementInitial extends AccountStatementState {
  const AccountStatementInitial();
}

final class AccountStatementLoading extends AccountStatementState {
  const AccountStatementLoading();
}

final class AccountStatementLoaded extends AccountStatementState {
  const AccountStatementLoaded({
    required this.account,
    required this.runningBalance,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.year,
    required this.month,
    this.transferCounterpartAccountIds = const {},
  });

  final AccountEntity account;
  final double runningBalance;
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpenses;
  final int year;
  final int month;

  // transfer transaction id → accountId of the linked (other side) transaction
  final Map<String, String> transferCounterpartAccountIds;

  double get result => totalIncome - totalExpenses;

  @override
  List<Object> get props => [
    account,
    runningBalance,
    transactions,
    totalIncome,
    totalExpenses,
    year,
    month,
    transferCounterpartAccountIds,
  ];
}

final class AccountStatementError extends AccountStatementState {
  const AccountStatementError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
