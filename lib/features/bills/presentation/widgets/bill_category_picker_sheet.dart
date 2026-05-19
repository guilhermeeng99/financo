import 'package:financo/app/widgets/financo_search_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/utils/category_display_order.dart';
import 'package:financo/features/categories/presentation/utils/category_query_filter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modal bottom sheet for picking a category. Filters by `billType` so the
/// list only contains categories whose type matches (expense for payable,
/// income for receivable). Subcategories are indented under their parent.
///
/// Usage:
///   final id = await showBillCategoryPicker(
///     context: context,
///     billType: state.type,
///     selectedId: state.categoryId,
///   );
Future<String?> showBillCategoryPicker({
  required BuildContext context,
  required BillType billType,
  required String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _BillCategoryPickerSheet(
      billType: billType,
      selectedId: selectedId,
    ),
  );
}

class _BillCategoryPickerSheet extends StatefulWidget {
  const _BillCategoryPickerSheet({
    required this.billType,
    required this.selectedId,
  });

  final BillType billType;
  final String? selectedId;

  @override
  State<_BillCategoryPickerSheet> createState() =>
      _BillCategoryPickerSheetState();
}

class _BillCategoryPickerSheetState extends State<_BillCategoryPickerSheet> {
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
    final wantedType = widget.billType == BillType.receivable
        ? CategoryType.income
        : CategoryType.expense;
    final allOfType = context
        .watch<CategoriesCubit>()
        .state
        .categoriesOrEmpty
        .where((c) => c.type == wantedType)
        .toList();
    // Match against pre-filtered list, then re-organize so subcategories
    // still render indented under their parent — when the parent matches
    // and the child doesn't, the child still appears beneath it.
    final filtered = filterCategoriesByQuery(all: allOfType, query: _query);
    final categories = organizeCategoriesForDisplay(filtered);
    final hasNoCategoriesAtAll = allOfType.isEmpty;
    final hasNoSearchResults = !hasNoCategoriesAtAll && categories.isEmpty;

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
                  t.bills.pickCategory,
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
                  ? _EmptyHint(
                      message: widget.billType == BillType.receivable
                          ? t.bills.noIncomeCategory
                          : t.bills.noExpenseCategory,
                    )
                  : hasNoSearchResults
                      ? _EmptyHint(message: t.categories.searchNoResults)
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                          itemCount: categories.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 4),
                          itemBuilder: (_, i) {
                            final c = categories[i];
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
          padding: EdgeInsets.fromLTRB(
            category.isSubcategory ? 36 : 12,
            10,
            12,
            10,
          ),
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
                    materialIconFor(category.icon),
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
