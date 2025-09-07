import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';

import 'create_and_edit_category_bloc.dart';

CreateAndEditCategoryModel get createAndEditCategoryModel =>
    Modular.get<CreateAndEditCategoryModel>();

class CreateAndEditCategoryModel {
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  Future<void> onTapSave(CategoryData? category, BuildContext context) async {
    if (category != null) {
      await _updateCategory(category, context);
    } else {
      await _createCategory(context);
    }
  }

  Future<void> _createCategory(BuildContext context) async {
    await _executeValidation(context, (name, parentCategoryId) async {
      final result = await _categoryUsecase.createCategory(
        name: name,
        categoryType: createAndEditCategoryBloc.selectedCategoryType.value,
        parentCategoryId: parentCategoryId,
      );

      result.fold(
        (failure) {
          logger.e('Error creating category: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (category) {
          logger.i('Category created successfully: ${category.name}');
          categoriesBloc.loadCategories();
          PopUpManager.pop();
        },
      );
    });
  }

  Future<void> _updateCategory(
    CategoryData originalCategory,
    BuildContext context,
  ) async {
    await _executeValidation(context, (name, parentCategoryId) async {
      final result = await _categoryUsecase.updateCategory(
        id: originalCategory.id,
        name: name,
        parentCategoryId: parentCategoryId,
        updateParentId:
            createAndEditCategoryBloc.parentCategoryId.value !=
            originalCategory.parentCategoryId,
      );

      result.fold(
        (failure) {
          if (failure is NoChangesFailure) {
            logger.i(context.t.messages.warnings.no_changes_provided);
            CWSnackBar.snackBar(
              title: context.t.messages.warnings.no_changes_provided,
              type: SnackBarType.info,
            );
            PopUpManager.pop();
          } else {
            logger.e('Error updating category: ${failure.message}');
            CWSnackBar.snackBar(
              title: failure.message,
              type: SnackBarType.error,
            );
          }
        },
        (category) {
          logger.i('Category updated successfully: ${category.name}');
          categoriesBloc.loadCategories();
          PopUpManager.pop();
        },
      );
    });
  }

  Future<void> _executeValidation(
    BuildContext context,
    Future<void> Function(CategoryName name, ParentCategoryId? parentCategoryId)
    execute,
  ) async {
    final validatedInputs = _validateInputs(context);
    if (validatedInputs == null) return;

    final (name, parentCategoryId) = validatedInputs;
    await execute(name, parentCategoryId);
  }

  (CategoryName, ParentCategoryId?)? _validateInputs(BuildContext context) {
    CategoryName? name;
    ParentCategoryId? parentCategoryId;

    try {
      name = CategoryName.create(
        createAndEditCategoryBloc.name.value.trim(),
        context,
      );
    } on ValidationException catch (e) {
      createAndEditCategoryBloc.nameError.value = e.message;
    }

    try {
      final parentId = createAndEditCategoryBloc.parentCategoryId.value;
      parentCategoryId = parentId != null
          ? ParentCategoryId.create(parentId, context)
          : ParentCategoryId.none();
    } on ValidationException catch (e) {
      logger.e('Error validating parent category: ${e.message}');
    }

    if (name == null) {
      return null;
    }

    return (name, parentCategoryId);
  }
}
