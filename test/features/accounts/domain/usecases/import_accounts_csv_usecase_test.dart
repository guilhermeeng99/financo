import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late ImportAccountsCsvUseCase useCase;
  late MockAccountRepository mockRepository;

  setUpAll(registerAccountFallbackValues);

  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = ImportAccountsCsvUseCase(mockRepository);
  });

  const userId = 'user-1';

  group('ImportAccountsCsvUseCase.preview', () {
    test('parses checking and credit card rows from CSV', () async {
      when(() => mockRepository.getAccounts(userId: userId))
          .thenAnswer((_) async => const Right([]));

      const csv = '''
Nome,Saldo inicial,Tipo,Banco,Limite,Próximo Vencimento,Fechamento
Nubank Gui,0,Conta Corrente,nubank,,,
Nu Invest,"421,95",Conta Corrente,nubank,,,
Cartão Nubank Gui,0,Cartão de Crédito,nubank,4450,08/05/2026,7
''';

      final result = await useCase.preview(
        csvContent: csv,
        userId: userId,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (preview) {
        expect(preview.toCreate, hasLength(3));
        expect(preview.duplicates, isEmpty);

        final invest = preview.toCreate[1];
        expect(invest.name, 'Nu Invest');
        expect(invest.initialBalance, closeTo(421.95, 0.001));

        final card = preview.toCreate[2];
        expect(card.type, AccountType.creditCard);
        expect(card.creditLimit, 4450);
        expect(card.dueDay, 8);
        expect(card.closingDay, 7);
      });
    });

    test('marks accounts with the same name as duplicates', () async {
      when(() => mockRepository.getAccounts(userId: userId)).thenAnswer(
        (_) async => Right([
          AccountFactory.checking(id: 'a-1', name: 'Nubank Gui'),
        ]),
      );

      const csv = '''
Nome,Saldo inicial,Tipo,Banco,Limite,Próximo Vencimento,Fechamento
Nubank Gui,0,Conta Corrente,nubank,,,
Nubank Mila,0,Conta Corrente,nubank,,,
''';

      final result = await useCase.preview(
        csvContent: csv,
        userId: userId,
      );

      result.fold((_) => fail('Expected Right'), (preview) {
        expect(preview.toCreate.map((it) => it.name), ['Nubank Mila']);
        expect(preview.duplicates.map((it) => it.name), ['Nubank Gui']);
      });
    });

    test('returns ValidationFailure for invalid csv', () async {
      const csv = 'Nome,Saldo inicial,Tipo,Banco';

      final result = await useCase.preview(
        csvContent: csv,
        userId: userId,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
    });
  });

  group('ImportAccountsCsvUseCase.importItems', () {
    test(
      'creates checking accounts first then credit cards linked by name',
      () async {
        when(() => mockRepository.getAccounts(userId: userId))
            .thenAnswer((_) async => const Right([]));

        var createdCount = 0;
        when(() => mockRepository.createAccount(any())).thenAnswer((
          invocation,
        ) async {
          final account =
              invocation.positionalArguments.first as AccountEntity;
          createdCount++;
          return Right<Failure, AccountEntity>(
            account.copyWith(id: 'created-$createdCount'),
          );
        });

        const items = [
          AccountImportPreviewItem(
            name: 'Cartão Gui',
            type: AccountType.creditCard,
            bank: BankType.nubank,
            initialBalance: 0,
            creditLimit: 1000,
            closingDay: 7,
            dueDay: 14,
            linkedAccountName: 'Nubank Gui',
          ),
          AccountImportPreviewItem(
            name: 'Nubank Gui',
            type: AccountType.checking,
            bank: BankType.nubank,
            initialBalance: 100,
          ),
        ];

        final created = <AccountEntity>[];
        when(() => mockRepository.createAccount(any())).thenAnswer((
          invocation,
        ) async {
          final account =
              invocation.positionalArguments.first as AccountEntity;
          created.add(account);
          return Right<Failure, AccountEntity>(
            account.copyWith(id: 'created-${created.length}'),
          );
        });

        final result = await useCase.importItems(
          items: items,
          userId: userId,
        );

        expect(
          result,
          const Right<Failure, AccountImportResult>(
            AccountImportResult(importedCount: 2, duplicateCount: 0),
          ),
        );
        // Checking account created first.
        expect(created[0].type, AccountType.checking);
        expect(created[0].name, 'Nubank Gui');
        // Then the credit card, linked to the just-created checking ID.
        expect(created[1].type, AccountType.creditCard);
        expect(created[1].linkedAccountId, 'created-1');
      },
    );

    test('skips credit cards whose linked account cannot be resolved',
        () async {
      when(() => mockRepository.getAccounts(userId: userId))
          .thenAnswer((_) async => const Right([]));

      when(() => mockRepository.createAccount(any())).thenAnswer((
        invocation,
      ) async {
        final account = invocation.positionalArguments.first as AccountEntity;
        return Right<Failure, AccountEntity>(
          account.copyWith(id: 'created-x'),
        );
      });

      const items = [
        AccountImportPreviewItem(
          name: 'Cartão Órfão',
          type: AccountType.creditCard,
          bank: BankType.nubank,
          initialBalance: 0,
          creditLimit: 1000,
          closingDay: 7,
          dueDay: 14,
          linkedAccountName: 'Inexistente',
        ),
      ];

      final result = await useCase.importItems(
        items: items,
        userId: userId,
      );

      expect(
        result,
        const Right<Failure, AccountImportResult>(
          AccountImportResult(importedCount: 0, duplicateCount: 0),
        ),
      );
      verifyNever(() => mockRepository.createAccount(any()));
    });
  });
}
