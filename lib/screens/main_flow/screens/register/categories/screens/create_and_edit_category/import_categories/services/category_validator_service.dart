import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/validation/category_form_types.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/validation/category_form_validator.dart';

class CategoryValidatorService {
  ValidationResult<CreateCategoryParams, CategoryFormErrors> validateCategory(
    String categoryName,
    FinancialType categoryType,
    int? parentCategoryId,
    BuildContext context,
  ) {
    final formData = CategoryFormData(
      name: categoryName,
      categoryType: categoryType,
      parentCategoryId: parentCategoryId,
    );

    return CategoryFormValidator.validateCreateCategory(formData, context);
  }
}
