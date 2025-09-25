import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/create_and_edit_category_module.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/create_and_edit_category_screen.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/import_categories/import_categories_module.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/import_categories/import_categories_screen.dart';

CategoriesModel get categoriesModel => Modular.get<CategoriesModel>();

ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

class CategoriesModel {
  void onTapFloatingActionButton() => _showCategoryPopUp(
    CreateAndEditCategoryPopUpArgs(type: CreateAndEditCategoryPopUpType.create),
  );

  Future<void> onTapShowOnlyActiveCategories() async {
    categoriesBloc.showOnlyActiveCategories.value =
        !categoriesBloc.showOnlyActiveCategories.value;
    await categoriesBloc.loadCategories();
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

    await result.fold(
      (failure) {
        logger.e('Error updating category status: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (updatedCategory) async {
        logger.i('Category status updated successfully');
        await categoriesBloc.loadCategories();
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

    await result.fold(
      (failure) {
        logger.e('Error deleting category: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (success) async {
        logger.i('Category deleted successfully');

        await categoriesBloc.loadCategories();
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
      final result = await _categoryUsecase.getCategoriesMapAsync();

      await result.fold(
        (failure) {
          logger.e('Error loading categories for export: ${failure.message}');
          CWSnackBar.snackBar(
            title: context.t.messages.errors.export_error,
            type: SnackBarType.error,
          );
        },
        (categoriesMap) async {
          final sheetName = context.t.common.labels.category(n: 2);
          final excel = Excel.createExcel()..rename('Sheet1', sheetName);

          final sheet = excel[sheetName];

          sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
            context.t.common.labels.type,
          );
          sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
            context.t.common.labels.category(n: 1),
          );
          sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
            context.t.common.labels.subcategory,
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
                  categoryType.title(context),
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
                    categoryType.title(context),
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

            CWSnackBar.snackBar(
              title: context.t.messages.errors.export_error,
              type: SnackBarType.error,
            );

            return;
          }

          const fileName = 'user_categories.xlsx';

          await AppSystemFiles.fileSaver(
            fileName: fileName,
            excelBytes: excelBytes,
          );
          logger.i('Category archive saved successfully!');

          if (context.mounted) {
            CWSnackBar.snackBar(
              title: context.t.messages.success.export_successfully,
              type: SnackBarType.success,
            );
          }
        },
      );
    } on Exception catch (e) {
      logger.e('Error exporting categories: $e');
      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.export_error,
          type: SnackBarType.error,
        );
      }
    }
  }
}
