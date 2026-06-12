import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// List of parsed CSV rows on the categories import preview, filtered to
/// the selected [filter] type and grouped as root → its subcategories
/// (alphabetical), with orphaned subcategories last. Duplicates render at
/// the bottom, dimmed and non-interactive. Callbacks receive the row's
/// index in the *unfiltered* [items] list so the page can edit/remove the
/// right entry.
class CategoryImportRowsList extends StatelessWidget {
  const CategoryImportRowsList({
    required this.items,
    required this.duplicates,
    required this.filter,
    required this.onTap,
    required this.onRemove,
    super.key,
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
      return ImportEmptyTab(message: t.categories.importEmptyTab);
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
      (a, b) => a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()),
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
                    ImportRemoveButton(onPressed: onRemove!),
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
