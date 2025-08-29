import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_module.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/create_and_edit_category/create_and_edit_category_screen.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/import_categories/import_categories_module.dart';
import 'package:financo/screens/main_flow/screens/categories/screens/import_categories/import_categories_screen.dart';

CategoriesModel get categoriesModel => Modular.get<CategoriesModel>();

CategoryUsecase get _categoryUsecase => Modular.get<CategoryUsecase>();

class CategoriesModel {
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
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
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
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
      },
      (success) {
        logger.i('Category deleted successfully');

        categoriesBloc.loadCategories();
      },
    );
  }

  void onTapImportPopUp() => PopUpManager.showDialog(
    builder: (c) => WidgetModuleProvider(
      module: ImportCategoriesModule(),
      child: ImportCategoriesPopUp.new,
    ),
  );
}

CategoriesModelExcel get categoriesModelExcel =>
    Modular.get<CategoriesModelExcel>();

class CategoriesModelExcel {
  Future<void> onTapDownloadUserCategories(BuildContext context) async {
    try {
      final result = await _categoryUsecase.getCategoriesAndSubcategories();

      await result.fold(
        (failure) {
          logger.e('Error loading categories for export: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: context.t.messages.errors.export_error,
            type: SnackBarType.error,
          );
        },
        (categoriesMap) async {
          final excel = Excel.createExcel()..rename('Sheet1', 'Categories');

          final sheet = excel['Categories'];

          sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
            'Type',
          );
          sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
            'Category',
          );
          sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
            'Subcategory',
          );

          var currentRow = 2;

          for (final entry in categoriesMap.entries) {
            final categoryType = entry.key;
            final categoriesWithSubs = entry.value;

            for (final categoryEntry in categoriesWithSubs.entries) {
              final parentCategory = categoryEntry.key;
              final subcategories = categoryEntry.value;

              if (subcategories.isEmpty) {
                sheet
                    .cell(
                      CellIndex.indexByColumnRow(
                        columnIndex: 0,
                        rowIndex: currentRow - 1,
                      ),
                    )
                    .value = TextCellValue(
                  categoryType.name,
                );
                sheet
                    .cell(
                      CellIndex.indexByColumnRow(
                        columnIndex: 1,
                        rowIndex: currentRow - 1,
                      ),
                    )
                    .value = TextCellValue(
                  parentCategory.name,
                );
                sheet
                    .cell(
                      CellIndex.indexByColumnRow(
                        columnIndex: 2,
                        rowIndex: currentRow - 1,
                      ),
                    )
                    .value = TextCellValue(
                  '',
                );

                currentRow++;
              } else {
                for (final subcategory in subcategories) {
                  sheet
                      .cell(
                        CellIndex.indexByColumnRow(
                          columnIndex: 0,
                          rowIndex: currentRow - 1,
                        ),
                      )
                      .value = TextCellValue(
                    categoryType.name,
                  );
                  sheet
                      .cell(
                        CellIndex.indexByColumnRow(
                          columnIndex: 1,
                          rowIndex: currentRow - 1,
                        ),
                      )
                      .value = TextCellValue(
                    parentCategory.name,
                  );
                  sheet
                      .cell(
                        CellIndex.indexByColumnRow(
                          columnIndex: 2,
                          rowIndex: currentRow - 1,
                        ),
                      )
                      .value = TextCellValue(
                    subcategory.name,
                  );

                  currentRow++;
                }
              }
            }
          }

          final excelBytes = excel.save();
          if (excelBytes == null) {
            logger.e('Error generating Excel file');

            AppWidgetsUtils.snackBar(
              title: context.t.messages.errors.export_error,
              type: SnackBarType.error,
            );

            return;
          }

          const fileName = 'user_categories.xlsx';

          await AppUtilsSystemFiles.fileSaver(
            fileName: fileName,
            excelBytes: excelBytes,
          );
          logger.i('Category archive saved successfully!');

          if (context.mounted) {
            AppWidgetsUtils.snackBar(
              title: context.t.messages.success.export_successfully,
              type: SnackBarType.success,
            );
          }
        },
      );
    } catch (e) {
      logger.e('Error exporting categories: $e');
      if (context.mounted) {
        AppWidgetsUtils.snackBar(
          title: context.t.messages.errors.export_error,
          type: SnackBarType.error,
        );
      }
    }
  }
}
