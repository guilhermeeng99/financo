import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CategoriesBloc get categoriesBloc => Modular.get<CategoriesBloc>();

class CategoriesBloc extends GetxController {
  CategoriesBloc() {
    unawaited(loadCategories());
  }
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  final RxMap<FinancialType, Map<CategoryData, List<CategoryData>>>
  categoriesWithSubcategories =
      <FinancialType, Map<CategoryData, List<CategoryData>>>{}.obs;

  final RxBool showOnlyActiveCategories = true.obs;

  Future<void> loadCategories() async {
    try {
      final result = await _categoryUsecase.getCategoriesMapAsync(
        onlyActive: showOnlyActiveCategories.value,
      );

      result.fold(
        (failure) {
          logger.e('❌ Error loading categories: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (withSubcategories) {
          categoriesWithSubcategories.value = withSubcategories;
          logger.i('✅ Grouped categories loaded from database');
        },
      );
    } on Exception catch (e) {
      logger.e('❌ Error loading categories: $e');
    }
  }

  @override
  void onClose() {
    categoriesWithSubcategories.close();
    showOnlyActiveCategories.close();
    super.onClose();
  }
}
