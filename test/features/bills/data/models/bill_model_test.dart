import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/bills/data/models/bill_model.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillModel', () {
    final dueDate = DateTime(2026, 5, 10);
    final createdAt = DateTime(2026, 4, 1, 10);
    final updatedAt = DateTime(2026, 4, 1, 10, 5);

    test('fromMap parses all fields', () {
      final data = {
        'userId': 'user-1',
        'description': 'Internet',
        'amount': 120.5,
        'dueDate': Timestamp.fromDate(dueDate),
        'status': 'pending',
        'recurrence': 'monthly',
        'categoryId': 'cat-1',
        'notes': 'fibra',
        'paidAt': null,
        'paidTransactionId': null,
        'parentBillId': null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

      final model = BillModel.fromMap(id: 'bill-1', data: data);

      expect(model.id, 'bill-1');
      expect(model.userId, 'user-1');
      expect(model.description, 'Internet');
      expect(model.amount, 120.5);
      expect(model.dueDate, dueDate);
      expect(model.status, BillStatus.pending);
      expect(model.recurrence, BillRecurrence.monthly);
      expect(model.categoryId, 'cat-1');
      expect(model.notes, 'fibra');
      expect(model.paidAt, isNull);
      expect(model.paidTransactionId, isNull);
      expect(model.createdAt, createdAt);
    });

    test('round-trip via Firestore preserves values', () async {
      final firestore = FakeFirebaseFirestore();
      final original = BillModel(
        id: '',
        userId: 'user-1',
        description: 'Aluguel',
        amount: 1500,
        dueDate: dueDate,
        status: BillStatus.pending,
        recurrence: BillRecurrence.oneShot,
        notes: 'transferência',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final ref = await firestore.collection('bills').add(original.toJson());
      final fetched = BillModel.fromFirestore(await ref.get());

      expect(fetched.userId, 'user-1');
      expect(fetched.description, 'Aluguel');
      expect(fetched.amount, 1500);
      expect(fetched.status, BillStatus.pending);
      expect(fetched.recurrence, BillRecurrence.oneShot);
      expect(fetched.notes, 'transferência');
      expect(fetched.createdAt, createdAt);
    });

    test('paidAt is null in toJson when bill is pending', () {
      final pending = BillModel(
        id: '',
        userId: 'user-1',
        description: 'X',
        amount: 1,
        dueDate: dueDate,
        status: BillStatus.pending,
        recurrence: BillRecurrence.oneShot,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      expect(pending.toJson()['paidAt'], isNull);
    });
  });
}
