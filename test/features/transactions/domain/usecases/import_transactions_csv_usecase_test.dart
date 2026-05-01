import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late ImportTransactionsCsvUseCase useCase;
  late MockTransactionRepository mockTransactionRepo;
  late MockCategoryRepository mockCategoryRepo;
  late MockAccountRepository mockAccountRepo;

  const userId = 'user-1';

  setUpAll(() {
    registerTransactionFallbackValues();
    registerCategoryFallbackValues();
    registerAccountFallbackValues();
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockCategoryRepo = MockCategoryRepository();
    mockAccountRepo = MockAccountRepository();
    useCase = ImportTransactionsCsvUseCase(
      mockTransactionRepo,
      mockCategoryRepo,
      mockAccountRepo,
    );
  });

  final categories = [
    CategoryFactory.expense(id: 'cat-gui', name: 'Gui'),
    CategoryFactory.expense(
      id: 'cat-moradia',
      name: 'Moradia',
    ),
    CategoryFactory.subcategory(
      id: 'cat-internet',
      name: 'Internet',
      parentId: 'cat-moradia',
    ),
    CategoryFactory.subcategory(
      id: 'cat-aluguel',
      name: 'Aluguel',
      parentId: 'cat-moradia',
    ),
    CategoryFactory.expense(id: 'cat-mercado', name: 'Mercado / Almoço'),
    CategoryFactory.expense(id: 'cat-itens', name: 'Itens Pessoais'),
    CategoryFactory.expense(id: 'cat-mila', name: 'Mila'),
    CategoryFactory.expense(id: 'cat-saude', name: 'Saúde'),
    CategoryFactory.subcategory(
      id: 'cat-plano',
      name: 'Plano de saúde',
      parentId: 'cat-saude',
    ),
    CategoryFactory.subcategory(
      id: 'cat-itens-casa',
      name: 'Itens para casa',
      parentId: 'cat-moradia',
    ),
    CategoryFactory.income(id: 'cat-salary', name: 'Salário'),
  ];

  final accounts = [
    AccountFactory.checking(id: 'acc-nubank-gui', name: 'Nubank Gui'),
    AccountFactory.checking(id: 'acc-nubank-mila', name: 'Nubank Mila'),
    AccountFactory.checking(
      id: 'acc-nubank-emerg',
      name: 'Nubank Emergência',
    ),
    AccountFactory.creditCard(
      id: 'acc-cartao',
      name: 'Cartão Nubank Gui',
    ),
  ];

  void stubRepositories({
    List<CategoryEntity>? categoryList,
    List<AccountEntity>? accountList,
  }) {
    when(
      () => mockCategoryRepo.getCategories(userId: userId),
    ).thenAnswer(
      (_) async => Right(categoryList ?? categories),
    );
    when(
      () => mockAccountRepo.getAccounts(userId: userId),
    ).thenAnswer(
      (_) async => Right(accountList ?? accounts),
    );
  }

  group('ImportTransactionsCsvUseCase', () {
    group('preview', () {
      test('should parse expense rows and return preview', () async {
        stubRepositories();

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,
Despesa,01/04/2026,"-109,90",,Moradia/Internet,Nubank Gui,''';

        final result = await useCase.preview(
          csvContent: csv,
          userId: userId,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (preview) {
            expect(preview.rows.length, 2);
            expect(preview.canImport, isTrue);
            expect(preview.missingCategories, isEmpty);
            expect(preview.missingAccounts, isEmpty);
            expect(preview.skippedRows, 0);
          },
        );
      });

      test('should identify missing categories', () async {
        stubRepositories(categoryList: []);

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

        final result = await useCase.preview(
          csvContent: csv,
          userId: userId,
        );

        result.fold(
          (_) => fail('Expected Right'),
          (preview) {
            expect(preview.canImport, isFalse);
            expect(preview.missingCategories, contains('Gui'));
          },
        );
      });

      test('should identify missing accounts', () async {
        stubRepositories(accountList: []);

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

        final result = await useCase.preview(
          csvContent: csv,
          userId: userId,
        );

        result.fold(
          (_) => fail('Expected Right'),
          (preview) {
            expect(preview.canImport, isFalse);
            expect(preview.missingAccounts, contains('Nubank Gui'));
          },
        );
      });

      test(
        'should identify missing destination account for transfers',
        () async {
          stubRepositories(
            accountList: [
              AccountFactory.checking(
                id: 'acc-nubank-emerg',
                name: 'Nubank Emergência',
              ),
            ],
          );

          const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Transferência,01/04/2026,"-359,91", ,Transferência,Nubank Emergência,Nubank Gui''';

          final result = await useCase.preview(
            csvContent: csv,
            userId: userId,
          );

          result.fold(
            (_) => fail('Expected Right'),
            (preview) {
              expect(preview.canImport, isFalse);
              expect(preview.missingAccounts, contains('Nubank Gui'));
            },
          );
        },
      );

      test('should skip malformed rows', () async {
        stubRepositories();

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,
MalformedRow,only,two''';

        final result = await useCase.preview(
          csvContent: csv,
          userId: userId,
        );

        result.fold(
          (_) => fail('Expected Right'),
          (preview) {
            expect(preview.rows.length, 1);
            expect(preview.skippedRows, 1);
          },
        );
      });
    });

    group('call', () {
      test('should import expense rows and create transactions', () async {
        stubRepositories();

        var createdCount = 0;
        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          createdCount++;
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created-$createdCount'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,
Despesa,01/04/2026,"-109,90",,Moradia/Internet,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (importResult) {
            expect(importResult.importedCount, 2);
            expect(importResult.skippedCount, 0);
          },
        );
        verify(
          () => mockTransactionRepo.createTransaction(any()),
        ).called(2);
      });

      test('should parse income rows correctly', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created-1'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Receita,05/03/2026,"3000,00",Salário,Salário,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (importResult) {
            expect(importResult.importedCount, 1);
          },
        );

        final captured = verify(
          () => mockTransactionRepo.createTransaction(captureAny()),
        ).captured;
        final created = captured.first as TransactionEntity;
        expect(created.type, TransactionType.income);
        expect(created.amount, 3000);
        expect(created.categoryId, 'cat-salary');
      });

      test(
        'should parse transfer rows and create linked transactions',
        () async {
          stubRepositories();

          when(
            () => mockTransactionRepo.createTransfer(
              expense: any(named: 'expense'),
              income: any(named: 'income'),
            ),
          ).thenAnswer((_) async {
            return const Right([]);
          });

          const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Transferência,01/04/2026,"-359,91", ,Transferência,Nubank Emergência,Nubank Gui''';

          final result = await useCase(csvContent: csv, userId: userId);

          expect(result.isRight(), isTrue);
          result.fold(
            (_) => fail('Expected Right'),
            (importResult) {
              expect(importResult.importedCount, 2);
            },
          );
          verify(
            () => mockTransactionRepo.createTransfer(
              expense: any(named: 'expense'),
              income: any(named: 'income'),
            ),
          ).called(1);
        },
      );

      test('should parse pagamento rows as transfers', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransfer(
            expense: any(named: 'expense'),
            income: any(named: 'income'),
          ),
        ).thenAnswer((_) async => const Right([]));

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Pagamento,01/04/2026,"-9514,59",Pagamento cartão Cartão Nubank Gui ,Pagamento de cartão,Nubank Gui,Cartão Nubank Gui''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (importResult) {
            expect(importResult.importedCount, 2);
          },
        );
        verify(
          () => mockTransactionRepo.createTransfer(
            expense: any(named: 'expense'),
            income: any(named: 'income'),
          ),
        ).called(1);
      });

      test('should handle category/subcategory notation', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,05/04/2026,"-660,50",Gui,Saúde/Plano de saúde,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);

        final captured = verify(
          () => mockTransactionRepo.createTransaction(captureAny()),
        ).captured;
        final created = captured.first as TransactionEntity;
        expect(created.categoryId, 'cat-plano');
      });

      test(
        'should return ValidationFailure when categories are missing',
        () async {
          stubRepositories(categoryList: []);

          const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

          final result = await useCase(csvContent: csv, userId: userId);

          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ValidationFailure>()),
            (_) => fail('Expected Left'),
          );
          verifyNever(
            () => mockTransactionRepo.createTransaction(any()),
          );
        },
      );

      test(
        'should return ValidationFailure when accounts are missing',
        () async {
          stubRepositories(accountList: []);

          const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

          final result = await useCase(csvContent: csv, userId: userId);

          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ValidationFailure>()),
            (_) => fail('Expected Left'),
          );
          verifyNever(
            () => mockTransactionRepo.createTransaction(any()),
          );
        },
      );

      test(
        'should return ValidationFailure for empty CSV',
        () async {
          const csv =
              'Tipo,Data,Valor,Descrição,Categoria,'
              'Conta,Conta transferência';

          final result = await useCase(csvContent: csv, userId: userId);

          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ValidationFailure>()),
            (_) => fail('Expected Left'),
          );
        },
      );

      test('should skip malformed rows and import valid ones', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,
BadRow,only,three
Despesa,02/04/2026,"-6,81",Transferência enviada,Mila,Nubank Mila,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (importResult) {
            expect(importResult.importedCount, 2);
            expect(importResult.skippedCount, 1);
          },
        );
      });

      test('should parse Brazilian amount format correctly', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-780,50", ,Mercado / Almoço,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);

        final captured = verify(
          () => mockTransactionRepo.createTransaction(captureAny()),
        ).captured;
        final created = captured.first as TransactionEntity;
        expect(created.amount, 780.50);
      });

      test('should parse DD/MM/YYYY dates correctly', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,11/04/2026,"-30,00",Test,Itens Pessoais,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);

        final captured = verify(
          () => mockTransactionRepo.createTransaction(captureAny()),
        ).captured;
        final created = captured.first as TransactionEntity;
        expect(created.date, DateTime(2026, 4, 11));
      });

      test('should return repository failure when create fails', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('create failed')),
        );

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure.message, 'create failed'),
          (_) => fail('Expected Left'),
        );
      });

      test('should match categories case-insensitively', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created'));
        });

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,gui,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);

        final captured = verify(
          () => mockTransactionRepo.createTransaction(captureAny()),
        ).captured;
        final created = captured.first as TransactionEntity;
        expect(created.categoryId, 'cat-gui');
      });

      test('should ignore category column for transfers', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransfer(
            expense: any(named: 'expense'),
            income: any(named: 'income'),
          ),
        ).thenAnswer((_) async => const Right([]));

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Transferência,05/04/2026,"-400,00", ,Transferência,Nubank Gui,Nubank Mila''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);

        final captured = verify(
          () => mockTransactionRepo.createTransfer(
            expense: captureAny(named: 'expense'),
            income: captureAny(named: 'income'),
          ),
        ).captured;
        final expense = captured[0] as TransactionEntity;
        final income = captured[1] as TransactionEntity;
        expect(expense.categoryId, '');
        expect(income.categoryId, '');
        expect(expense.accountId, 'acc-nubank-gui');
        expect(income.accountId, 'acc-nubank-mila');
      });

      test('should handle the full sample CSV', () async {
        stubRepositories();

        when(
          () => mockTransactionRepo.createTransaction(any()),
        ).thenAnswer((invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right(tx.copyWith(id: 'created'));
        });
        when(
          () => mockTransactionRepo.createTransfer(
            expense: any(named: 'expense'),
            income: any(named: 'income'),
          ),
        ).thenAnswer((_) async => const Right([]));

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,
Despesa,01/04/2026,"-109,90",,Moradia/Internet,Nubank Gui,
Despesa,01/04/2026,"-359,91",,Itens Pessoais,Nubank Gui,
Despesa,01/04/2026,"-780,50", ,Mercado / Almoço,Nubank Gui,
Pagamento,01/04/2026,"-9514,59",Pagamento cartão Cartão Nubank Gui ,Pagamento de cartão,Nubank Gui,Cartão Nubank Gui
Transferência,01/04/2026,"-359,91", ,Transferência,Nubank Emergência,Nubank Gui
Despesa,02/04/2026,"-6,81",Transferência enviada|Josimara Araujo dos Santos - 859.970.025-19 ,Mila,Nubank Mila,
Despesa,05/04/2026,"-2000,00",,Moradia/Aluguel,Nubank Gui,
Despesa,05/04/2026,"-660,50",Gui,Saúde/Plano de saúde,Nubank Gui,
Despesa,05/04/2026,"-660,50",Mila,Saúde/Plano de saúde,Nubank Gui,
Transferência,05/04/2026,"-400,00", ,Transferência,Nubank Gui,Nubank Mila
Despesa,05/04/2026,"-12,50",Transferência enviada|Tatiana Teixeira Guimaraes Dias - Tatiana Teixeira Guimaraes Dias - 016.137.115-90 ,Mila,Nubank Mila,
Despesa,08/04/2026,"-80,00",Transferência enviada|Diomarcos Barbosa Dos Santos - 030.347.325-89 ,Moradia/Itens para casa,Nubank Gui,
Despesa,09/04/2026,"-29,00",Transferência enviada|Tatiana Teixeira Guimaraes Dias - Tatiana Teixeira Guimaraes Dias - 016.137.115-90 ,Gui,Nubank Mila,
Despesa,11/04/2026,"-30,00",Transferência enviada|André Luis Pereira dos Santos - 799.133.345-00 ,Itens Pessoais,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (importResult) {
            // 12 expenses + 3 transfers (2 txs each) = 18
            expect(importResult.importedCount, 18);
            expect(importResult.skippedCount, 0);
          },
        );

        // 12 individual createTransaction calls
        verify(
          () => mockTransactionRepo.createTransaction(any()),
        ).called(12);
        // 3 createTransfer calls (1 Pagamento + 2 Transferência)
        verify(
          () => mockTransactionRepo.createTransfer(
            expense: any(named: 'expense'),
            income: any(named: 'income'),
          ),
        ).called(3);
      });

      test(
        'should return ValidationFailure for CSV with only header',
        () async {
          const csv =
              'Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência\n';

          final result = await useCase(csvContent: csv, userId: userId);

          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ValidationFailure>()),
            (_) => fail('Expected Left'),
          );
        },
      );

      test('should return failure when category repo fails', () async {
        when(
          () => mockCategoryRepo.getCategories(userId: userId),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('category fetch failed')),
        );
        when(
          () => mockAccountRepo.getAccounts(userId: userId),
        ).thenAnswer(
          (_) async => Right(accounts),
        );

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure.message, 'category fetch failed'),
          (_) => fail('Expected Left'),
        );
      });

      test('should return failure when account repo fails', () async {
        when(
          () => mockCategoryRepo.getCategories(userId: userId),
        ).thenAnswer(
          (_) async => Right(categories),
        );
        when(
          () => mockAccountRepo.getAccounts(userId: userId),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('account fetch failed')),
        );

        const csv = '''
Tipo,Data,Valor,Descrição,Categoria,Conta,Conta transferência
Despesa,01/04/2026,"-9,99",,Gui,Nubank Gui,''';

        final result = await useCase(csvContent: csv, userId: userId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure.message, 'account fetch failed'),
          (_) => fail('Expected Left'),
        );
      });
    });
  });

  group('ImportTransactionsCsvUseCase.importRows', () {
    setUp(() {
      when(() => mockCategoryRepo.getCategories(userId: userId))
          .thenAnswer((_) async => Right(categories));
      when(() => mockAccountRepo.getAccounts(userId: userId))
          .thenAnswer((_) async => Right(accounts));
    });

    test('creates expense and income rows using user-edited names', () async {
      when(() => mockTransactionRepo.createTransaction(any())).thenAnswer(
        (invocation) async {
          final tx = invocation.positionalArguments.first as TransactionEntity;
          return Right<Failure, TransactionEntity>(
            tx.copyWith(id: 'tx-${tx.description}'),
          );
        },
      );

      final rows = [
        TransactionImportRow(
          csvType: CsvTransactionType.despesa,
          amount: 12.50,
          description: 'edited expense',
          date: DateTime(2026, 4),
          accountName: 'Nubank Gui',
          categoryName: 'Gui',
        ),
        TransactionImportRow(
          csvType: CsvTransactionType.receita,
          amount: 1000,
          description: 'salary',
          date: DateTime(2026, 4, 5),
          accountName: 'Nubank Gui',
          categoryName: 'Salário',
        ),
      ];

      final result = await useCase.importRows(
        rows: rows,
        userId: userId,
        skippedCount: 3,
      );

      expect(
        result,
        const Right<Failure, TransactionImportResult>(
          TransactionImportResult(importedCount: 2, skippedCount: 3),
        ),
      );
      verify(() => mockTransactionRepo.createTransaction(any())).called(2);
    });

    test('skips rows whose account is not found in the latest state',
        () async {
      when(() => mockTransactionRepo.createTransaction(any())).thenAnswer(
        (_) async => Right<Failure, TransactionEntity>(
          TransactionEntity(
            id: 'x',
            userId: userId,
            accountId: 'acc-nubank-gui',
            categoryId: 'cat-gui',
            type: TransactionType.expense,
            amount: 1,
            description: '',
            date: DateTime(2026, 4),
            createdAt: DateTime(2026, 4),
            updatedAt: DateTime(2026, 4),
          ),
        ),
      );

      final rows = [
        TransactionImportRow(
          csvType: CsvTransactionType.despesa,
          amount: 10,
          description: '',
          date: DateTime(2026, 4),
          accountName: 'Ghost Account',
          categoryName: 'Gui',
        ),
      ];

      final result = await useCase.importRows(
        rows: rows,
        userId: userId,
      );

      expect(
        result,
        const Right<Failure, TransactionImportResult>(
          TransactionImportResult(importedCount: 0, skippedCount: 0),
        ),
      );
      verifyNever(() => mockTransactionRepo.createTransaction(any()));
    });
  });
}
