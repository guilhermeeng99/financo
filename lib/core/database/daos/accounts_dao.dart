import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/accounts_table.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [LocalAccounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.attachedDatabase);

  Future<void> insertAllAccounts(List<AccountEntity> accounts) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localAccounts,
        accounts.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertAccount(AccountEntity account) =>
      into(localAccounts).insertOnConflictUpdate(_toCompanion(account));

  Future<List<AccountEntity>> getAccounts(String userId) async {
    final rows =
        await (select(localAccounts)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<AccountEntity?> getAccountById(String id) async {
    final row = await (select(
      localAccounts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteAccount(String id) =>
      (delete(localAccounts)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllAccounts() => delete(localAccounts).go();

  LocalAccountsCompanion _toCompanion(AccountEntity e) =>
      LocalAccountsCompanion.insert(
        id: e.id,
        userId: e.userId,
        name: e.name,
        type: e.type.name,
        bank: e.bank.name,
        initialBalance: e.initialBalance,
        creditLimit: Value(e.creditLimit),
        closingDay: Value(e.closingDay),
        dueDay: Value(e.dueDay),
        linkedAccountId: Value(e.linkedAccountId),
        createdAt: e.createdAt,
      );

  AccountEntity _toEntity(LocalAccount row) => AccountEntity(
    id: row.id,
    userId: row.userId,
    name: row.name,
    type: AccountType.values.byName(row.type),
    bank: BankType.values.byName(row.bank),
    initialBalance: row.initialBalance,
    creditLimit: row.creditLimit,
    closingDay: row.closingDay,
    dueDay: row.dueDay,
    linkedAccountId: row.linkedAccountId,
    createdAt: row.createdAt,
  );
}
