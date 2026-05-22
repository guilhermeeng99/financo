import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// Pure compute behind the category drill-down dialog. Kept out of the widget
/// so the membership rule and the per-subcategory rollup are testable and the
/// dialog only renders.

/// Expense (non-transfer) transactions booked on [parentCategoryId] itself or
/// on any of its subcategories, newest first.
List<TransactionEntity> filterTransactionsForCategory({
  required String parentCategoryId,
  required List<TransactionEntity> periodTransactions,
  required Map<String, CategoryEntity> categoryMap,
}) {
  bool belongs(TransactionEntity tx) {
    if (tx.isTransfer) return false;
    if (tx.type != TransactionType.expense) return false;
    if (tx.categoryId == parentCategoryId) return true;
    return categoryMap[tx.categoryId]?.parentId == parentCategoryId;
  }

  return periodTransactions.where(belongs).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

/// Per-subcategory totals for the drill-down breakdown, largest first.
/// Amounts booked directly on the parent are excluded (the breakdown is about
/// where inside the parent the money went). [fallbackName] / [fallbackColor]
/// cover transactions whose category id is missing from [categoryMap], keeping
/// this domain code free of i18n.
List<CategoryAmount> aggregateSubcategorySpend({
  required String parentCategoryId,
  required List<TransactionEntity> transactions,
  required Map<String, CategoryEntity> categoryMap,
  required String fallbackName,
  int fallbackColor = 0xFF9E9E9E,
}) {
  final amounts = <String, double>{};
  for (final tx in transactions) {
    if (tx.categoryId == parentCategoryId) continue;
    amounts[tx.categoryId] = (amounts[tx.categoryId] ?? 0) + tx.amount;
  }

  return amounts.entries.map((e) {
    final cat = categoryMap[e.key];
    return CategoryAmount(
      categoryId: e.key,
      categoryName: cat?.name ?? fallbackName,
      categoryColor: cat?.color ?? fallbackColor,
      amount: e.value,
    );
  }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
}
