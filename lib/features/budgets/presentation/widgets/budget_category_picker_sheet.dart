import 'package:financo/app/widgets/financo_category_avatar.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
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
    final all =
        context
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

    return FinancoPickerSheet(
      title: t.budgets.categoryHint,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      header: [
        if (!hasNoneAtAll)
          FinancoSearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            hintText: t.categories.searchHint,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
      ],
      bodyBuilder: (scrollController) => _buildBody(
        scrollController: scrollController,
        filtered: filtered,
        hasNoneAtAll: hasNoneAtAll,
      ),
    );
  }

  Widget _buildBody({
    required ScrollController scrollController,
    required List<CategoryEntity> filtered,
    required bool hasNoneAtAll,
  }) {
    if (hasNoneAtAll) {
      return FinancoPickerSheetEmpty(
        message: widget.excludedIds.isEmpty
            ? t.budgets.noExpenseCategory
            : t.budgets.allCategoriesBudgeted,
      );
    }
    if (filtered.isEmpty) {
      return FinancoPickerSheetEmpty(message: t.categories.searchNoResults);
    }
    return ListView.separated(
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
              FinancoCategoryAvatar(category: category),
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
