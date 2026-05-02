import 'package:equatable/equatable.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';

/// Threshold buckets used to colour budget progress at the UI layer.
///
/// Boundaries (uncapped — i.e. computed from raw `spent / amount`):
/// - `safe`     → percentage `< 0.8`
/// - `warning`  → `0.8 <= percentage < 1.0`
/// - `exceeded` → `percentage >= 1.0`
enum BudgetStatus { safe, warning, exceeded }

/// Presentation entity that combines a [BudgetEntity] with its current-month
/// spending totals and resolved category metadata. Built by
/// `GetBudgetsOverviewUseCase` so the page renders this directly without
/// having to cross-reference categories/transactions itself.
class BudgetOverview extends Equatable {
  const BudgetOverview({
    required this.budget,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.spent,
  });

  final BudgetEntity budget;
  final String categoryName;
  final int categoryIcon;
  final int categoryColor;
  final double spent;

  /// Amount still available before the cap is reached. Clamped at 0 — once
  /// spending exceeds the cap, [overspent] grows instead.
  double get remaining {
    final r = budget.amount - spent;
    return r < 0 ? 0 : r;
  }

  /// Amount above the cap (`spent > amount`). 0 unless exceeded.
  double get overspent {
    final o = spent - budget.amount;
    return o < 0 ? 0 : o;
  }

  /// Uncapped ratio of spent to amount. `1.20` means 120% of the cap was
  /// used. Callers that need a progress bar value should clamp this to
  /// `[0, 1]` themselves.
  double get percentage {
    if (budget.amount <= 0) return 0;
    return spent / budget.amount;
  }

  BudgetStatus get status {
    final p = percentage;
    if (p >= 1.0) return BudgetStatus.exceeded;
    if (p >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }

  @override
  List<Object?> get props => [
    budget,
    categoryName,
    categoryIcon,
    categoryColor,
    spent,
  ];
}
