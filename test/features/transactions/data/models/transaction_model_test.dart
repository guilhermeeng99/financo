import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/transaction_factory.dart';

void main() {
  group('TransactionModel', () {
    group('fromEntity', () {
      test('should create model from expense entity', () {
        final entity = TransactionFactory.expense();
        final model = TransactionModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.accountId, entity.accountId);
        expect(model.categoryId, entity.categoryId);
        expect(model.type, TransactionType.expense);
        expect(model.amount, entity.amount);
        expect(model.description, entity.description);
        expect(model.date, entity.date);
        expect(model.notes, isNull);
        expect(model.linkedTransactionId, isNull);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);
      });

      test('should create model from income entity with notes', () {
        final entity = TransactionFactory.income(notes: 'Monthly salary');
        final model = TransactionModel.fromEntity(entity);

        expect(model.type, TransactionType.income);
        expect(model.notes, 'Monthly salary');
      });

      test('should preserve linkedTransactionId for transfers', () {
        final pair = TransactionFactory.transfer();
        final model = TransactionModel.fromEntity(pair.expense);

        expect(model.linkedTransactionId, pair.income.id);
        expect(model.isTransfer, true);
      });
    });

    group('toJson', () {
      test('should serialize all fields except id', () {
        final entity = TransactionFactory.expense(notes: 'weekly');
        final model = TransactionModel.fromEntity(entity);
        final json = model.toJson();

        expect(json['userId'], 'user-1');
        expect(json['accountId'], 'acc-1');
        expect(json['categoryId'], 'cat-1');
        expect(json['type'], 'expense');
        expect(json['amount'], 150.0);
        expect(json['description'], 'Groceries');
        expect(json['date'], isA<Timestamp>());
        expect(json['notes'], 'weekly');
        expect(json['linkedTransactionId'], isNull);
        expect(json['createdAt'], isA<Timestamp>());
        expect(json['updatedAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
      });

      test('should serialize linkedTransactionId for transfers', () {
        final pair = TransactionFactory.transfer();
        final model = TransactionModel.fromEntity(pair.expense);
        final json = model.toJson();

        expect(json['linkedTransactionId'], pair.income.id);
      });
    });

    group('fromMap', () {
      test('should deserialize expense transaction', () {
        final date = DateTime(2024, 3, 15);
        final createdAt = DateTime(2024, 3, 15);
        final updatedAt = DateTime(2024, 3, 15);

        final model = TransactionModel.fromMap(
          id: 'tx-1',
          data: {
            'userId': 'user-1',
            'accountId': 'acc-1',
            'categoryId': 'cat-1',
            'type': 'expense',
            'amount': 150,
            'description': 'Groceries',
            'date': Timestamp.fromDate(date),
            'notes': null,
            'linkedTransactionId': null,
            'createdAt': Timestamp.fromDate(createdAt),
            'updatedAt': Timestamp.fromDate(updatedAt),
          },
        );

        expect(model.id, 'tx-1');
        expect(model.userId, 'user-1');
        expect(model.type, TransactionType.expense);
        expect(model.amount, 150.0);
        expect(model.notes, isNull);
        expect(model.linkedTransactionId, isNull);
        expect(model.isTransfer, false);
      });

      test('should deserialize transfer with linkedTransactionId', () {
        final model = TransactionModel.fromMap(
          id: 'tx-transfer-exp',
          data: {
            'userId': 'user-1',
            'accountId': 'acc-1',
            'categoryId': '',
            'type': 'expense',
            'amount': 500,
            'description': 'Transfer',
            'date': Timestamp.fromDate(DateTime(2024, 3, 20)),
            'notes': null,
            'linkedTransactionId': 'tx-transfer-inc',
            'createdAt': Timestamp.fromDate(DateTime(2024, 3, 20)),
            'updatedAt': Timestamp.fromDate(DateTime(2024, 3, 20)),
          },
        );

        expect(model.linkedTransactionId, 'tx-transfer-inc');
        expect(model.isTransfer, true);
        expect(model.categoryId, '');
      });

      test('should handle integer amount as double', () {
        final model = TransactionModel.fromMap(
          id: 'tx-1',
          data: {
            'userId': 'user-1',
            'accountId': 'acc-1',
            'categoryId': 'cat-1',
            'type': 'expense',
            'amount': 42,
            'description': 'Test',
            'date': Timestamp.fromDate(DateTime(2024)),
            'notes': null,
            'linkedTransactionId': null,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
            'updatedAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.amount, 42.0);
        expect(model.amount, isA<double>());
      });
    });
  });

  group('TransactionEntity', () {
    test('copyWith creates new entity with overridden fields', () {
      final original = TransactionFactory.expense();
      final updated = original.copyWith(
        description: 'Updated',
        amount: 200,
      );

      expect(updated.description, 'Updated');
      expect(updated.amount, 200);
      expect(updated.id, original.id);
      expect(updated.type, original.type);
    });

    test('isTransfer returns true when linkedTransactionId is set', () {
      final tx = TransactionFactory.expense(
        linkedTransactionId: 'tx-other',
      );
      expect(tx.isTransfer, true);
    });

    test('isTransfer returns false when linkedTransactionId is null', () {
      final tx = TransactionFactory.expense();
      expect(tx.isTransfer, false);
    });

    test('equality works via Equatable', () {
      final a = TransactionFactory.expense();
      final b = TransactionFactory.expense();
      expect(a, equals(b));
    });

    test('different entities are not equal', () {
      final a = TransactionFactory.expense();
      final b = TransactionFactory.income();
      expect(a, isNot(equals(b)));
    });
  });
}
