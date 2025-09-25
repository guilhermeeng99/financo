import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'create_and_edit_category_bloc.dart';
import 'create_and_edit_category_service.dart';
import 'validation/category_form_types.dart';
import 'validation/category_form_validator.dart';

CreateAndEditCategoryModel get createAndEditCategoryModel =>
    Modular.get<CreateAndEditCategoryModel>();

class CreateAndEditCategoryModel {
  final CategoryOperationService _operationService = CategoryOperationService();

  Future<void> onTapSave(CategoryData? category, BuildContext context) async {
    createAndEditCategoryBloc.clearAllErrors();

    if (category != null) {
      await _updateCategory(category, context);
    } else {
      await _createCategory(context);
    }
  }

  Future<void> _createCategory(BuildContext context) async {
    final formData = createAndEditCategoryBloc.formData.value;

    final validationResult = CategoryFormValidator.validateCreateCategory(
      formData,
      context,
    );

    if (validationResult.isFailure) {
      createAndEditCategoryBloc.formErrors.value = validationResult.errors!;
      return;
    }

    final params = validationResult.data!;
    final result = await _operationService.createCategory(
      params,
      formData,
      context,
    );

    await result.fold((failure) => _handleFailure(failure, context), (
      category,
    ) async {
      logger.i('Category created successfully');
      await PopUpManager.pop();
    });
  }

  Future<void> _updateCategory(
    CategoryData originalCategory,
    BuildContext context,
  ) async {
    final formData = createAndEditCategoryBloc.formData.value;

    final validationResult = CategoryFormValidator.validateUpdateCategory(
      originalCategory.id,
      formData,
      originalCategory.parentCategoryId,
      context,
    );

    if (validationResult.isFailure) {
      createAndEditCategoryBloc.formErrors.value = validationResult.errors!;
      return;
    }

    final params = validationResult.data!;
    final result = await _operationService.updateCategory(
      params,
      formData,
      context,
    );

    await result.fold((failure) => _handleFailure(failure, context), (
      category,
    ) async {
      logger.i('Category updated successfully');
      await PopUpManager.pop();
    });
  }

  Future<void> _handleFailure(Failure failure, BuildContext context) async {
    if (failure is DuplicateEntryFailure) {
      createAndEditCategoryBloc.formErrors.value = CategoryFormErrors(
        name: context.t.categories.validation.category_name_already_exists,
      );
    } else if (failure is NoChangesFailure) {
      logger.i(context.t.messages.warnings.no_changes_provided);
      CWSnackBar.snackBar(
        title: context.t.messages.warnings.no_changes_provided,
        type: SnackBarType.info,
      );
      await PopUpManager.pop();
    } else {
      CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      logger.e('Error with category operation: ${failure.message}');
    }
  }
}
