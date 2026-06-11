import 'package:financo/app/widgets/financo_category_avatar.dart';
import 'package:financo/app/widgets/financo_search_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/utils/category_display_order.dart';
import 'package:financo/features/categories/presentation/utils/category_query_filter.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modal bottom sheet for picking a category. Filters by transaction type
/// — expense transactions show expense categories, income shows income —
/// and indents subcategories under their parent.
Future<String?> showTransactionCategoryPicker({
  required BuildContext context,
  required TransactionType transactionType,
  required String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _CategoryPickerSheet(
      transactionType: transactionType,
      selectedId: selectedId,
    ),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.transactionType,
    required this.selectedId,
  });

  final TransactionType transactionType;
  final String? selectedId;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
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
    final wantedType = widget.transactionType == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;
    final allOfType = context
        .watch<CategoriesCubit>()
        .state
        .categoriesOrEmpty
        .where((c) => c.type == wantedType)
        .toList();
    final filtered = filterCategoriesByQuery(all: allOfType, query: _query);
    final categories = organizeCategoriesForDisplay(filtered);
    final hasNoCategoriesAtAll = allOfType.isEmpty;
    final hasNoSearchResults = !hasNoCategoriesAtAll && categories.isEmpty;

    return DraggableScrollableSheet(
      minChildSize: 0.3,
      maxChildSize: 0.85,
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
                  t.payablesReceivables.pickCategory,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!hasNoCategoriesAtAll)
              FinancoSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                hintText: t.categories.searchHint,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
            Expanded(
              child: hasNoCategoriesAtAll
                  ? _Empty(
                      message: widget.transactionType == TransactionType.income
                          ? t.payablesReceivables.noIncomeCategory
                          : t.payablesReceivables.noExpenseCategory,
                    )
                  : hasNoSearchResults
                  ? _Empty(message: t.categories.searchNoResults)
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final c = categories[i];
                        return _CategoryRow(
                          category: c,
                          allCategories: allOfType,
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
    required this.allCategories,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryEntity category;
  final Iterable<CategoryEntity> allCategories;
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
          padding: EdgeInsets.fromLTRB(
            category.isSubcategory ? 36 : 12,
            10,
            12,
            10,
          ),
          child: Row(
            children: [
              FinancoCategoryAvatar(
                category: category,
                allCategories: allCategories,
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

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
