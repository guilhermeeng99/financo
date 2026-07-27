import 'package:financo/app/widgets/financo_category_avatar.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
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

    return FinancoPickerSheet(
      title: t.payablesReceivables.pickCategory,
      header: [
        if (!hasNoCategoriesAtAll)
          FinancoSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            hintText: t.categories.searchHint,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
      ],
      bodyBuilder: (scrollController) => _buildBody(
        scrollController: scrollController,
        allOfType: allOfType,
        categories: categories,
        hasNoCategoriesAtAll: hasNoCategoriesAtAll,
      ),
    );
  }

  Widget _buildBody({
    required ScrollController scrollController,
    required List<CategoryEntity> allOfType,
    required List<CategoryEntity> categories,
    required bool hasNoCategoriesAtAll,
  }) {
    if (hasNoCategoriesAtAll) {
      return FinancoPickerSheetEmpty(
        message: widget.transactionType == TransactionType.income
            ? t.payablesReceivables.noIncomeCategory
            : t.payablesReceivables.noExpenseCategory,
      );
    }
    if (categories.isEmpty) {
      return FinancoPickerSheetEmpty(message: t.categories.searchNoResults);
    }
    return ListView.separated(
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
          // While searching, the parent may be filtered out and matches lose
          // their grouping — show each subcategory's parent so an ambiguous
          // name (e.g. "Saúde" under "Gatos") reads clearly.
          showParent: _query.trim().isNotEmpty,
          onTap: () => Navigator.pop(context, c.id),
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.allCategories,
    required this.isSelected,
    required this.showParent,
    required this.onTap,
  });

  final CategoryEntity category;
  final Iterable<CategoryEntity> allCategories;
  final bool isSelected;

  /// When true, a subcategory shows its parent's name beneath it (used while
  /// searching, where the grouping indentation no longer conveys the parent).
  final bool showParent;
  final VoidCallback onTap;

  /// The parent category's name, or null when this is a root or the parent
  /// isn't in the list.
  String? _parentName() {
    final parentId = category.parentId;
    if (parentId == null) return null;
    for (final candidate in allCategories) {
      if (candidate.id == parentId) return candidate.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final parentName = showParent ? _parentName() : null;
    // Indentation groups subcategories under their parent in the normal
    // (unsearched) view; while searching the parent name (subtitle) carries
    // that context instead, so the rows sit flush-left.
    final leftPadding = showParent
        ? 12.0
        : (category.isSubcategory ? 36.0 : 12.0);
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.fromLTRB(leftPadding, 10, 12, 10),
          child: Row(
            children: [
              FinancoCategoryAvatar(
                category: category,
                allCategories: allCategories,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
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
                    if (parentName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        parentName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
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
