import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';

import 'create_and_edit_category_bloc.dart';

CreateAndEditCategoryModel get createAndEditCategoryModel =>
    Modular.get<CreateAndEditCategoryModel>();

class CreateAndEditCategoryModel {
  CategoryUsecase get _categoryUsecase => Modular.get<CategoryUsecase>();

  Future<void> onTapSave(CategoryData? category) async {
    final canSave = createAndEditCategoryBloc.name.value.trim().isNotEmpty;

    if (canSave) {
      if (category != null) {
        await _updateCategory(category);
      } else {
        await _createCategory();
      }
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
      },
      (category) {
        logger.i('Category created successfully: ${category.name}');

        DataCacheManager().categories.add(category);

        categoriesBloc.loadGroupedCategories();
        PopUpManager.pop();
      },
    );
  }

  Future<void> _updateCategory(CategoryData originalCategory) async {
    final result = await _categoryUsecase.updateCategory(
      id: originalCategory.id,
      name: createAndEditCategoryBloc.name.value.trim(),
      parentCategoryId: createAndEditCategoryBloc.parentCategoryId.value,
    );

    result.fold(
      (failure) {
        logger.e('Error updating category: ${failure.message}');
      },
      (category) {
        logger.i('Category updated successfully: ${category.name}');

        DataCacheManager().categories.update(category);

        categoriesBloc.loadGroupedCategories();
        PopUpManager.pop();
      },
    );
  }
}
