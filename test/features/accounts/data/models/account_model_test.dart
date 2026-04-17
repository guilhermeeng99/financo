import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/account_factory.dart';

void main() {
  group('AccountModel', () {
    group('fromEntity', () {
      test('should create model from checking account entity', () {
        final entity = AccountFactory.checking();
        final model = AccountModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.name, entity.name);
        expect(model.type, entity.type);
        expect(model.bank, entity.bank);
        expect(model.initialBalance, entity.initialBalance);
        expect(model.creditLimit, isNull);
        expect(model.closingDay, isNull);
        expect(model.dueDay, isNull);
        expect(model.linkedAccountId, isNull);
        expect(model.createdAt, entity.createdAt);
      });

      test('should create model from credit card entity', () {
        final entity = AccountFactory.creditCard();
        final model = AccountModel.fromEntity(entity);

        expect(model.type, AccountType.creditCard);
        expect(model.creditLimit, 5000);
        expect(model.closingDay, 3);
        expect(model.dueDay, 10);
        expect(model.linkedAccountId, 'acc-checking-1');
      });
    });

    group('toJson', () {
      test('should serialize checking account without id', () {
        final entity = AccountFactory.checking();
        final model = AccountModel.fromEntity(entity);
        final json = model.toJson();

        expect(json['userId'], 'user-1');
        expect(json['name'], 'Nubank Checking');
        expect(json['type'], 'checking');
        expect(json['bank'], 'nubank');
        expect(json['balance'], 1000.0);
        expect(json['creditLimit'], isNull);
        expect(json['closingDay'], isNull);
        expect(json['dueDay'], isNull);
        expect(json['linkedAccountId'], isNull);
        expect(json['createdAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
      });

      test('should serialize credit card with all fields', () {
        final entity = AccountFactory.creditCard();
        final model = AccountModel.fromEntity(entity);
        final json = model.toJson();

        expect(json['type'], 'creditCard');
        expect(json['creditLimit'], 5000.0);
        expect(json['closingDay'], 3);
        expect(json['dueDay'], 10);
        expect(json['linkedAccountId'], 'acc-checking-1');
      });
    });

    group('fromMap', () {
      test('should deserialize checking account', () {
        final createdAt = DateTime(2024);
        final model = AccountModel.fromMap(
          id: 'acc-1',
          data: {
            'userId': 'user-1',
            'name': 'My Account',
            'type': 'checking',
            'bank': 'nubank',
            'balance': 1500,
            'creditLimit': null,
            'closingDay': null,
            'dueDay': null,
            'linkedAccountId': null,
            'createdAt': Timestamp.fromDate(createdAt),
          },
        );

        expect(model.id, 'acc-1');
        expect(model.userId, 'user-1');
        expect(model.name, 'My Account');
        expect(model.type, AccountType.checking);
        expect(model.bank, BankType.nubank);
        expect(model.initialBalance, 1500.0);
        expect(model.creditLimit, isNull);
        expect(model.createdAt, createdAt);
      });

      test('should deserialize credit card account', () {
        final model = AccountModel.fromMap(
          id: 'acc-cc',
          data: {
            'userId': 'user-1',
            'name': 'CC',
            'type': 'creditCard',
            'bank': 'nubank',
            'balance': 200,
            'creditLimit': 3000,
            'closingDay': 5,
            'dueDay': 15,
            'linkedAccountId': 'acc-1',
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.type, AccountType.creditCard);
        expect(model.creditLimit, 3000.0);
        expect(model.closingDay, 5);
        expect(model.dueDay, 15);
        expect(model.linkedAccountId, 'acc-1');
      });

      test('should fallback to BankType.others for unknown bank', () {
        final model = AccountModel.fromMap(
          id: 'acc-1',
          data: {
            'userId': 'user-1',
            'name': 'Test',
            'type': 'checking',
            'bank': 'unknown_bank',
            'balance': 0,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.bank, BankType.others);
      });

      test('should fallback to BankType.others when bank is null', () {
        final model = AccountModel.fromMap(
          id: 'acc-1',
          data: {
            'userId': 'user-1',
            'name': 'Test',
            'type': 'checking',
            'balance': 0,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.bank, BankType.others);
      });
    });
  });

  group('AccountEntity', () {
    test('availableCredit returns creditLimit - initialBalance', () {
      final account = AccountFactory.creditCard(
        creditLimit: 8000,
        initialBalance: 3000,
      );
      expect(account.availableCredit, 5000);
    });

    test('availableCredit returns 0 for checking account', () {
      final account = AccountFactory.checking();
      expect(account.availableCredit, 0);
    });

    test('bankLabel returns human-readable label', () {
      expect(AccountFactory.checking().bankLabel, 'Nubank');
      expect(
        AccountFactory.checking(bank: BankType.others).bankLabel,
        'Others',
      );
    });

    test('copyWith creates new entity with overridden fields', () {
      final original = AccountFactory.checking();
      final updated = original.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.id, original.id);
      expect(updated.type, original.type);
    });

    test('equality works via Equatable', () {
      final a = AccountFactory.checking();
      final b = AccountFactory.checking();
      expect(a, equals(b));
    });
  });
}
