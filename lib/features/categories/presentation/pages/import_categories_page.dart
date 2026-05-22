import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/widgets/category_color_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_icon_picker.dart';
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
      builder: (_) => _EditItemSheet(item: original),
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
      message:
          t.categories.importDeleteRoot(name: item.name, count: childCount),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.categories.importSuccessDetailed(
              imported: state.importedCount,
              duplicates: state.duplicateCount,
            ),
          ),
        ),
      );
      context.pop(true);
    } else if (state is CategoriesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(state.failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final expenseCount = _items
        .where((it) => it.type == CategoryType.expense)
        .length;
    final incomeCount = _items
        .where((it) => it.type == CategoryType.income)
        .length;

    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: _onCubitState,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: FinancoLargeAppBar(
          title: t.categories.importPageTitle,
          subtitle: t.categories.importPageSubtitle,
          showBack: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FinancoPillToggle<CategoryType>(
                    selected: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                    options: [
                      FinancoPillToggleOption(
                        value: CategoryType.expense,
                        label: t.categories.importTabExpense(
                          count: expenseCount,
                        ),
                        icon: FontAwesomeIcons.arrowUp,
                      ),
                      FinancoPillToggleOption(
                        value: CategoryType.income,
                        label: t.categories.importTabIncome(count: incomeCount),
                        icon: FontAwesomeIcons.arrowDown,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _ImportList(
                    items: _items,
                    duplicates: widget.preview.duplicates,
                    filter: _filter,
                    onTap: _editItem,
                    onRemove: _confirmRemove,
                  ),
                ),
              ],
            ),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              buildWhen: (previous, current) =>
                  previous is CategoriesImporting ||
                  current is CategoriesImporting,
              builder: (context, state) {
                if (state is! CategoriesImporting) {
                  return const SizedBox.shrink();
                }
                return _ImportProgressOverlay(state: state);
              },
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) => FinancoSubmitBar(
            label: _items.isEmpty
                ? t.categories.importNothingLeft
                : t.categories.importSubmit(count: _items.length),
            isLoading:
                state is CategoriesLoading || state is CategoriesImporting,
            isEnabled: _items.isNotEmpty,
            onSubmit: _onSubmit,
          ),
        ),
      ),
    );
  }
}

/// Modal-style overlay rendered on top of the import preview while the cubit
/// is in the [CategoriesImporting] state. Blocks interaction with the list
/// (an in-flight import shouldn't be edited) and shows a determinate
/// progress bar with a `processed of total` counter so the user knows how
/// long the operation still has to run.
class _ImportProgressOverlay extends StatelessWidget {
  const _ImportProgressOverlay({required this.state});

  final CategoriesImporting state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = (state.progress * 100).clamp(0, 100).toStringAsFixed(0);

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.categories.importInProgressTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 8,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.categories.importProgressCounter(
                        processed: state.processed,
                        total: state.total,
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImportList extends StatelessWidget {
  const _ImportList({
    required this.items,
    required this.duplicates,
    required this.filter,
    required this.onTap,
    required this.onRemove,
  });

  final List<CategoryImportPreviewItem> items;
  final List<CategoryImportPreviewItem> duplicates;
  final CategoryType filter;
  final void Function(int globalIndex) onTap;
  final void Function(int globalIndex) onRemove;

  @override
  Widget build(BuildContext context) {
    final ordered = _orderForFilter(items, filter);
    final filteredDuplicates = duplicates
        .where((it) => it.type == filter)
        .toList();

    if (ordered.isEmpty && filteredDuplicates.isEmpty) {
      return _EmptyTab();
    }

    final colors = context.appColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        for (final entry in ordered)
          _ImportRow(
            item: entry.item,
            onTap: () => onTap(entry.globalIndex),
            onRemove: () => onRemove(entry.globalIndex),
          ),
        if (filteredDuplicates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              t.categories.importDuplicatesHeader.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackgroundLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          for (final dup in filteredDuplicates)
            Opacity(
              opacity: 0.55,
              child: _ImportRow(
                item: dup,
                onTap: null,
                onRemove: null,
              ),
            ),
        ],
      ],
    );
  }

  List<_OrderedItem> _orderForFilter(
    List<CategoryImportPreviewItem> items,
    CategoryType filter,
  ) {
    final indexed = <_OrderedItem>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      if (it.type != filter) continue;
      indexed.add(_OrderedItem(item: it, globalIndex: i));
    }

    final roots = indexed.where((e) => !e.item.isSubcategory).toList()
      ..sort(
        (a, b) =>
            a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()),
      );
    final childrenByParent = <String, List<_OrderedItem>>{};
    final orphans = <_OrderedItem>[];

    for (final entry in indexed.where((e) => e.item.isSubcategory)) {
      final parentName = entry.item.parentName!;
      final hasParent = roots.any((r) => r.item.name == parentName);
      if (hasParent) {
        childrenByParent.putIfAbsent(parentName, () => []).add(entry);
      } else {
        orphans.add(entry);
      }
    }

    for (final list in childrenByParent.values) {
      list.sort(
        (a, b) =>
            a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()),
      );
    }
    orphans.sort(
      (a, b) =>
          a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()),
    );

    final out = <_OrderedItem>[];
    for (final root in roots) {
      out
        ..add(root)
        ..addAll(childrenByParent[root.item.name] ?? const []);
    }
    out.addAll(orphans);
    return out;
  }
}

class _OrderedItem {
  const _OrderedItem({required this.item, required this.globalIndex});

  final CategoryImportPreviewItem item;
  final int globalIndex;
}

class _ImportRow extends StatelessWidget {
  const _ImportRow({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final CategoryImportPreviewItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(item.color);
    final isSub = item.isSubcategory;

    return Padding(
      padding: EdgeInsets.only(left: isSub ? 24 : 0, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        materialIconFor(item.icon),
                        size: 18,
                        color: tint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSub
                              ? '${item.parentName} · '
                                  '${t.categories.subcategoryLabel}'
                              : (item.type == CategoryType.income
                                    ? t.categories.incomeType
                                    : t.categories.expenseType),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 4),
                    _RemoveButton(onPressed: onRemove!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.error.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.trash,
              size: 13,
              color: colors.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          t.categories.importEmptyTab,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to edit a single preview item: name, icon, color. The
/// type/parent relationship is locked here — those are decided by the CSV
/// shape and editing them mid-preview would create cross-tab confusion.
class _EditItemSheet extends StatefulWidget {
  const _EditItemSheet({required this.item});

  final CategoryImportPreviewItem item;

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late final TextEditingController _nameController;
  late int _icon;
  late int _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _icon = widget.item.icon;
    _color = widget.item.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      widget.item.copyWith(name: name, icon: _icon, color: _color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onBackgroundLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.categories.importEditTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + viewInsets),
                children: [
                  _PreviewTile(
                    name: _nameController.text.trim().isEmpty
                        ? t.categories.nameHint
                        : _nameController.text.trim(),
                    icon: _icon,
                    color: _color,
                  ),
                  const SizedBox(height: 16),
                  FinancoTextField(
                    controller: _nameController,
                    label: t.categories.name,
                    hintText: t.categories.nameHint,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.categories.selectColor.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CategoryColorPicker(
                    selected: _color,
                    onChanged: (c) => setState(() => _color = c),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.categories.selectIcon.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CategoryIconPickerLauncher(
                    selectedIcon: _icon,
                    color: _color,
                    onChanged: (i) => setState(() => _icon = i),
                  ),
                ],
              ),
            ),
            FinancoSubmitBar(
              label: t.general.save,
              onSubmit: _save,
              isEnabled: _nameController.text.trim().isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final int icon;
  final int color;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.18),
            tint.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                materialIconFor(icon),
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
