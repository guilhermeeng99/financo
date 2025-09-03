import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';

import 'create_and_edit_category_bloc.dart';

CreateAndEditCategoryModel get createAndEditCategoryModel =>
    Modular.get<CreateAndEditCategoryModel>();

class CreateAndEditCategoryModel {
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  Future<void> onTapSave(CategoryData? category) async {
    if (category != null) {
      await _updateCategory(category);
    } else {
      await _createCategory();
    }
  }

  Future<void> _createCategory() async {
    final result = await _categoryUsecase.createCategory(
      name: createAndEditCategoryBloc.name.value.trim(),
      categoryType: createAndEditCategoryBloc.selectedCategoryType.value,
      parentCategoryId: createAndEditCategoryBloc.parentCategoryId.value,
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
  }

  Future<void> _updateCategory(CategoryData originalCategory) async {
    final newName = createAndEditCategoryBloc.name.value.trim();
    final newParentId = createAndEditCategoryBloc.parentCategoryId.value;

    final nameChanged = newName != originalCategory.name;
    final parentChanged = newParentId != originalCategory.parentCategoryId;

    if (!nameChanged && !parentChanged) {
      CWSnackBar.snackBar(
        title: 'No changes detected',
        type: SnackBarType.info,
      );
      await PopUpManager.pop();
      return;
    }

    final result = await _categoryUsecase.updateCategory(
      id: originalCategory.id,
      name: nameChanged ? newName : null,
      parentCategoryId: newParentId,
      updateParentId: parentChanged,
    );

    result.fold(
      (failure) {
        logger.e('Error creating category: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (category) {
        logger.i('Category updated successfully: ${category.name}');
        categoriesBloc.loadCategories();
        PopUpManager.pop();
      },
    );
  }
}
