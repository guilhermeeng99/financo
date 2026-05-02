// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_dao.dart';

// ignore_for_file: type=lint
mixin _$BudgetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalBudgetsTable get localBudgets => attachedDatabase.localBudgets;
  BudgetsDaoManager get managers => BudgetsDaoManager(this);
}

class BudgetsDaoManager {
  final _$BudgetsDaoMixin _db;
  BudgetsDaoManager(this._db);
  $$LocalBudgetsTableTableManager get localBudgets =>
      $$LocalBudgetsTableTableManager(_db.attachedDatabase, _db.localBudgets);
}
