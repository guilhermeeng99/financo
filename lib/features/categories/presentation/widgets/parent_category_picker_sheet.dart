import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/app/widgets/financo_search_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/utils/category_query_filter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Bottom sheet that lets the user pick a parent category (or "None").
/// Replaces the dropdown — same shape as the shared category picker so the
/// app stays consistent.
///
/// Returns:
///   - `null`     → sheet dismissed without choosing
///   - `''` (empty string) → user picked "No parent"
///   - any other value → the chosen category id
Future<String?> showParentCategoryPicker({
  required BuildContext context,
  required List<CategoryEntity> options,
  required String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _ParentPickerSheet(
      options: options,
      selectedId: selectedId,
    ),
  );
}

class _ParentPickerSheet extends StatefulWidget {
  const _ParentPickerSheet({
    required this.options,
    required this.selectedId,
  });

  final List<CategoryEntity> options;
  final String? selectedId;

  @override
  State<_ParentPickerSheet> createState() => _ParentPickerSheetState();
}

class _ParentPickerSheetState extends State<_ParentPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterCategoriesByQuery(
      all: widget.options,
      query: _query,
    );
    // "No parent" row stays available regardless of search query — it's
    // not a category, it's an action. Keeping it visible while typing
    // means the user can always pick "make this top-level" without
    // clearing the search box first.
    final showNoneRow = _query.trim().isEmpty;
    final hasResults = filtered.isNotEmpty || showNoneRow;

    return FinancoPickerSheet(
      title: t.categories.pickParent,
      header: [
        if (widget.options.isNotEmpty)
          FinancoSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            hintText: t.categories.searchHint,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
      ],
      bodyBuilder: (scrollController) {
        if (!hasResults) {
          return FinancoPickerSheetEmpty(
            message: t.categories.searchNoResults,
          );
        }
        return _buildList(scrollController, filtered, showNoneRow);
      },
    );
  }

  Widget _buildList(
    ScrollController scrollController,
    List<CategoryEntity> filtered,
    bool showNoneRow,
  ) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      itemCount: filtered.length + (showNoneRow ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        if (showNoneRow && i == 0) {
          return _NoneRow(
            isSelected: widget.selectedId == null,
            onTap: () => Navigator.pop(context, ''),
          );
        }
        final c = filtered[i - (showNoneRow ? 1 : 0)];
        return _CategoryRow(
          category: c,
          isSelected: c.id == widget.selectedId,
          onTap: () => Navigator.pop(context, c.id),
        );
      },
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.minus,
                    size: 14,
                    color: colors.onBackgroundLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.categories.noParent,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                FaIcon(
                  FontAwesomeIcons.check,
                  size: 14,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(category.color);
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    materialIconFor(category.icon),
                    size: 18,
                    color: tint,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                FaIcon(
                  FontAwesomeIcons.check,
                  size: 14,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
