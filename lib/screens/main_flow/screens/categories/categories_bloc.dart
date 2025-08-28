import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CategoriesBloc get categoriesBloc => Modular.get<CategoriesBloc>();

class CategoriesBloc extends GetxController {
  CategoriesBloc() {
    loadCategories();
  }
  CategoryUsecase get _categoryUsecase => Modular.get<CategoryUsecase>();

  final RxMap<FinancialType, Map<CategoryData, List<CategoryData>>>
  categoriesWithSubcategories =
      <FinancialType, Map<CategoryData, List<CategoryData>>>{}.obs;

  final RxBool showOnlyActiveCategories = true.obs;

  Future<void> loadCategories() async {
    try {
      final result = await _categoryUsecase.getCategoriesAndSubcategories(
        onlyActive: showOnlyActiveCategories.value,
      );

      result.fold(
        (failure) {
          logger.e('❌ Error loading categories: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
        },
        (withSubcategories) {
          categoriesWithSubcategories.value = withSubcategories;
          logger.i('✅ Grouped categories loaded from database');
        },
      );
    } catch (e) {
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
