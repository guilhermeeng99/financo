import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/validation/category_form_types.dart';

CreateAndEditCategoryBloc get createAndEditCategoryBloc =>
    Modular.get<CreateAndEditCategoryBloc>();

class CreateAndEditCategoryBloc extends GetxController {
  CreateAndEditCategoryBloc() {
    unawaited(loadAvailableParentCategories());

    ever(formData, (CategoryFormData data) {
      formErrors.value = const CategoryFormErrors();
    });
  }

  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  final Rx<CategoryFormData> formData = CategoryFormData().obs;
  final Rx<CategoryFormErrors> formErrors = const CategoryFormErrors().obs;

  final RxList<CategoryData> availableParentCategories = <CategoryData>[].obs;
  final RxnInt currentCategoryId = RxnInt();

  String get name => formData.value.name;
  FinancialType get selectedCategoryType => formData.value.categoryType;
  int? get parentCategoryId => formData.value.parentCategoryId;

  void updateName(String name) {
    formData.value = formData.value.copyWith(name: name);
    _clearFormError('name');
  }

  void updateCategoryType(FinancialType categoryType) {
    formData.value = formData.value.copyWith(categoryType: categoryType);
    unawaited(loadAvailableParentCategories());
  }

  void updateParentCategoryId(int? parentCategoryId) {
    formData.value = formData.value.copyWith(
      parentCategoryId: parentCategoryId,
      clearParentCategoryId: parentCategoryId == null,
    );
  }

  int? get validatedParentCategoryId {
    final selectedId = parentCategoryId;
    if (selectedId == null) return null;

    final availableIds = availableParentCategories.map((c) => c.id).toSet();
    return availableIds.contains(selectedId) ? selectedId : null;
  }

  List<int?> get validDropdownValues => [
    null,
    ...availableParentCategories.map((category) => category.id),
  ];

  bool get currentCategoryHasSubcategories {
    final categoryId = currentCategoryId.value;
    if (categoryId == null) return false;

    return false;
  }

  void initializeWithCategoryData(CategoryData category) {
    formData.value = CategoryFormData.fromCategory(category);
    currentCategoryId.value = category.id;
    clearAllErrors();
    unawaited(loadAvailableParentCategories());
  }

  Future<void> initializeSubCategoryFromCategory(int parentCategoryId) async {
    updateParentCategoryId(parentCategoryId);

    final result = await _categoryUsecase.getCategoryById(parentCategoryId);

    result.fold(
      (failure) {
        logger.e('Error getting parent category: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (parentCategory) {
        if (parentCategory != null) {
          updateCategoryType(parentCategory.categoryType);
        }
      },
    );

    await loadAvailableParentCategories();
  }

  Future<void> loadAvailableParentCategories() async {
    try {
      final result = await _categoryUsecase.getEligibleParentCategories(
        selectedCategoryType,
        currentCategoryId.value,
      );

      result.fold(
        (failure) {
          logger.e('Error loading parent categories: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
          availableParentCategories.clear();
        },
        (categories) {
          availableParentCategories.value = categories;
        },
      );
    } on Exception catch (e) {
      logger.e('Error loading parent categories: $e');
      availableParentCategories.clear();
    }
  }

  void _clearFormError(String field) {
    switch (field) {
      case 'name':
        formErrors.value = formErrors.value.copyWith(name: '');
    }
  }

  void clearAllErrors() {
    formErrors.value = const CategoryFormErrors();
  }

  @override
  void onClose() {
    formData.close();
    formErrors.close();
    availableParentCategories.close();
    currentCategoryId.close();
    super.onClose();
  }
}
