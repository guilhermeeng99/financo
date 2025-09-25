import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_model.dart';

enum CategoryMenuAction implements PopupMenuAction<CategoryData> {
  edit('edit'),
  freeze('freeze'),
  unfreeze('unfreeze'),
  createSubCategory('createSubCategory'),
  delete('delete');

  const CategoryMenuAction(this.value);

  final String value;

  @override
  String getLabel(BuildContext context) {
    switch (this) {
      case CategoryMenuAction.edit:
        return context.t.common.actions.edit;
      case CategoryMenuAction.freeze:
        return context.t.common.actions.freeze;
      case CategoryMenuAction.unfreeze:
        return context.t.common.actions.unfreeze;
      case CategoryMenuAction.createSubCategory:
        return context.t.categories.create_sub_category;
      case CategoryMenuAction.delete:
        return context.t.common.actions.delete;
    }
  }

  @override
  IconData getIcon() {
    switch (this) {
      case CategoryMenuAction.edit:
        return Icons.edit;
      case CategoryMenuAction.freeze:
        return Icons.lock_outline;
      case CategoryMenuAction.unfreeze:
        return Icons.lock_open_outlined;
      case CategoryMenuAction.createSubCategory:
        return Icons.add;
      case CategoryMenuAction.delete:
        return Icons.delete;
    }
  }

  @override
  Future<void> execute(CategoryData category) async {
    switch (this) {
      case CategoryMenuAction.edit:
        categoriesModel.onTapUpdateCategoryPopUp(category);
      case CategoryMenuAction.freeze:
        await categoriesModel.onTapFreezeOrUnfreeze(
          category: category,
          freeze: true,
        );
      case CategoryMenuAction.unfreeze:
        await categoriesModel.onTapFreezeOrUnfreeze(
          category: category,
          freeze: false,
        );
      case CategoryMenuAction.createSubCategory:
        categoriesModel.onTapCreateSubCategory(category);
      case CategoryMenuAction.delete:
        await categoriesModel.onTapDeleteCategory(category);
    }
  }

  @override
  bool isVisible(CategoryData category) {
    switch (this) {
      case CategoryMenuAction.freeze:
        return category.isActive;
      case CategoryMenuAction.unfreeze:
        return !category.isActive;
      case CategoryMenuAction.createSubCategory:
        return category.parentCategoryId == null;
      case CategoryMenuAction.edit:
      case CategoryMenuAction.delete:
        return true;
    }
  }
}
