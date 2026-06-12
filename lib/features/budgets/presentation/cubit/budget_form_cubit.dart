import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Form state for creating or editing a budget. The `categoryId` selector is
/// hidden in edit mode (immutable post-creation per spec rule 3).
class BudgetFormCubit extends Cubit<BudgetFormState> {
  BudgetFormCubit({
    required CreateBudgetUseCase createBudget,
    required UpdateBudgetUseCase updateBudget,
    required GetBudgetsUseCase getBudgets,
    required String userId,
    BudgetEntity? existingBudget,
  }) : _createBudget = createBudget,
       _updateBudget = updateBudget,
       _getBudgets = getBudgets,
       super(BudgetFormState.initial(userId: userId, existing: existingBudget));

  final CreateBudgetUseCase _createBudget;
  final UpdateBudgetUseCase _updateBudget;
  final GetBudgetsUseCase _getBudgets;

  /// Loads the category ids the user has already budgeted, so the picker
  /// can hide them in create mode (one budget per category — spec rule 1).
  /// Called once when the form opens; failures degrade to an empty set
  /// (the repository re-enforces uniqueness on submit anyway).
  Future<void> loadBudgetedCategoryIds() async {
    final result = await _getBudgets(userId: state.userId);
    if (isClosed) return;
    final ids = result.fold<Set<String>>(
      (_) => const {},
      (budgets) => budgets.map((b) => b.categoryId).toSet(),
    );
    emit(state.copyWith(budgetedCategoryIds: ids));
  }

  void updateCategoryId(String? id) {
    if (state.isEditing) return; // immutable after creation
    emit(state.copyWith(categoryId: id, clearCategory: id == null));
  }

  void updateAmount(String value) {
    final parsed = parseDecimalAmount(value) ?? 0;
    emit(state.copyWith(amount: parsed));
  }

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final now = DateTime.now();
    final budget = BudgetEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      categoryId: state.categoryId!,
      amount: state.amount,
      createdAt: state.existingCreatedAt ?? now,
      updatedAt: now,
    );

    (state.isEditing
            ? await _updateBudget(budget)
            : await _createBudget(budget))
        .fold(
          (failure) => emit(
            state.copyWith(
              status: FormStatus.failure,
              failure: failure,
            ),
          ),
          (_) => emit(state.copyWith(status: FormStatus.success)),
        );
  }
}

class BudgetFormState extends Equatable {
  const BudgetFormState({
    required this.userId,
    required this.amount,
    required this.status,
    this.budgetedCategoryIds = const {},
    this.categoryId,
    this.existingId,
    this.existingCreatedAt,
    this.failure,
  });

  factory BudgetFormState.initial({
    required String userId,
    BudgetEntity? existing,
  }) {
    return BudgetFormState(
      userId: userId,
      amount: existing?.amount ?? 0,
      status: FormStatus.initial,
      categoryId: existing?.categoryId,
      existingId: existing?.id,
      existingCreatedAt: existing?.createdAt,
    );
  }

  final String userId;
  final String? categoryId;
  final double amount;
  final FormStatus status;

  /// Categories the user has already budgeted — drives the picker's
  /// exclusion list. Populated by
  /// [BudgetFormCubit.loadBudgetedCategoryIds]; the form's own current
  /// `categoryId` is excluded from this set in edit mode by the page so
  /// re-saving the same record doesn't fight itself.
  final Set<String> budgetedCategoryIds;
  final String? existingId;
  final DateTime? existingCreatedAt;
  final Failure? failure;

  bool get isEditing => existingId != null;

  bool get isValid {
    if (categoryId == null || categoryId!.isEmpty) return false;
    if (amount <= 0) return false;
    return true;
  }

  BudgetFormState copyWith({
    String? categoryId,
    bool clearCategory = false,
    double? amount,
    FormStatus? status,
    Set<String>? budgetedCategoryIds,
    Failure? failure,
  }) {
    return BudgetFormState(
      userId: userId,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      amount: amount ?? this.amount,
      status: status ?? this.status,
      budgetedCategoryIds: budgetedCategoryIds ?? this.budgetedCategoryIds,
      existingId: existingId,
      existingCreatedAt: existingCreatedAt,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    categoryId,
    amount,
    status,
    budgetedCategoryIds,
    existingId,
    existingCreatedAt,
    failure,
  ];
}
