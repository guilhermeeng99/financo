import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel', () {
    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        const entity = CategoryEntity(
          id: 'cat-1',
          userId: 'user-1',
          name: 'Food',
          icon: 58746,
          color: 4294198070,
          type: CategoryType.expense,
        );

        final model = CategoryModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.name, entity.name);
        expect(model.icon, entity.icon);
        expect(model.color, entity.color);
        expect(model.type, entity.type);
      });

      test('should preserve parentId for subcategory entity', () {
        const entity = CategoryEntity(
          id: 'cat-1',
          userId: 'user-1',
          name: 'Restaurants',
          icon: 58746,
          color: 4294198070,
          type: CategoryType.expense,
          parentId: 'parent-1',
        );

        final model = CategoryModel.fromEntity(entity);

        expect(model.parentId, 'parent-1');
        expect(model.isSubcategory, isTrue);
        expect(model.canBeParent, isFalse);
      });

      test('should handle null userId', () {
        const entity = CategoryEntity(
          id: 'cat-default',
          name: 'General',
          icon: 58332,
          color: 4280391411,
          type: CategoryType.expense,
        );

        final model = CategoryModel.fromEntity(entity);

        expect(model.userId, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields except id', () {
        const model = CategoryModel(
          id: 'cat-1',
          userId: 'user-1',
          name: 'Food',
          icon: 58746,
          color: 4294198070,
          type: CategoryType.expense,
        );

        final json = model.toJson();

        expect(json, {
          'userId': 'user-1',
          'name': 'Food',
          'icon': 58746,
          'color': 4294198070,
          'type': 'expense',
        });
        expect(json.containsKey('id'), isFalse);
      });

      test('should serialize type as string name', () {
        const model = CategoryModel(
          id: 'cat-1',
          name: 'Salary',
          icon: 59472,
          color: 4283215696,
          type: CategoryType.income,
        );

        final json = model.toJson();

        expect(json['type'], 'income');
      });

      test('should include parentId when serializing subcategory', () {
        const model = CategoryModel(
          id: 'cat-1',
          userId: 'user-1',
          name: 'Restaurants',
          icon: 58746,
          color: 4294198070,
          type: CategoryType.expense,
          parentId: 'parent-1',
        );

        final json = model.toJson();

        expect(json['parentId'], 'parent-1');
      });
    });

    group('fromMap', () {
      test('should deserialize from map data', () {
        final model = CategoryModel.fromMap(
          id: 'cat-1',
          data: const {
            'userId': 'user-1',
            'name': 'Food',
            'icon': 58746,
            'color': 4294198070,
            'type': 'expense',
          },
        );

        expect(model.id, 'cat-1');
        expect(model.userId, 'user-1');
        expect(model.name, 'Food');
        expect(model.icon, 58746);
        expect(model.color, 4294198070);
        expect(model.type, CategoryType.expense);
      });

      test('should parse income type', () {
        final model = CategoryModel.fromMap(
          id: 'cat-2',
          data: const {
            'userId': 'user-1',
            'name': 'Salary',
            'icon': 59472,
            'color': 4283215696,
            'type': 'income',
          },
        );

        expect(model.type, CategoryType.income);
      });

      test('should deserialize parentId when present', () {
        final model = CategoryModel.fromMap(
          id: 'cat-2',
          data: const {
            'userId': 'user-1',
            'name': 'Restaurants',
            'icon': 58746,
            'color': 4294198070,
            'type': 'expense',
            'parentId': 'parent-1',
          },
        );

        expect(model.parentId, 'parent-1');
        expect(model.isSubcategory, isTrue);
      });

      test('should default to expense for unknown type', () {
        final model = CategoryModel.fromMap(
          id: 'cat-3',
          data: const {
            'userId': 'user-1',
            'name': 'Unknown',
            'icon': 58332,
            'color': 4280391411,
            'type': 'invalid_type',
          },
        );

        expect(model.type, CategoryType.expense);
      });
    });
  });
}
