import 'package:financo/app/widgets/financo_search_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modal bottom sheet for picking the root expense category to budget.
///
/// Filters out:
/// - non-expense categories (budgets are expense-only — spec rule 2)
/// - subcategories (parent-only — spec rule 2)
/// - categories whose id is in [excludedIds] (those already have a budget
///   in create mode; the calling form passes the existing budget set so
///   the user can't pick the same category twice)
Future<String?> showBudgetCategoryPicker({
  required BuildContext context,
  required String? selectedId,
  required Set<String> excludedIds,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _BudgetCategoryPickerSheet(
      selectedId: selectedId,
      excludedIds: excludedIds,
    ),
  );
}

class _BudgetCategoryPickerSheet extends StatefulWidget {
  const _BudgetCategoryPickerSheet({
    required this.selectedId,
    required this.excludedIds,
  });

  final String? selectedId;
  final Set<String> excludedIds;

  @override
  State<_BudgetCategoryPickerSheet> createState() =>
      _BudgetCategoryPickerSheetState();
}

class _BudgetCategoryPickerSheetState
    extends State<_BudgetCategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final all = context
        .watch<CategoriesCubit>()
        .state
        .categoriesOrEmpty
        .where((c) => c.type == CategoryType.expense && c.canBeParent)
        .where((c) => !widget.excludedIds.contains(c.id))
        .toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    final filtered = _query.trim().isEmpty
        ? all
        : all
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_query.trim().toLowerCase()),
              )
              .toList();

    final hasNoneAtAll = all.isEmpty;
    final hasNoSearchHits = !hasNoneAtAll && filtered.isEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
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
                  t.budgets.categoryHint,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!hasNoneAtAll)
              FinancoSearchField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                hintText: t.categories.searchHint,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
            Expanded(
              child: hasNoneAtAll
                  ? _EmptyHint(
                      message: widget.excludedIds.isEmpty
                          ? t.budgets.noExpenseCategory
                          : t.budgets.allCategoriesBudgeted,
                    )
                  : hasNoSearchHits
                  ? _EmptyHint(message: t.categories.searchNoResults)
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return _CategoryRow(
                          category: c,
                          isSelected: c.id == widget.selectedId,
                          onTap: () => Navigator.pop(context, c.id),
                        );
                      },
                    ),
            ),
          ],
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
    final categoryColor = Color(category.color);
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
                  color: categoryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    IconData(category.icon, fontFamily: 'MaterialIcons'),
                    size: 18,
                    color: categoryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
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

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
