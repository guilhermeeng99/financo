import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/budget_factory.dart';

void main() {
  group('BudgetModel', () {
    test('fromMap parses Firestore data correctly', () {
      final created = DateTime(2026, 4, 1, 10);
      final updated = DateTime(2026, 4, 15, 14, 30);
      final model = BudgetModel.fromMap(
        id: 'b1',
        data: {
          'userId': 'u1',
          'categoryId': 'cat-food',
          'amount': 1500.0,
          'createdAt': Timestamp.fromDate(created),
          'updatedAt': Timestamp.fromDate(updated),
        },
      );

      expect(model.id, 'b1');
      expect(model.userId, 'u1');
      expect(model.categoryId, 'cat-food');
      expect(model.amount, 1500);
      expect(model.createdAt, created);
      expect(model.updatedAt, updated);
    });

    test('fromMap coerces int amount to double', () {
      // Firestore round-trips numeric fields as `int` when there's no
      // fractional part — the model must call `.toDouble()` defensively.
      final model = BudgetModel.fromMap(
        id: 'b1',
        data: {
          'userId': 'u1',
          'categoryId': 'cat-food',
          'amount': 1000,
          'createdAt': Timestamp.fromDate(DateTime(2026)),
          'updatedAt': Timestamp.fromDate(DateTime(2026)),
        },
      );
      expect(model.amount, 1000.0);
      expect(model.amount, isA<double>());
    });

    test('toJson omits id and serialises dates as Timestamps', () {
      final model = BudgetModel.fromEntity(
        BudgetFactory.make(
          id: 'b1',
          createdAt: DateTime(2026, 4),
          updatedAt: DateTime(2026, 4, 15),
        ),
      );
      final json = model.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['userId'], 'user-1');
      expect(json['categoryId'], 'cat-1');
      expect(json['amount'], 1500);
      expect(json['createdAt'], isA<Timestamp>());
      expect(json['updatedAt'], isA<Timestamp>());
    });

    test('fromEntity preserves all fields', () {
      final entity = BudgetFactory.make(amount: 999);
      final model = BudgetModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.userId, entity.userId);
      expect(model.categoryId, entity.categoryId);
      expect(model.amount, 999);
    });
  });
}
