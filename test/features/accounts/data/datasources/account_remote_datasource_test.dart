import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/account_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AccountRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = AccountRemoteDataSourceImpl(firestore: firestore);
  });

  group('createAccount + getAccount', () {
    test('persists the model and reads it back with the generated id',
        () async {
      final model = AccountModel.fromEntity(AccountFactory.checking());

      final created = await datasource.createAccount(model);

      expect(created.id, isNotEmpty);
      expect(created.id, isNot(model.id));
      final fetched = await datasource.getAccount(created.id);
      expect(fetched.name, model.name);
      expect(fetched.type, model.type);
      expect(fetched.bank, model.bank);
      expect(fetched.initialBalance, model.initialBalance);
      expect(fetched.userId, userId);
    });

    test('round-trips credit-card-only fields', () async {
      final model = AccountModel.fromEntity(AccountFactory.creditCard());

      final created = await datasource.createAccount(model);

      final fetched = await datasource.getAccount(created.id);
      expect(fetched.creditLimit, model.creditLimit);
      expect(fetched.closingDay, model.closingDay);
      expect(fetched.dueDay, model.dueDay);
      expect(fetched.linkedAccountId, model.linkedAccountId);
    });
  });

  group('getAccounts', () {
    test("returns only the given user's accounts ordered by createdAt",
        () async {
      await datasource.createAccount(
        AccountModel.fromEntity(
          AccountFactory.checking(
            name: 'Newest',
            createdAt: DateTime(2026, 2),
          ),
        ),
      );
      await datasource.createAccount(
        AccountModel.fromEntity(
          AccountFactory.checking(
            name: 'Oldest',
            createdAt: DateTime(2026),
          ),
        ),
      );
      await datasource.createAccount(
        AccountModel.fromEntity(
          AccountFactory.checking(name: 'Foreign', userId: 'user-2'),
        ),
      );

      final accounts = await datasource.getAccounts(userId: userId);

      expect(accounts.map((a) => a.name).toList(), ['Oldest', 'Newest']);
    });

    test('returns an empty list when the user has no accounts', () async {
      expect(await datasource.getAccounts(userId: userId), isEmpty);
    });
  });

  group('updateAccount', () {
    test('overwrites the stored fields and returns the fresh doc', () async {
      final created = await datasource.createAccount(
        AccountModel.fromEntity(AccountFactory.checking()),
      );

      final updated = await datasource.updateAccount(
        AccountModel.fromEntity(
          AccountFactory.checking(id: created.id, name: 'Renamed'),
        ),
      );

      expect(updated.name, 'Renamed');
      final fetched = await datasource.getAccount(created.id);
      expect(fetched.name, 'Renamed');
    });
  });

  group('deleteAccount', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createAccount(
        AccountModel.fromEntity(AccountFactory.checking(name: 'Keep')),
      );
      final drop = await datasource.createAccount(
        AccountModel.fromEntity(AccountFactory.checking(name: 'Drop')),
      );

      await datasource.deleteAccount(drop.id);

      final remaining = await datasource.getAccounts(userId: userId);
      expect(remaining.map((a) => a.id).toList(), [keep.id]);
    });
  });
}
