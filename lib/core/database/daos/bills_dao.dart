import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/bills_table.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';

part 'bills_dao.g.dart';

@DriftAccessor(tables: [LocalBills])
class BillsDao extends DatabaseAccessor<AppDatabase> with _$BillsDaoMixin {
  BillsDao(super.attachedDatabase);

  Future<void> insertAllBills(List<BillEntity> bills) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localBills,
        bills.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertBill(BillEntity bill) =>
      into(localBills).insertOnConflictUpdate(_toCompanion(bill));

  Future<List<BillEntity>> getBills({
    required String userId,
    BillStatus? status,
  }) async {
    final query = select(localBills)
      ..where((b) => b.userId.equals(userId));

    if (status != null) {
      query.where((b) => b.status.equals(status.name));
    }

    query.orderBy([(b) => OrderingTerm.asc(b.dueDate)]);

    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  Future<BillEntity?> getBillById(String id) async {
    final row = await (select(
      localBills,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteBill(String id) =>
      (delete(localBills)..where((b) => b.id.equals(id))).go();

  Future<void> deleteAllBills() => delete(localBills).go();

  LocalBillsCompanion _toCompanion(BillEntity e) => LocalBillsCompanion.insert(
    id: e.id,
    userId: e.userId,
    type: Value(e.type.name),
    description: e.description,
    amount: e.amount,
    dueDate: e.dueDate,
    status: e.status.name,
    recurrence: e.recurrence.name,
    categoryId: Value(e.categoryId),
    notes: Value(e.notes),
    paidAt: Value(e.paidAt),
    paidTransactionId: Value(e.paidTransactionId),
    parentBillId: Value(e.parentBillId),
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  BillEntity _toEntity(LocalBill row) => BillEntity(
    id: row.id,
    userId: row.userId,
    type: BillType.values.byName(row.type),
    description: row.description,
    amount: row.amount,
    dueDate: row.dueDate,
    status: BillStatus.values.byName(row.status),
    recurrence: BillRecurrence.values.byName(row.recurrence),
    categoryId: row.categoryId,
    notes: row.notes,
    paidAt: row.paidAt,
    paidTransactionId: row.paidTransactionId,
    parentBillId: row.parentBillId,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
