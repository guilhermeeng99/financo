// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_transactions_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestmentTransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalInvestmentTransactionsTable get localInvestmentTransactions =>
      attachedDatabase.localInvestmentTransactions;
  InvestmentTransactionsDaoManager get managers =>
      InvestmentTransactionsDaoManager(this);
}

class InvestmentTransactionsDaoManager {
  final _$InvestmentTransactionsDaoMixin _db;
  InvestmentTransactionsDaoManager(this._db);
  $$LocalInvestmentTransactionsTableTableManager
  get localInvestmentTransactions =>
      $$LocalInvestmentTransactionsTableTableManager(
        _db.attachedDatabase,
        _db.localInvestmentTransactions,
      );
}
