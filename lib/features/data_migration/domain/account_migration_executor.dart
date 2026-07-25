import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/data_migration/domain/account_migration_planner.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Tally of what an applied migration changed, shown on the result screen.
class MigrationResult extends Equatable {
  const MigrationResult({
    this.aportesRetagged = 0,
    this.legsDeleted = 0,
    this.accountsRemoved = 0,
    this.accountsCreated = 0,
    this.institutionsRemoved = 0,
  });

  final int aportesRetagged;
  final int legsDeleted;
  final int accountsRemoved;
  final int accountsCreated;
  final int institutionsRemoved;

  @override
  List<Object?> get props => [
    aportesRetagged,
    legsDeleted,
    accountsRemoved,
    accountsCreated,
    institutionsRemoved,
  ];
}

/// Applies an [AccountMigrationPlan] to the real data (F8.5 + F9.6). Invoked
/// only after the user confirms the in-app diff. Writes are sequential and
/// stop on the first failure, returning it — a partial run is reported by the
/// UI so the user can re-open the (recomputed) plan and finish. See
/// `docs/specs/investing_account_unification.md` §6.
class AccountMigrationExecutor {
  const AccountMigrationExecutor({
    required AccountRepository accountRepository,
    required InstitutionRepository institutionRepository,
    required TransactionRepository transactionRepository,
  }) : _accounts = accountRepository,
       _institutions = institutionRepository,
       _transactions = transactionRepository;

  final AccountRepository _accounts;
  final InstitutionRepository _institutions;
  final TransactionRepository _transactions;

  Future<Either<Failure, MigrationResult>> apply(
    AccountMigrationPlan plan,
  ) async {
    var aportesRetagged = 0;
    var legsDeleted = 0;
    var accountsRemoved = 0;
    var accountsCreated = 0;
    var institutionsRemoved = 0;

    MigrationResult snapshot() => MigrationResult(
      aportesRetagged: aportesRetagged,
      legsDeleted: legsDeleted,
      accountsRemoved: accountsRemoved,
      accountsCreated: accountsCreated,
      institutionsRemoved: institutionsRemoved,
    );

    // ── F8.5: fold investment accounts into their institutions ──
    for (final merge in plan.merges) {
      // 1) Re-tag each checking-side leg as an institution cash flow.
      for (final flow in merge.aportes) {
        final txResult = await _transactions.getTransaction(flow.transactionId);
        final tx = txResult.fold<TransactionEntity?>((_) => null, (t) => t);
        if (tx == null) continue; // already gone — skip, not fatal
        final failure = _failureOf(
          await _transactions.updateTransaction(
            tx.asInstitutionCashFlow(flow.institutionId),
          ),
        );
        if (failure != null) return Left(failure);
        aportesRetagged++;
      }
      // 2) Delete the account-side legs (their counterpart now carries it).
      for (final legId in merge.deletedLegIds) {
        final failure = _failureOf(
          await _transactions.deleteTransaction(legId),
        );
        if (failure != null) return Left(failure);
        legsDeleted++;
      }
      // 3) Carry the account's brand onto the institution for the dashboard.
      final failedInstitution = _failureOf(
        await _institutions.updateInstitution(
          merge.institution.copyWith(bank: merge.account.bank.name),
        ),
      );
      if (failedInstitution != null) return Left(failedInstitution);
      // 4) Retire the now-redundant investment account.
      final failedAccount = _failureOf(
        await _accounts.deleteAccount(merge.account.id),
      );
      if (failedAccount != null) return Left(failedAccount);
      accountsRemoved++;
    }

    // ── F9.6: convert Wise-style institutions into foreign cash accounts ──
    for (final conversion in plan.conversions) {
      final institution = conversion.institution;
      final account = AccountEntity(
        id: '',
        userId: institution.userId,
        name: institution.name,
        type: AccountType.checking,
        bank: _bankFor(institution),
        initialBalance: 0,
        currency: conversion.currency,
        createdAt: institution.createdAt,
      );
      final failedCreate = _failureOf(await _accounts.createAccount(account));
      if (failedCreate != null) return Left(failedCreate);
      accountsCreated++;
      final failedDelete = _failureOf(
        await _institutions.deleteInstitution(institution.id),
      );
      if (failedDelete != null) return Left(failedDelete);
      institutionsRemoved++;
    }

    return Right(snapshot());
  }

  Failure? _failureOf<T>(Either<Failure, T> either) =>
      either.fold((f) => f, (_) => null);

  BankType _bankFor(Institution institution) {
    final name = institution.bank;
    if (name != null) {
      for (final bank in BankType.values) {
        if (bank.name == name) return bank;
      }
    }
    return BankType.others;
  }
}
