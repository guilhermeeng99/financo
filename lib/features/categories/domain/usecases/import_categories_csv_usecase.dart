import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';

class CategoryImportPreviewItem extends Equatable {
  const CategoryImportPreviewItem({
    required this.name,
    required this.type,
    this.parentName,
  });

  final String name;
  final CategoryType type;
  final String? parentName;

  bool get isSubcategory => parentName != null;

  @override
  List<Object?> get props => [name, type, parentName];
}

class CategoryImportPreview extends Equatable {
  const CategoryImportPreview({
    required this.toCreate,
    required this.duplicates,
  });

  final List<CategoryImportPreviewItem> toCreate;
  final List<CategoryImportPreviewItem> duplicates;

  @override
  List<Object?> get props => [toCreate, duplicates];
}

class CategoryImportResult extends Equatable {
  const CategoryImportResult({
    required this.importedCount,
    required this.duplicateCount,
  });

  final int importedCount;
  final int duplicateCount;

  @override
  List<Object?> get props => [importedCount, duplicateCount];
}

class ImportCategoriesCsvUseCase {
  const ImportCategoriesCsvUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, CategoryImportPreview>> preview({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final parsedItems = _parseCsv(csvContent);
      final existingResult = await _repository.getCategories(userId: userId);

      return existingResult.fold(
        Left.new,
        (existingCategories) => Right(
          _buildPreview(parsedItems, existingCategories),
        ),
      );
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to import categories.'));
    }
  }

  Future<Either<Failure, CategoryImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    final previewResult = await preview(csvContent: csvContent, userId: userId);

    Failure? previewFailure;
    CategoryImportPreview? previewValue;
    previewResult.fold<void>(
      (failure) => previewFailure = failure,
      (value) => previewValue = value,
    );

    if (previewFailure != null) {
      return Left(previewFailure!);
    }

    final previewData = previewValue!;
    final existingResult = await _repository.getCategories(userId: userId);

    Failure? existingFailure;
    List<CategoryEntity>? existingCategories;
    existingResult.fold(
      (failure) => existingFailure = failure,
      (categories) => existingCategories = categories,
    );

    if (existingFailure != null) {
      return Left(existingFailure!);
    }

    final existingRoots = <String, String>{};
    for (final category in existingCategories!.where(
      (c) => c.parentId == null,
    )) {
      existingRoots[_rootKey(category.name, category.type)] = category.id;
    }

    var importedCount = 0;
    final rootsToCreate = previewData.toCreate.where(
      (item) => !item.isSubcategory,
    );
    final childrenToCreate = previewData.toCreate.where(
      (item) => item.isSubcategory,
    );

    for (final item in rootsToCreate) {
      final result = await _repository.createCategory(
        CategoryEntity(
          id: '',
          userId: userId,
          name: item.name,
          icon: 58332,
          color: 4280391411,
          type: item.type,
        ),
      );

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);

      result.fold((_) {}, (created) {
        existingRoots[_rootKey(item.name, item.type)] = created.id;
        importedCount++;
      });
    }

    for (final item in childrenToCreate) {
      final parentKey = _rootKey(item.parentName!, item.type);
      final parentId = existingRoots[parentKey];
      if (parentId == null) continue;

      final result = await _repository.createCategory(
        CategoryEntity(
          id: '',
          userId: userId,
          name: item.name,
          icon: 58332,
          color: 4280391411,
          type: item.type,
          parentId: parentId,
        ),
      );

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);

      result.fold((_) {}, (_) => importedCount++);
    }

    return Right(
      CategoryImportResult(
        importedCount: importedCount,
        duplicateCount: previewData.duplicates.length,
      ),
    );
  }

  List<CategoryImportPreviewItem> _parseCsv(String csvContent) {
    final rows = Csv().decode(csvContent);
    if (rows.length < 2) {
      throw const FormatException('CSV file is empty or invalid.');
    }

    final items = <CategoryImportPreviewItem>[];
    for (final row in rows.skip(1)) {
      if (row.length < 3) continue;

      final category = '${row[0] ?? ''}'.trim();
      final subcategory = '${row[1] ?? ''}'.trim();
      final typeStr = '${row[2] ?? ''}'.trim().toLowerCase();

      if (category.isEmpty) continue;

      final type = typeStr == 'income'
          ? CategoryType.income
          : CategoryType.expense;

      items.add(CategoryImportPreviewItem(name: category, type: type));

      if (subcategory.isNotEmpty) {
        items.add(
          CategoryImportPreviewItem(
            name: subcategory,
            type: type,
            parentName: category,
          ),
        );
      }
    }

    if (items.isEmpty) {
      throw const FormatException('CSV file has no valid categories.');
    }

    return items;
  }

  CategoryImportPreview _buildPreview(
    List<CategoryImportPreviewItem> parsedItems,
    List<CategoryEntity> existingCategories,
  ) {
    final byId = {
      for (final category in existingCategories) category.id: category,
    };
    final existingKeys = <String>{};

    for (final category in existingCategories) {
      if (category.parentId == null) {
        existingKeys.add(_rootKey(category.name, category.type));
      } else {
        final parent = byId[category.parentId];
        if (parent != null) {
          existingKeys.add(
            _childKey(parent.name, category.name, category.type),
          );
        }
      }
    }

    final seenKeys = <String>{};
    final toCreate = <CategoryImportPreviewItem>[];
    final duplicates = <CategoryImportPreviewItem>[];

    for (final item in parsedItems) {
      final key = item.isSubcategory
          ? _childKey(item.parentName!, item.name, item.type)
          : _rootKey(item.name, item.type);

      if (existingKeys.contains(key) || !seenKeys.add(key)) {
        duplicates.add(item);
      } else {
        toCreate.add(item);
      }
    }

    return CategoryImportPreview(toCreate: toCreate, duplicates: duplicates);
  }

  String _rootKey(String name, CategoryType type) =>
      'root:${type.name}:${name.trim().toLowerCase()}';

  String _childKey(String parentName, String name, CategoryType type) =>
      'child:${type.name}:${parentName.trim().toLowerCase()}:'
      '${name.trim().toLowerCase()}';
}
