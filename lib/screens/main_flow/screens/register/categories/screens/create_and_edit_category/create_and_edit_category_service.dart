import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/validation/category_form_types.dart';

class CategoryOperationService {
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  Future<Either<Failure, CategoryData>> createCategory(
    CreateCategoryParams params,
    CategoryFormData formData,
    BuildContext context,
  ) async {
    final result = await _categoryUsecase.createCategory(
      name: params.name,
      categoryType: params.categoryType,
      parentCategoryId: params.parentCategoryId,
    );

    result.fold(
      (failure) => logger.e('Error creating category: ${failure.message}'),
      (category) async {
        logger.i('Category created successfully: ${category.name}');
        await categoriesBloc.loadCategories();
      },
    );

    return result;
  }

  Future<Either<Failure, CategoryData>> updateCategory(
    UpdateCategoryParams params,
    CategoryFormData formData,
    BuildContext context,
  ) async {
    final result = await _categoryUsecase.updateCategory(
      id: params.id,
      name: params.name,
      parentCategoryId: params.parentCategoryId,
      updateParentId: params.updateParentId,
    );

    result.fold(
      (failure) => logger.e('Error updating category: ${failure.message}'),
      (category) async {
        logger.i('Category updated successfully: ${category.name}');
        await categoriesBloc.loadCategories();
      },
    );

    return result;
  }
}
