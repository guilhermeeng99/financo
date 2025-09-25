import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/validation/category_validation_exceptions.dart';

import 'category_form_types.dart';

class CategoryFormValidator {
  static ValidationResult<CreateCategoryParams, CategoryFormErrors>
  validateCreateCategory(CategoryFormData formData, BuildContext context) {
    final validationResults = _validateFields(formData, context);

    if (validationResults.hasErrors) {
      return ValidationResult.failure(validationResults.errors);
    }

    return ValidationResult.success(
      CreateCategoryParams(
        name: validationResults.nameValidation!,
        categoryType: formData.categoryType,
        parentCategoryId: validationResults.parentCategoryIdValidation,
      ),
    );
  }

  static ValidationResult<UpdateCategoryParams, CategoryFormErrors>
  validateUpdateCategory(
    int categoryId,
    CategoryFormData formData,
    int? originalParentCategoryId,
    BuildContext context,
  ) {
    final validationResults = _validateFields(formData, context);

    if (validationResults.hasErrors) {
      return ValidationResult.failure(validationResults.errors);
    }

    final updateParentId =
        formData.parentCategoryId != originalParentCategoryId;

    return ValidationResult.success(
      UpdateCategoryParams(
        id: categoryId,
        name: validationResults.nameValidation!,
        categoryType: formData.categoryType,
        parentCategoryId: validationResults.parentCategoryIdValidation,
        updateParentId: updateParentId,
      ),
    );
  }

  static _FieldValidationResults _validateFields(
    CategoryFormData formData,
    BuildContext context,
  ) {
    CategoryName? nameValidation;
    ParentCategoryId? parentCategoryIdValidation;
    var errors = const CategoryFormErrors();

    try {
      nameValidation = CategoryName.create(formData.name);
    } on Exception catch (e) {
      final errorMessage = CategoryValidationException.getMessage(e, context);
      errors = errors.copyWith(name: errorMessage);
    }

    try {
      final parentId = formData.parentCategoryId;
      parentCategoryIdValidation = parentId != null
          ? ParentCategoryId.create(parentId)
          : ParentCategoryId.none();
    } on Exception catch (e) {
      final errorMessage = e.toString();
      errors = errors.copyWith(name: errorMessage);
    }

    return _FieldValidationResults(
      nameValidation: nameValidation,
      parentCategoryIdValidation: parentCategoryIdValidation,
      errors: errors,
    );
  }
}

class _FieldValidationResults {
  const _FieldValidationResults({
    required this.errors,
    this.nameValidation,
    this.parentCategoryIdValidation,
  });

  final CategoryName? nameValidation;
  final ParentCategoryId? parentCategoryIdValidation;
  final CategoryFormErrors errors;

  bool get hasErrors => errors.hasErrors || nameValidation == null;
}
