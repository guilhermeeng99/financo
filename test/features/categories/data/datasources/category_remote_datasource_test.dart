import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/category_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CategoryRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = CategoryRemoteDataSourceImpl(firestore: firestore);
  });

  group('createCategory', () {
    test('persists the model and returns it with the generated id', () async {
      final model = CategoryModel.fromEntity(CategoryFactory.expense());

      final created = await datasource.createCategory(model);

      expect(created.id, isNotEmpty);
      expect(created.name, model.name);
      expect(created.type, CategoryType.expense);
      expect(created.icon, model.icon);
      expect(created.color, model.color);
    });

    test('round-trips bucket and parent linkage', () async {
      final parent = await datasource.createCategory(
        CategoryModel.fromEntity(
          CategoryFactory.expense(bucket: CategoryBucket.needs),
        ),
      );
      final child = await datasource.createCategory(
        CategoryModel.fromEntity(
          CategoryFactory.subcategory(parentId: parent.id),
        ),
      );

      expect(parent.bucket, CategoryBucket.needs);
      expect(child.parentId, parent.id);
    });
  });

  group('getCategories', () {
    test("returns only the given user's categories ordered by name",
        () async {
      await datasource.createCategory(
        CategoryModel.fromEntity(CategoryFactory.expense(name: 'Zoo')),
      );
      await datasource.createCategory(
        CategoryModel.fromEntity(CategoryFactory.expense(name: 'Aquarium')),
      );
      await datasource.createCategory(
        CategoryModel.fromEntity(
          CategoryFactory.expense(name: 'Foreign', userId: 'user-2'),
        ),
      );

      final categories = await datasource.getCategories(userId: userId);

      expect(categories.map((c) => c.name).toList(), ['Aquarium', 'Zoo']);
    });
  });

  group('updateCategory', () {
    test('overwrites stored fields and returns the fresh doc', () async {
      final created = await datasource.createCategory(
        CategoryModel.fromEntity(CategoryFactory.expense()),
      );

      final updated = await datasource.updateCategory(
        CategoryModel.fromEntity(
          CategoryFactory.expense(id: created.id, name: 'Renamed'),
        ),
      );

      expect(updated.name, 'Renamed');
      final all = await datasource.getCategories(userId: userId);
      expect(all.single.name, 'Renamed');
    });
  });

  group('deleteCategory', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createCategory(
        CategoryModel.fromEntity(CategoryFactory.expense(name: 'Keep')),
      );
      final drop = await datasource.createCategory(
        CategoryModel.fromEntity(CategoryFactory.expense(name: 'Drop')),
      );

      await datasource.deleteCategory(drop.id);

      final remaining = await datasource.getCategories(userId: userId);
      expect(remaining.map((c) => c.id).toList(), [keep.id]);
    });
  });
}
