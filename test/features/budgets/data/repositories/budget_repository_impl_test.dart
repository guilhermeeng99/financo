import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';
import 'package:financo/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBudgetRemoteDataSource remote;
  late MockBudgetsDao dao;
  late BudgetRepositoryImpl repository;

  setUpAll(registerBudgetFallbackValues);

  setUp(() {
    remote = MockBudgetRemoteDataSource();
    dao = MockBudgetsDao();
    repository = BudgetRepositoryImpl(
      remoteDataSource: remote,
      budgetsDao: dao,
    );
    when(() => dao.upsertBudget(any())).thenAnswer((_) async {});
    when(() => dao.insertAllBudgets(any())).thenAnswer((_) async {});
    when(() => dao.deleteBudget(any())).thenAnswer((_) async {});
  });

  group('getBudgets', () {
    test('returns local cache when forceRefresh is false', () async {
      final budgets = [BudgetFactory.make()];
      when(
        () => dao.getBudgets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => budgets);

      final result = await repository.getBudgets(userId: 'u1');

      expect(result.isRight(), isTrue);
      verifyNever(() => remote.getBudgets(userId: any(named: 'userId')));
    });

    test('refreshes from remote when forceRefresh is true', () async {
      final remoteList = <BudgetModel>[
        BudgetModel.fromEntity(BudgetFactory.make()),
      ];
      when(
        () => remote.getBudgets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => remoteList);
      when(
        () => dao.getBudgets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => [BudgetFactory.make()]);

      final result = await repository.getBudgets(
        userId: 'u1',
        forceRefresh: true,
      );

      expect(result.isRight(), isTrue);
      verify(() => remote.getBudgets(userId: 'u1')).called(1);
      verify(() => dao.insertAllBudgets(remoteList)).called(1);
    });

    test('translates ServerException to ServerFailure', () async {
      when(
        () => remote.getBudgets(userId: any(named: 'userId')),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.getBudgets(
        userId: 'u1',
        forceRefresh: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('createBudget', () {
    test('rejects duplicates by (userId, categoryId)', () async {
      final existing = BudgetFactory.make(
        id: 'existing',
        categoryId: 'cat-food',
      );
      when(
        () => dao.getBudgets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => [existing]);

      final newBudget = BudgetFactory.make(
        id: '',
        categoryId: 'cat-food',
        amount: 999,
      );
      final result = await repository.createBudget(newBudget);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => remote.createBudget(any()));
    });

    test('writes to remote and upserts locally on success', () async {
      when(
        () => dao.getBudgets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const []);
      final input = BudgetFactory.make(id: '', categoryId: 'cat-new');
      final created = BudgetModel.fromEntity(
        input.copyWith(id: 'srv-id'),
      );
      when(() => remote.createBudget(any())).thenAnswer((_) async => created);

      final result = await repository.createBudget(input);

      expect(result.isRight(), isTrue);
      verify(() => remote.createBudget(any())).called(1);
      verify(() => dao.upsertBudget(created)).called(1);
    });

    test('returns ServerFailure when remote create fails', () async {
      when(
        () => dao.getBudgets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const []);
      when(
        () => remote.createBudget(any()),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.createBudget(BudgetFactory.make(id: ''));
      expect(result.isLeft(), isTrue);
    });
  });

  group('updateBudget', () {
    test('writes to remote and upserts locally', () async {
      final input = BudgetFactory.make(amount: 2000);
      final saved = BudgetModel.fromEntity(input);
      when(() => remote.updateBudget(any())).thenAnswer((_) async => saved);

      final result = await repository.updateBudget(input);

      expect(result.isRight(), isTrue);
      verify(() => remote.updateBudget(any())).called(1);
      verify(() => dao.upsertBudget(saved)).called(1);
    });

    test('does NOT re-validate uniqueness on update', () async {
      // categoryId is immutable, so duplicate-check on update is unnecessary
      // (and would break if the entity is being re-saved with the same key).
      final saved = BudgetModel.fromEntity(BudgetFactory.make());
      when(() => remote.updateBudget(any())).thenAnswer((_) async => saved);

      await repository.updateBudget(BudgetFactory.make());

      verifyNever(() => dao.getBudgets(userId: any(named: 'userId')));
    });
  });

  group('deleteBudget', () {
    test('deletes remote then local', () async {
      when(() => remote.deleteBudget(any())).thenAnswer((_) async {});

      final result = await repository.deleteBudget('b1');

      expect(result.isRight(), isTrue);
      verify(() => remote.deleteBudget('b1')).called(1);
      verify(() => dao.deleteBudget('b1')).called(1);
    });

    test('returns ServerFailure when remote delete fails', () async {
      when(
        () => remote.deleteBudget(any()),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.deleteBudget('b1');
      expect(result.isLeft(), isTrue);
    });
  });
}
