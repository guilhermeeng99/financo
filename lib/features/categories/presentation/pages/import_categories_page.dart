import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/import_preview_scaffold.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/widgets/category_import_edit_sheet.dart';
import 'package:financo/features/categories/presentation/widgets/category_import_rows_list.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Page that shows the parsed CSV import preview with full UI to edit each
/// item (name, icon, color), delete it, or split-review by Expense/Income
/// before committing the import. Replaces the old confirmation dialog.
class ImportCategoriesPage extends StatefulWidget {
  const ImportCategoriesPage({required this.preview, super.key});

  final CategoryImportPreview preview;

  @override
  State<ImportCategoriesPage> createState() => _ImportCategoriesPageState();
}

class _ImportCategoriesPageState extends State<ImportCategoriesPage> {
  late List<CategoryImportPreviewItem> _items;
  CategoryType _filter = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.preview.toCreate);
  }

  // Removing a root drops its children too — otherwise they'd silently fail
  // at import time (orphaned because the parent never gets created).
  void _removeItem(int globalIndex) {
    final removed = _items[globalIndex];
    setState(() {
      if (removed.isSubcategory) {
        _items.removeAt(globalIndex);
      } else {
        _items.removeWhere(
          (it) =>
              identical(it, removed) ||
              (it.isSubcategory &&
                  it.type == removed.type &&
                  it.parentName == removed.name),
        );
      }
    });
  }

  // When the user renames a root, propagate to its children's `parentName`
  // so the parent lookup at import time still resolves.
  void _replaceItem(int globalIndex, CategoryImportPreviewItem updated) {
    setState(() {
      final original = _items[globalIndex];
      _items[globalIndex] = updated;

      if (!original.isSubcategory && original.name != updated.name) {
        for (var i = 0; i < _items.length; i++) {
          final it = _items[i];
          if (it.isSubcategory &&
              it.type == original.type &&
              it.parentName == original.name) {
            _items[i] = it.copyWith(parentName: updated.name);
          }
        }
      }
    });
  }

  Future<void> _editItem(int globalIndex) async {
    final original = _items[globalIndex];
    final result = await showModalBottomSheet<CategoryImportPreviewItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryImportEditSheet(item: original),
    );
    if (result == null) return;
    _replaceItem(globalIndex, result);
  }

  Future<void> _confirmRemove(int globalIndex) async {
    final item = _items[globalIndex];
    if (item.isSubcategory) {
      _removeItem(globalIndex);
      return;
    }
    final childCount = _items
        .where(
          (it) =>
              it.isSubcategory &&
              it.type == item.type &&
              it.parentName == item.name,
        )
        .length;

    if (childCount == 0) {
      _removeItem(globalIndex);
      return;
    }

    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.general.delete,
      message: t.categories.importDeleteRoot(
        name: item.name,
        count: childCount,
      ),
      confirmLabel: t.categories.importDeleteRootConfirm,
      destructive: true,
    );
    if (confirmed) _removeItem(globalIndex);
  }

  void _onSubmit() {
    unawaited(
      context.read<CategoriesCubit>().confirmImport(
        items: _items,
        duplicateCount: widget.preview.duplicates.length,
      ),
    );
  }

  void _onCubitState(BuildContext context, CategoriesState state) {
    if (state is CategoriesImported) {
      context
        ..showSnack(
          t.categories.importSuccessDetailed(
            imported: state.importedCount,
            duplicates: state.duplicateCount,
          ),
        )
        ..pop(true);
    } else if (state is CategoriesError) {
      context.showSnack(localizedFailure(state.failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ImportPreviewScaffold<CategoriesCubit, CategoriesState>(
      title: t.categories.importPageTitle,
      subtitle: t.categories.importPageSubtitle,
      onStateChanged: _onCubitState,
      typeToggle: _buildTypeToggle(),
      list: CategoryImportRowsList(
        items: _items,
        duplicates: widget.preview.duplicates,
        filter: _filter,
        onTap: _editItem,
        onRemove: _confirmRemove,
      ),
      progressOverlayOf: _progressOverlayOf,
      submitLabel: _items.isEmpty
          ? t.categories.importNothingLeft
          : t.categories.importSubmit(count: _items.length),
      isSubmitting: (state) =>
          state is CategoriesLoading || state is CategoriesImporting,
      canSubmit: _items.isNotEmpty,
      onSubmit: _onSubmit,
    );
  }

  int _countFor(CategoryType type) =>
      _items.where((it) => it.type == type).length;

  Widget _buildTypeToggle() {
    return FinancoPillToggle<CategoryType>(
      selected: _filter,
      onChanged: (f) => setState(() => _filter = f),
      options: [
        FinancoPillToggleOption(
          value: CategoryType.expense,
          label: t.categories.importTabExpense(
            count: _countFor(CategoryType.expense),
          ),
          icon: FontAwesomeIcons.arrowUp,
        ),
        FinancoPillToggleOption(
          value: CategoryType.income,
          label: t.categories.importTabIncome(
            count: _countFor(CategoryType.income),
          ),
          icon: FontAwesomeIcons.arrowDown,
        ),
      ],
    );
  }

  /// Modal-style overlay rendered on top of the import preview while the
  /// cubit is in the [CategoriesImporting] state. Blocks interaction with
  /// the list (an in-flight import shouldn't be edited) and shows a
  /// determinate progress bar with a `processed of total` counter so the
  /// user knows how long the operation still has to run.
  ImportProgressOverlay? _progressOverlayOf(CategoriesState state) {
    if (state is! CategoriesImporting) return null;
    return ImportProgressOverlay(
      title: t.categories.importInProgressTitle,
      counterLabel: t.categories.importProgressCounter(
        processed: state.processed,
        total: state.total,
      ),
      progress: state.progress,
    );
  }
}
