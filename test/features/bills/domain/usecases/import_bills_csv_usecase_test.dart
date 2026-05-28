import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/import_bills_csv_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late ImportBillsCsvUseCase useCase;
  late MockBillRepository mockBillRepository;
  late MockCategoryRepository mockCategoryRepository;

  setUpAll(() {
    registerBillFallbackValues();
    registerCategoryFallbackValues();
  });

  setUp(() {
    mockBillRepository = MockBillRepository();
    mockCategoryRepository = MockCategoryRepository();
    useCase = ImportBillsCsvUseCase(mockBillRepository, mockCategoryRepository);
  });

  const userId = 'user-1';

  // Root "Housing" with child "Internet", plus an income root, so category
  // resolution (root + parent/sub) and the unresolved path are all exercised.
  final categories = [
    CategoryFactory.expense(id: 'cat-housing', name: 'Housing'),
    CategoryFactory.subcategory(
      id: 'cat-internet',
      name: 'Internet',
      parentId: 'cat-housing',
    ),
    CategoryFactory.income(id: 'cat-salary'),
  ];

  void stubCategories() {
    when(
      () => mockCategoryRepository.getCategories(userId: userId),
    ).thenAnswer((_) async => Right<Failure, List<CategoryEntity>>(categories));
  }

  List<BillEntity> stubCreateBillCapturing() {
    final created = <BillEntity>[];
    when(() => mockBillRepository.createBill(any())).thenAnswer((
      invocation,
    ) async {
      final bill = invocation.positionalArguments.first as BillEntity;
      created.add(bill);
      return Right<Failure, BillEntity>(bill);
    });
    return created;
  }

  group('ImportBillsCsvUseCase', () {
    test('imports payable + receivable, resolving parent/sub category',
        () async {
      stubCategories();
      final created = stubCreateBillCapturing();

      const csv = '''
Type,Description,Amount,Date,Status,Recurrence,Category,Notes
Payable,Internet bill,120.00,15/05/2026,Pending,Monthly,Housing/Internet,wifi
Receivable,Paycheck,5000.00,05/05/2026,Pending,Monthly,,
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, BillImportResult>(
          BillImportResult(importedCount: 2, skippedCount: 0),
        ),
      );
      verify(() => mockBillRepository.createBill(any())).called(2);

      final byDesc = {for (final b in created) b.description: b};
      expect(byDesc['Internet bill']?.type, BillType.payable);
      expect(byDesc['Internet bill']?.recurrence, BillRecurrence.monthly);
      expect(byDesc['Internet bill']?.categoryId, 'cat-internet');
      expect(byDesc['Internet bill']?.notes, 'wifi');
      expect(byDesc['Paycheck']?.type, BillType.receivable);
      // Empty category column → imported with null category, NOT skipped.
      expect(byDesc['Paycheck']?.categoryId, isNull);
    });

    test('parses Portuguese headers, type/status/recurrence keywords',
        () async {
      stubCategories();
      final created = stubCreateBillCapturing();

      const csv = '''
Tipo,Descrição,Valor,Data,Status,Recorrência,Categoria
A Pagar,Conta de luz,200,05/05/2026,Pendente,Mensal,Housing
A Receber,Salário,3500,05/05/2026,Pendente,Única,Salary
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(result.isRight(), isTrue);
      final byDesc = {for (final b in created) b.description: b};
      expect(byDesc['Conta de luz']?.type, BillType.payable);
      expect(byDesc['Conta de luz']?.recurrence, BillRecurrence.monthly);
      expect(byDesc['Conta de luz']?.categoryId, 'cat-housing');
      expect(byDesc['Salário']?.type, BillType.receivable);
      expect(byDesc['Salário']?.recurrence, BillRecurrence.oneShot);
      expect(byDesc['Salário']?.amount, 3500);
    });

    test('counts unresolved category as skipped but still imports the bill',
        () async {
      stubCategories();
      final created = stubCreateBillCapturing();

      const csv = '''
Type,Description,Amount,Date,Category
Payable,Mystery,50,01/05/2026,DoesNotExist
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, BillImportResult>(
          BillImportResult(importedCount: 1, skippedCount: 1),
        ),
      );
      expect(created.single.categoryId, isNull);
    });

    test('paid status sets paidAt to the due date', () async {
      stubCategories();
      final created = stubCreateBillCapturing();

      const csv = '''
Type,Description,Amount,Date,Status
Payable,Settled,80,10/05/2026,Paid
''';

      await useCase(csvContent: csv, userId: userId);

      expect(created.single.status, BillStatus.paid);
      expect(created.single.paidAt, DateTime(2026, 5, 10));
    });

    test('parses BR decimal amount (comma) as the magnitude', () async {
      stubCategories();
      final created = stubCreateBillCapturing();

      const csv = '''
Type,Description,Amount,Date
Payable,Decimals,"1.234,56",10/05/2026
''';

      await useCase(csvContent: csv, userId: userId);

      expect(created.single.amount, closeTo(1234.56, 0.001));
    });

    test('rejects an unknown type keyword with row + value detail', () async {
      stubCategories();
      final created = stubCreateBillCapturing();

      const csv = '''
Type,Description,Amount,Date
Maybe,Ambiguous,10,10/05/2026
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Row 2'));
          expect(failure.message, contains('Maybe'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
      expect(created, isEmpty);
      verifyNever(() => mockBillRepository.createBill(any()));
    });

    test('rejects a zero / negative amount', () async {
      stubCategories();
      stubCreateBillCapturing();

      const csv = '''
Type,Description,Amount,Date
Payable,Free,0,10/05/2026
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Row 2'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockBillRepository.createBill(any()));
    });

    test('rejects a malformed date', () async {
      stubCategories();

      const csv = '''
Type,Description,Amount,Date
Payable,BadDate,10,2026-05-10
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Row 2'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
    });

    test('rejects an empty description', () async {
      stubCategories();

      const csv = '''
Type,Description,Amount,Date
Payable,,10,10/05/2026
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('empty'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
    });

    test('rejects a CSV missing a required column', () async {
      const csv = '''
Type,Description,Date
Payable,No amount column,10/05/2026
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('amount'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
    });

    test('rejects a header-only CSV', () async {
      const csv = 'Type,Description,Amount,Date';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(result, isA<Left<Failure, BillImportResult>>());
    });

    test('propagates a category-fetch failure', () async {
      when(
        () => mockCategoryRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Left(ServerFailure('boom')));

      const csv = '''
Type,Description,Amount,Date
Payable,X,10,10/05/2026
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) => expect(failure.message, 'boom'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns the repository failure and stops on first create error',
        () async {
      stubCategories();
      when(() => mockBillRepository.createBill(any())).thenAnswer(
        (_) async => const Left(ServerFailure('create failed')),
      );

      const csv = '''
Type,Description,Amount,Date
Payable,First,10,10/05/2026
Payable,Second,20,11/05/2026
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) => expect(failure.message, 'create failed'),
        (_) => fail('Expected failure'),
      );
      verify(() => mockBillRepository.createBill(any())).called(1);
    });
  });
}
