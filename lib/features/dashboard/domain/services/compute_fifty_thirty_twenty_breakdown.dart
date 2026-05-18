import 'package:equatable/equatable.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// One row in the per-bucket category breakdown rendered on the
/// `FiftyThirtyTwentyPage`. Identifies the root category and how much
/// it spent in the period.
class FiftyThirtyTwentyBreakdownRow extends Equatable {
  const FiftyThirtyTwentyBreakdownRow({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
  });

  final String categoryId;
  final String categoryName;
  final int categoryIcon;
  final int categoryColor;
  final double amount;

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    amount,
  ];
}

/// Three lists of [FiftyThirtyTwentyBreakdownRow] grouping the period's
/// expense spend by bucket. Each list is sorted by amount descending
/// (largest first) — the page surfaces these as ranked lists so the
/// user can spot the categories doing the most damage in a glance.
class FiftyThirtyTwentyBreakdown extends Equatable {
  const FiftyThirtyTwentyBreakdown({
    required this.needs,
    required this.wants,
    required this.unclassified,
  });

  static const empty = FiftyThirtyTwentyBreakdown(
    needs: [],
    wants: [],
    unclassified: [],
  );

  final List<FiftyThirtyTwentyBreakdownRow> needs;
  final List<FiftyThirtyTwentyBreakdownRow> wants;
  final List<FiftyThirtyTwentyBreakdownRow> unclassified;

  @override
  List<Object?> get props => [needs, wants, unclassified];
}

/// Pure helper that buckets a period's expense transactions by the
/// resolved root category's bucket. Subcategories roll up into the
/// parent (mirrors `compute50_30_20Overview`'s rule 20 handling).
/// Orphan transactions land under `unclassified` with a synthetic
/// "Sem categoria" row keyed by the orphan id.
FiftyThirtyTwentyBreakdown compute50_30_20Breakdown({
  required List<TransactionEntity> periodTransactions,
  required List<CategoryEntity> categories,
}) {
  final byId = <String, CategoryEntity>{
    for (final c in categories) c.id: c,
  };

  // categoryId → running amount per bucket
  final needsAmounts = <String, double>{};
  final wantsAmounts = <String, double>{};
  final unclassifiedAmounts = <String, double>{};

  for (final t in periodTransactions) {
    if (t.type != TransactionType.expense) continue;
    if (t.isTransfer) continue;

    final cat = byId[t.categoryId];
    if (cat == null) {
      // Orphan — use the dangling id as the bucket key so multiple
      // transactions referencing the same missing category aggregate.
      unclassifiedAmounts[t.categoryId] =
          (unclassifiedAmounts[t.categoryId] ?? 0) + t.amount;
      continue;
    }
    final root = cat.parentId == null ? cat : byId[cat.parentId];
    if (root == null) {
      // Orphan parent — subcategory bucket key (no parent to roll up to).
      unclassifiedAmounts[cat.id] =
          (unclassifiedAmounts[cat.id] ?? 0) + t.amount;
      continue;
    }

    final target = switch (root.bucket) {
      CategoryBucket.needs => needsAmounts,
      CategoryBucket.wants => wantsAmounts,
      null => unclassifiedAmounts,
    };
    target[root.id] = (target[root.id] ?? 0) + t.amount;
  }

  return FiftyThirtyTwentyBreakdown(
    needs: _toRows(needsAmounts, byId),
    wants: _toRows(wantsAmounts, byId),
    unclassified: _toRows(unclassifiedAmounts, byId),
  );
}

List<FiftyThirtyTwentyBreakdownRow> _toRows(
  Map<String, double> amounts,
  Map<String, CategoryEntity> byId,
) {
  final rows = amounts.entries.map((e) {
    final cat = byId[e.key];
    return FiftyThirtyTwentyBreakdownRow(
      categoryId: e.key,
      categoryName: cat?.name ?? 'Sem categoria',
      categoryIcon: cat?.icon ?? 58332,
      categoryColor: cat?.color ?? 0xFF9E9E9E,
      amount: e.value,
    );
  }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
  return rows;
}
