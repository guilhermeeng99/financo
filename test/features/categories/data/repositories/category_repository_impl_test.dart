import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/categories/data/repositories/category_repository_impl.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryRemoteDataSource mockRemote;
  late MockCategoriesDao mockDao;

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockRemote = MockCategoryRemoteDataSource();
    mockDao = MockCategoriesDao();
    repository = CategoryRepositoryImpl(
      remoteDataSource: mockRemote,
      categoriesDao: mockDao,
    );
  });

  const userId = 'user-1';

  group('getCategories', () {
    test('should return local cache when forceRefresh is false', () async {
      final categories = CategoryFactory.list();
      when(() => mockDao.getCategories(userId))
          .thenAnswer((_) async => categories);

      final result = await repository.getCategories(userId: userId);

      expect(
        result,
        Right<Failure, List<CategoryEntity>>(categories),
      );
      verify(() => mockDao.getCategories(userId)).called(1);
      verifyNever(() => mockRemote.getCategories(userId: any(named: 'userId')));
    });

    test(
      'should fetch from remote and replace local cache when forceRefresh',
      () async {
        final remoteCategories = [
          CategoryModel.fromEntity(CategoryFactory.expense()),
        ];
        final localCategories = [CategoryFactory.expense()];

        when(() => mockRemote.getCategories(userId: userId))
            .thenAnswer((_) async => remoteCategories);
        when(() => mockDao.deleteAllCategories()).thenAnswer((_) async {});
        when(() => mockDao.insertAllCategories(any())).thenAnswer((_) async {});
        when(() => mockDao.getCategories(userId))
            .thenAnswer((_) async => localCategories);

        final result = await repository.getCategories(
          userId: userId,
          forceRefresh: true,
        );

        expect(
          result,
          Right<Failure, List<CategoryEntity>>(localCategories),
        );
        verify(() => mockRemote.getCategories(userId: userId)).called(1);
        verify(() => mockDao.deleteAllCategories()).called(1);
        verify(() => mockDao.insertAllCategories(remoteCategories)).called(1);
      },
    );

    test(
      'should clear cache and not insert when remote returns empty',
      () async {
        when(() => mockRemote.getCategories(userId: userId))
            .thenAnswer((_) async => []);
        when(() => mockDao.deleteAllCategories()).thenAnswer((_) async {});
        when(() => mockDao.getCategories(userId))
            .thenAnswer((_) async => []);

        final result = await repository.getCategories(
          userId: userId,
          forceRefresh: true,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) {}, (categories) => expect(categories, isEmpty));
        verify(() => mockDao.deleteAllCategories()).called(1);
        verifyNever(() => mockDao.insertAllCategories(any()));
      },
    );

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.getCategories(userId: userId))
          .thenThrow(const ServerException());
      when(() => mockDao.getCategories(userId))
          .thenAnswer((_) async => []);

      final result = await repository.getCategories(
        userId: userId,
        forceRefresh: true,
      );

      expect(result, isA<Left<Failure, List<CategoryEntity>>>());
    });
  });

  group('createCategory', () {
    test('should create remotely and upsert locally', () async {
      final category = CategoryFactory.expense();
      final model = CategoryModel.fromEntity(category);

      when(() => mockRemote.createCategory(any()))
          .thenAnswer((_) async => model);
      when(() => mockDao.upsertCategory(any())).thenAnswer((_) async {});

      final result = await repository.createCategory(category);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.createCategory(any())).called(1);
      verify(() => mockDao.upsertCategory(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      final category = CategoryFactory.expense();

      when(() => mockRemote.createCategory(any()))
          .thenThrow(const ServerException('Failed to create category.'));

      final result = await repository.createCategory(category);

      expect(result, isA<Left<Failure, CategoryEntity>>());
      verifyNever(() => mockDao.upsertCategory(any()));
    });
  });

  group('updateCategory', () {
    test('should update remotely and upsert locally', () async {
      final category = CategoryFactory.expense(name: 'Updated');
      final model = CategoryModel.fromEntity(category);

      when(() => mockRemote.updateCategory(any()))
          .thenAnswer((_) async => model);
      when(() => mockDao.upsertCategory(any())).thenAnswer((_) async {});

      final result = await repository.updateCategory(category);

      expect(result.isRight(), isTrue);
      verify(() => mockRemote.updateCategory(any())).called(1);
      verify(() => mockDao.upsertCategory(model)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      final category = CategoryFactory.expense();

      when(() => mockRemote.updateCategory(any()))
          .thenThrow(const ServerException('Failed to update category.'));

      final result = await repository.updateCategory(category);

      expect(result, isA<Left<Failure, CategoryEntity>>());
      verifyNever(() => mockDao.upsertCategory(any()));
    });
  });

  group('deleteCategory', () {
    const categoryId = 'cat-1';

    test('should delete remotely and locally', () async {
      when(() => mockRemote.deleteCategory(any()))
          .thenAnswer((_) async {});
      when(() => mockDao.deleteCategory(any())).thenAnswer((_) async {});

      final result = await repository.deleteCategory(categoryId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.deleteCategory(categoryId)).called(1);
      verify(() => mockDao.deleteCategory(categoryId)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.deleteCategory(any()))
          .thenThrow(const ServerException('Failed to delete category.'));

      final result = await repository.deleteCategory(categoryId);

      expect(result, isA<Left<Failure, void>>());
      verifyNever(() => mockDao.deleteCategory(any()));
    });
  });
}
