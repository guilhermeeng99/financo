import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class CategoryImportPreviewItem extends Equatable {
  const CategoryImportPreviewItem({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.parentName,
  });

  final String name;
  final CategoryType type;
  final int icon;
  final int color;
  final String? parentName;

  bool get isSubcategory => parentName != null;

  CategoryImportPreviewItem copyWith({
    String? name,
    CategoryType? type,
    int? icon,
    int? color,
    String? parentName,
  }) {
    return CategoryImportPreviewItem(
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentName: parentName ?? this.parentName,
    );
  }

  @override
  List<Object?> get props => [name, type, icon, color, parentName];
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

/// Default Material icon code point (shopping_cart) — same default as the
/// category form, so freshly parsed CSV rows show a recognizable icon while
/// the user reviews the import.
const int _defaultIcon = 58332;

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

    return importItems(
      items: previewValue!.toCreate,
      userId: userId,
      duplicateCount: previewValue!.duplicates.length,
    );
  }

  /// Creates the [items] as categories under [userId] in dependency order
  /// (roots first, then children). Each item's `icon`/`color` are used
  /// verbatim — letting the import-preview page expose per-item editing.
  ///
  /// Children whose parent is missing (deleted from the preview before
  /// import) are silently skipped, matching the CSV-only flow.
  ///
  /// [onProgress] is called after each item has been processed (created or
  /// skipped) with `(processedCount, total)` so the caller can render a
  /// determinate progress UI. The callback is invoked synchronously between
  /// awaits, so emitting cubit state from inside it is safe.
  Future<Either<Failure, CategoryImportResult>> importItems({
    required List<CategoryImportPreviewItem> items,
    required String userId,
    int duplicateCount = 0,
    void Function(int processed, int total)? onProgress,
  }) async {
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

    final total = items.length;
    var processed = 0;
    var importedCount = 0;
    final rootsToCreate = items.where((item) => !item.isSubcategory);
    final childrenToCreate = items.where((item) => item.isSubcategory);

    for (final item in rootsToCreate) {
      final result = await _repository.createCategory(
        CategoryEntity(
          id: '',
          userId: userId,
          name: item.name,
          icon: item.icon,
          color: item.color,
          type: item.type,
        ),
      );

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);

      result.fold((_) {}, (created) {
        existingRoots[_rootKey(item.name, item.type)] = created.id;
        importedCount++;
      });
      processed++;
      onProgress?.call(processed, total);
    }

    for (final item in childrenToCreate) {
      final parentKey = _rootKey(item.parentName!, item.type);
      final parentId = existingRoots[parentKey];
      if (parentId == null) {
        processed++;
        onProgress?.call(processed, total);
        continue;
      }

      final result = await _repository.createCategory(
        CategoryEntity(
          id: '',
          userId: userId,
          name: item.name,
          icon: item.icon,
          color: item.color,
          type: item.type,
          parentId: parentId,
        ),
      );

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return Left(failure);

      result.fold((_) {}, (_) => importedCount++);
      processed++;
      onProgress?.call(processed, total);
    }

    return Right(
      CategoryImportResult(
        importedCount: importedCount,
        duplicateCount: duplicateCount,
      ),
    );
  }

  List<CategoryImportPreviewItem> _parseCsv(String csvContent) {
    final rows = Csv().decode(csvContent);
    if (rows.length < 2) {
      throw FormatException(t.csvImport.errors.emptyFile);
    }

    final items = <CategoryImportPreviewItem>[];
    final seenRoots = <String>{};
    var colorIndex = 0;
    var rowNumber = 1; // header row
    for (final row in rows.skip(1)) {
      rowNumber++;
      if (row.length < 3) continue;

      final category = '${row[0] ?? ''}'.trim();
      final subcategory = '${row[1] ?? ''}'.trim();
      final typeStr = '${row[2] ?? ''}'.trim();

      if (category.isEmpty) continue;

      final type = _parseType(typeStr, rowNumber);

      final rootKey = '${type.name}:${category.toLowerCase()}';
      if (seenRoots.add(rootKey)) {
        items.add(
          CategoryImportPreviewItem(
            name: category,
            type: type,
            icon: _defaultIcon,
            color: CategoryColors.forIndex(colorIndex++),
          ),
        );
      }

      if (subcategory.isNotEmpty) {
        items.add(
          CategoryImportPreviewItem(
            name: subcategory,
            type: type,
            parentName: category,
            icon: _defaultIcon,
            color: CategoryColors.forIndex(colorIndex++),
          ),
        );
      }
    }

    if (items.isEmpty) {
      throw FormatException(t.csvImport.errors.noValidCategories);
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

  /// Maps a type column value to [CategoryType]. Accepts English
  /// (`income`/`expense`) and Portuguese (`receita`/`despesa`) so users can
  /// import CSVs exported in either language. Empty or unrecognized values
  /// raise a [FormatException] tagged with the offending [csvRow] so the UI
  /// can point the user to the exact row to fix.
  CategoryType _parseType(String raw, int csvRow) {
    switch (raw.toLowerCase()) {
      case 'income':
      case 'receita':
        return CategoryType.income;
      case 'expense':
      case 'despesa':
        return CategoryType.expense;
    }
    if (raw.isEmpty) {
      throw FormatException(
        t.csvImport.errors.categoryTypeEmpty(row: csvRow),
      );
    }
    throw FormatException(
      t.csvImport.errors.categoryTypeInvalid(row: csvRow, value: raw),
    );
  }

  String _rootKey(String name, CategoryType type) =>
      'root:${type.name}:${name.trim().toLowerCase()}';

  String _childKey(String parentName, String name, CategoryType type) =>
      'child:${type.name}:${parentName.trim().toLowerCase()}:'
      '${name.trim().toLowerCase()}';
}
