import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class BudgetChatActionHandler implements ChatActionHandler {
  BudgetChatActionHandler({
    required GetCategoriesUseCase getCategories,
    required GetBudgetsUseCase getBudgets,
    required CreateBudgetUseCase createBudget,
    required UpdateBudgetUseCase updateBudget,
    required DeleteBudgetUseCase deleteBudget,
  }) : _getCategories = getCategories,
       _getBudgets = getBudgets,
       _createBudget = createBudget,
       _updateBudget = updateBudget,
       _deleteBudget = deleteBudget;

  final GetCategoriesUseCase _getCategories;
  final GetBudgetsUseCase _getBudgets;
  final CreateBudgetUseCase _createBudget;
  final UpdateBudgetUseCase _updateBudget;
  final DeleteBudgetUseCase _deleteBudget;

  @override
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final action = (meta['action'] as String?) ?? '';
    final categoryName = (meta['category'] as String? ?? '').trim();
    if (categoryName.isEmpty) {
      return strings.chat.handlers.budgetCategoryRequired;
    }

    final catResult = await _getCategories(userId: userId);
    if (catResult.isLeft()) return null;
    final categories = catResult.getOrElse(() => []);
    final matched = categories
        .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
        .toList();
    if (matched.isEmpty) {
      return strings.chat.handlers
          .budgetCategoryNotFoundCreate(name: categoryName);
    }
    final cat = matched.first;
    if (cat.type != CategoryType.expense) {
      return strings.chat.handlers.budgetExpenseOnly;
    }
    if (cat.parentId != null) {
      final parentName = categories
          .firstWhere(
            (c) => c.id == cat.parentId,
            orElse: () => cat,
          )
          .name;
      return strings.chat.handlers.budgetRootCategoryOnly(name: parentName);
    }

    if (action == 'create' || action == 'update' || action == 'delete') {
      final budgetsResult = await _getBudgets(userId: userId);
      if (budgetsResult.isLeft()) return null;
      final budgets = budgetsResult.getOrElse(() => []);
      final existing = budgets.where((b) => b.categoryId == cat.id).toList();
      if (action == 'create' && existing.isNotEmpty) {
        return strings.chat.handlers.budgetAlreadyExists(name: categoryName);
      }
      if ((action == 'update' || action == 'delete') && existing.isEmpty) {
        return strings.chat.handlers.budgetDoesNotExist(name: categoryName);
      }
    }

    if (action == 'create' || action == 'update') {
      final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
      if (amount <= 0) return strings.chat.handlers.budgetAmountPositive;
    }
    return null;
  }

  @override
  Future<String> handle({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final action = meta['action'] as String?;
    final categoryName = (meta['category'] as String? ?? '').trim();
    if (categoryName.isEmpty) {
      return strings.chat.handlers.budgetCategoryRequired;
    }

    final catResult = await _getCategories(userId: userId);
    if (catResult.isLeft()) {
      return strings.chat.handlers.budgetLoadCategoriesFailed;
    }
    final categories = catResult.getOrElse(() => []);
    final cat = categories
        .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
        .firstOrNull;
    if (cat == null) {
      return strings.chat.handlers.budgetCategoryNotFound(name: categoryName);
    }

    switch (action) {
      case 'create':
        return _create(
          userId: userId,
          meta: meta,
          category: cat,
          locale: locale,
        );
      case 'update':
        return _update(
          userId: userId,
          meta: meta,
          category: cat,
          locale: locale,
        );
      case 'delete':
        return _delete(userId: userId, category: cat, locale: locale);
      default:
        return strings.chat.handlers.unknownBudgetAction;
    }
  }

  Future<String> _create({
    required String userId,
    required Map<String, dynamic> meta,
    required CategoryEntity category,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.invalidAmount;
    final now = DateTime.now();
    final budget = BudgetEntity(
      id: '',
      userId: userId,
      categoryId: category.id,
      amount: amount,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _createBudget(budget);
    return result.fold(
      (f) => strings.chat.handlers.budgetCreateFailed(error: f.message),
      (b) => strings.chat.handlers.budgetCreated(
        amount: formatCurrency(b.amount),
        name: category.name,
      ),
    );
  }

  Future<String> _update({
    required String userId,
    required Map<String, dynamic> meta,
    required CategoryEntity category,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.invalidAmount;
    final budgetsResult = await _getBudgets(userId: userId);
    if (budgetsResult.isLeft()) {
      return strings.chat.handlers.budgetLoadFailed;
    }
    final budgets = budgetsResult.getOrElse(() => []);
    final existing = budgets
        .where((b) => b.categoryId == category.id)
        .firstOrNull;
    if (existing == null) {
      return strings.chat.handlers.budgetNoActive(name: category.name);
    }
    final updated = existing.copyWith(
      amount: amount,
      updatedAt: DateTime.now(),
    );
    final result = await _updateBudget(updated);
    return result.fold(
      (f) => strings.chat.handlers.budgetUpdateFailed(error: f.message),
      (b) => strings.chat.handlers.budgetUpdated(
        name: category.name,
        amount: formatCurrency(b.amount),
      ),
    );
  }

  Future<String> _delete({
    required String userId,
    required CategoryEntity category,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final budgetsResult = await _getBudgets(userId: userId);
    if (budgetsResult.isLeft()) {
      return strings.chat.handlers.budgetLoadFailed;
    }
    final budgets = budgetsResult.getOrElse(() => []);
    final existing = budgets
        .where((b) => b.categoryId == category.id)
        .firstOrNull;
    if (existing == null) {
      return strings.chat.handlers.budgetNoActive(name: category.name);
    }
    final result = await _deleteBudget(existing.id);
    return result.fold(
      (f) => strings.chat.handlers.budgetDeleteFailed(error: f.message),
      (_) => strings.chat.handlers.budgetDeleted(name: category.name),
    );
  }
}
