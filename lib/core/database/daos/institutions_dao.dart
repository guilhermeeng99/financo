import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/institutions_table.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';

part 'institutions_dao.g.dart';

@DriftAccessor(tables: [LocalInstitutions])
class InstitutionsDao extends DatabaseAccessor<AppDatabase>
    with _$InstitutionsDaoMixin {
  InstitutionsDao(super.attachedDatabase);

  Future<void> insertAllInstitutions(List<Institution> institutions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localInstitutions,
        institutions.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertInstitution(Institution institution) => into(
    localInstitutions,
  ).insertOnConflictUpdate(_toCompanion(institution));

  Future<List<Institution>> getInstitutions(String userId) async {
    final rows =
        await (select(localInstitutions)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> deleteInstitution(String id) =>
      (delete(localInstitutions)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllInstitutions() => delete(localInstitutions).go();

  LocalInstitutionsCompanion _toCompanion(Institution e) =>
      LocalInstitutionsCompanion.insert(
        id: e.id,
        userId: e.userId,
        name: e.name,
        kind: e.kind.name,
        currency: e.currency.name,
        createdAt: e.createdAt,
        bank: Value(e.bank),
        color: Value(e.color),
      );

  Institution _toEntity(LocalInstitution row) => Institution(
    id: row.id,
    userId: row.userId,
    name: row.name,
    kind: InstitutionKind.values.byName(row.kind),
    currency: Currency.values.byName(row.currency),
    createdAt: row.createdAt,
    bank: row.bank,
    color: row.color,
  );
}
