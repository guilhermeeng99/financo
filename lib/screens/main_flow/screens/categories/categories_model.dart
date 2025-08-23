import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_module.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_screen.dart';

CategoriesModel get categoriesModel => Modular.get<CategoriesModel>();

class CategoriesModel {
  CategoryUsecase get _categoryUsecase => Modular.get<CategoryUsecase>();

  void onTapFloatingActionButton() => _showCategoryPopUp(
    CreateAndEditCategoryPopUpArgs(type: CreateAndEditCategoryPopUpType.create),
  );

  void onTapShowOnlyActiveCategories() {
    categoriesBloc.showOnlyActiveCategories.value =
        !categoriesBloc.showOnlyActiveCategories.value;
    categoriesBloc.loadCategories();
  }

  void onTapUpdateCategoryPopUp(CategoryData category) => _showCategoryPopUp(
    CreateAndEditCategoryPopUpArgs(
      type: CreateAndEditCategoryPopUpType.edit,
      category: category,
    ),
  );

  void _showCategoryPopUp(CreateAndEditCategoryPopUpArgs args) =>
      PopUpManager.showDialog(
        builder: (c) => WidgetModuleProvider(
          module: CreateAndEditCategoryModule(),
          child: () => CreateAndEditCategoryPopUp(args),
        ),
      );

  Future<void> onTapFreezeOrUnfreeze({
    required CategoryData category,
    required bool freeze,
  }) async {
    final result = await _categoryUsecase.updateCategory(
      id: category.id,
      isActive: !freeze,
    );

    result.fold(
      (failure) {
        logger.e('Error updating category status: ${failure.message}');
      },
      (updatedCategory) {
        logger.i('Category status updated successfully');
        categoriesBloc.loadCategories();
      },
    );
  }

  void onTapCreateSubCategory(CategoryData category) {
    _showCategoryPopUp(
      CreateAndEditCategoryPopUpArgs(
        type: CreateAndEditCategoryPopUpType.create,
        parentCategoryId: category.id,
      ),
    );
  }

  Future<void> onTapDeleteCategory(CategoryData category) async {
    final result = await _categoryUsecase.deleteCategory(category.id);

    result.fold(
      (failure) {
        logger.e('Error deleting category: ${failure.message}');
      },
      (success) {
        logger.i('Category deleted successfully');

        categoriesBloc.loadCategories();
      },
    );
  }
}
