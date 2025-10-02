import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/import_categories/models/import_category_data.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/import_categories/services/category_validator_service.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/validation/category_form_types.dart';

class CategoryImportService {
  CategoryImportService({
    required ICategoryUsecase categoryUsecase,
    required CategoryValidatorService validatorService,
  }) : _categoryUsecase = categoryUsecase,
       _validatorService = validatorService;

  final ICategoryUsecase _categoryUsecase;
  final CategoryValidatorService _validatorService;

  Future<ImportResult> importCategories(
    List<ImportCategoryData> categories,
    int validRowsCount,
    BuildContext context,
  ) async {
    var successCount = 0;
    var errorCount = 0;
    final createdParentCategories = <String, CreatedParentCategory>{};

    final uniqueParentCategories = _collectUniqueParentCategories(categories);

    logger.i(
      'Creating ${uniqueParentCategories.length} unique parent categories...',
    );

    final validatedParents = _preValidateCategories(
      uniqueParentCategories,
      context,
    );

    final validatedSubcategories = _preValidateSubcategories(
      categories,
      context,
    );

    await _createOrFindParentCategories(
      validatedParents,
      createdParentCategories,
      onSuccess: () => successCount++,
      onError: () => errorCount++,
    );

    await _createSubcategories(
      validatedSubcategories,
      createdParentCategories,
      onSuccess: () => successCount++,
      onError: () => errorCount++,
    );

    logger.i('Import completed: $successCount success, $errorCount errors');
    return ImportResult(successCount, errorCount, validRowsCount);
  }

  Map<String, ImportCategoryData> _collectUniqueParentCategories(
    List<ImportCategoryData> categories,
  ) {
    final uniqueParents = <String, ImportCategoryData>{};

    for (final categoryData in categories) {
      if (categoryData.isParent) {
        uniqueParents[categoryData.key] = categoryData;
      } else {
        final parentKey = categoryData.key;
        if (!uniqueParents.containsKey(parentKey)) {
          uniqueParents[parentKey] = ImportCategoryData(
            name: categoryData.parentName,
            type: categoryData.type,
            isParent: true,
            parentName: categoryData.parentName,
          );
        }
      }
    }

    return uniqueParents;
  }

  Map<String, _ValidatedCategoryData> _preValidateCategories(
    Map<String, ImportCategoryData> categories,
    BuildContext context,
  ) {
    final validated = <String, _ValidatedCategoryData>{};

    for (final entry in categories.entries) {
      final key = entry.key;
      final categoryData = entry.value;

      final validationResult = _validatorService.validateCategory(
        categoryData.name,
        categoryData.type,
        null,
        context,
      );

      validated[key] = _ValidatedCategoryData(
        categoryData: categoryData,
        validationResult: validationResult,
      );
    }

    return validated;
  }

  List<_ValidatedCategoryData> _preValidateSubcategories(
    List<ImportCategoryData> categories,
    BuildContext context,
  ) {
    final subcategories = categories.where((cat) => !cat.isParent).toList();
    final validated = <_ValidatedCategoryData>[];

    for (final subcategoryData in subcategories) {
      final validationResult = _validatorService.validateCategory(
        subcategoryData.name,
        subcategoryData.type,
        null,
        context,
      );

      validated.add(
        _ValidatedCategoryData(
          categoryData: subcategoryData,
          validationResult: validationResult,
        ),
      );
    }

    return validated;
  }

  Future<void> _createOrFindParentCategories(
    Map<String, _ValidatedCategoryData> validatedCategories,
    Map<String, CreatedParentCategory> createdParentCategories, {
    required void Function() onSuccess,
    required void Function() onError,
  }) async {
    for (final entry in validatedCategories.entries) {
      final parentKey = entry.key;
      final validated = entry.value;
      final categoryData = validated.categoryData;

      final existingCategory = await _findExistingParentCategory(
        categoryData.name,
        categoryData.type,
      );

      if (existingCategory != null) {
        createdParentCategories[parentKey] = CreatedParentCategory(
          id: existingCategory.id,
          name: existingCategory.name,
          categoryType: existingCategory.categoryType,
        );
        logger.i('Using existing parent category: ${existingCategory.name}');
      } else {
        final result = await _createParentCategory(validated);
        result.fold(
          (failure) => onError(),
          (createdCategory) {
            onSuccess();
            createdParentCategories[parentKey] = CreatedParentCategory(
              id: createdCategory.id,
              name: createdCategory.name,
              categoryType: createdCategory.categoryType,
            );
          },
        );
      }
    }
  }

  Future<void> _createSubcategories(
    List<_ValidatedCategoryData> validatedSubcategories,
    Map<String, CreatedParentCategory> createdParentCategories, {
    required void Function() onSuccess,
    required void Function() onError,
  }) async {
    logger.i('Creating ${validatedSubcategories.length} subcategories...');

    for (final validated in validatedSubcategories) {
      final subcategoryData = validated.categoryData;
      final parentCategory = createdParentCategories[subcategoryData.key];

      if (parentCategory == null) {
        logger.e(
          'Parent category not found for subcategory: ${subcategoryData.name}',
        );
        onError();
        continue;
      }

      final result = await _createSubcategory(
        validated,
        parentCategory.id,
      );
      result.fold((failure) => onError(), (success) => onSuccess());
    }
  }

  Future<CategoryData?> _findExistingParentCategory(
    String categoryName,
    FinancialType categoryType,
  ) async {
    try {
      final result = await _categoryUsecase.getCategoriesByType(categoryType);
      return result.fold((failure) => null, (categories) {
        return categories
            .where(
              (cat) =>
                  cat.parentCategoryId == null &&
                  cat.name.toLowerCase() == categoryName.toLowerCase(),
            )
            .firstOrNull;
      });
    } on Exception catch (e) {
      logger.e('Error finding existing parent category: $e');
      return null;
    }
  }

  Future<Either<Failure, CategoryData>> _createParentCategory(
    _ValidatedCategoryData validated,
  ) async {
    try {
      final categoryData = validated.categoryData;
      final validationResult = validated.validationResult;

      if (validationResult.isFailure) {
        final errorMessage =
            validationResult.errors?.name ?? 'Validation error';
        logger.e(
          'Validation failed for parent category "${categoryData.name}": $errorMessage',
        );
        return Either.left(ValidationFailure(errorMessage));
      }

      final params = validationResult.data!;
      final result = await _categoryUsecase.createCategory(
        name: params.name,
        categoryType: params.categoryType,
      );

      result.fold(
        (failure) => logger.e(
          'Error creating parent category "${categoryData.name}": ${failure.message}',
        ),
        (createdCategory) =>
            logger.i('Parent category created: ${createdCategory.name}'),
      );

      return result;
    } on ValidationException catch (e) {
      logger.e('Validation error creating parent category: ${e.message}');
      return Either.left(ValidationFailure(e.message));
    } on Exception catch (e) {
      logger.e('Unexpected error creating parent category: $e');
      return Either.left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, CategoryData>> _createSubcategory(
    _ValidatedCategoryData validated,
    int parentId,
  ) async {
    try {
      final subcategoryData = validated.categoryData;
      final validationResult = validated.validationResult;

      if (validationResult.isFailure) {
        final errorMessage =
            validationResult.errors?.name ?? 'Validation error';
        logger.e(
          'Validation failed for subcategory "${subcategoryData.name}": $errorMessage',
        );
        return Either.left(ValidationFailure(errorMessage));
      }

      final params = validationResult.data!;
      final result = await _categoryUsecase.createCategory(
        name: params.name,
        categoryType: params.categoryType,
        parentCategoryId: ParentCategoryId.create(parentId),
      );

      result.fold(
        (failure) => logger.e(
          'Error creating subcategory "${subcategoryData.name}": ${failure.message}',
        ),
        (createdCategory) =>
            logger.i('Subcategory created: ${createdCategory.name}'),
      );

      return result;
    } on ValidationException catch (e) {
      logger.e('Validation error creating subcategory: ${e.message}');
      return Either.left(ValidationFailure(e.message));
    } on Exception catch (e) {
      logger.e('Unexpected error creating subcategory: $e');
      return Either.left(DatabaseFailure('Unexpected error: $e'));
    }
  }
}

class _ValidatedCategoryData {
  const _ValidatedCategoryData({
    required this.categoryData,
    required this.validationResult,
  });

  final ImportCategoryData categoryData;
  final ValidationResult<CreateCategoryParams, CategoryFormErrors>
  validationResult;
}
