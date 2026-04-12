import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/categories_table.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [LocalCategories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.attachedDatabase);

  Future<void> insertAllCategories(List<CategoryEntity> categories) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localCategories,
        categories.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertCategory(CategoryEntity category) =>
      into(localCategories).insertOnConflictUpdate(_toCompanion(category));

  Future<List<CategoryEntity>> getCategories(String userId) async {
    final rows =
        await (select(localCategories)
              ..where(
                (t) => t.userId.equals(userId) | t.isDefault.equals(true),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<CategoryEntity?> getCategoryById(String id) async {
    final row = await (select(
      localCategories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteCategory(String id) =>
      (delete(localCategories)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllCategories() => delete(localCategories).go();

  LocalCategoriesCompanion _toCompanion(CategoryEntity e) =>
      LocalCategoriesCompanion.insert(
        id: e.id,
        userId: Value(e.userId),
        name: e.name,
        icon: e.icon,
        color: e.color,
        type: e.type.name,
        isDefault: e.isDefault,
        sortOrder: e.sortOrder,
      );

  CategoryEntity _toEntity(LocalCategory row) => CategoryEntity(
    id: row.id,
    userId: row.userId,
    name: row.name,
    icon: row.icon,
    color: row.color,
    type: CategoryType.values.byName(row.type),
    isDefault: row.isDefault,
    sortOrder: row.sortOrder,
  );
}
