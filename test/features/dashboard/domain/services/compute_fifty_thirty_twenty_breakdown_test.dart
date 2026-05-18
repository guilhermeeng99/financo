import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';

void main() {
  final needsCat = CategoryFactory.expense(id: 'cat-needs').copyWith(
    bucket: CategoryBucket.needs,
  );
  final wantsCat = CategoryFactory.expense(id: 'cat-wants').copyWith(
    bucket: CategoryBucket.wants,
  );
  final unsetCat = CategoryFactory.expense(id: 'cat-unset');
  final subOfNeeds = CategoryFactory.subcategory(
    id: 'sub-of-needs',
    parentId: needsCat.id,
  );

  test('groups expenses by bucket', () {
    final out = compute50_30_20Breakdown(
      periodTransactions: [
        TransactionFactory.expense(
          id: 'tx-1',
          amount: 200,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-2',
          amount: 50,
          categoryId: wantsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-3',
          amount: 80,
          categoryId: unsetCat.id,
        ),
      ],
      categories: [needsCat, wantsCat, unsetCat],
    );

    expect(out.needs.length, 1);
    expect(out.needs.first.amount, 200);
    expect(out.wants.length, 1);
    expect(out.wants.first.amount, 50);
    expect(out.unclassified.length, 1);
    expect(out.unclassified.first.amount, 80);
  });

  test('subcategory rolls up into the parent root row', () {
    final out = compute50_30_20Breakdown(
      periodTransactions: [
        TransactionFactory.expense(
          id: 'tx-1',
          amount: 100,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-2',
          amount: 70,
          categoryId: subOfNeeds.id,
        ),
      ],
      categories: [needsCat, subOfNeeds],
    );

    expect(out.needs.length, 1);
    expect(out.needs.first.categoryId, needsCat.id);
    expect(out.needs.first.amount, 170);
  });

  test('rows sorted by amount descending', () {
    final big = CategoryFactory.expense(id: 'big').copyWith(
      bucket: CategoryBucket.needs,
    );
    final small = CategoryFactory.expense(id: 'small').copyWith(
      bucket: CategoryBucket.needs,
    );
    final out = compute50_30_20Breakdown(
      periodTransactions: [
        TransactionFactory.expense(
          id: 'tx-1',
          amount: 11,
          categoryId: small.id,
        ),
        TransactionFactory.expense(
          id: 'tx-2',
          amount: 500,
          categoryId: big.id,
        ),
      ],
      categories: [big, small],
    );
    expect(
      out.needs.map((r) => r.categoryId).toList(),
      [big.id, small.id],
    );
  });

  test('transfers and income transactions are ignored', () {
    final transfer = TransactionFactory.transfer(
      sourceAccountId: 'src',
      destinationAccountId: 'dst',
    );
    final out = compute50_30_20Breakdown(
      periodTransactions: [
        TransactionFactory.income(
          id: 'tx-inc',
          amount: 1000,
          categoryId: 'inc',
        ),
        transfer.expense,
        transfer.income,
      ],
      categories: [needsCat, wantsCat],
    );
    expect(out.needs, isEmpty);
    expect(out.wants, isEmpty);
    expect(out.unclassified, isEmpty);
  });
}
