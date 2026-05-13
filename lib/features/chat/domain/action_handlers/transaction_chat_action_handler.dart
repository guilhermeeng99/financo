import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/action_handlers/account_resolver.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class TransactionChatActionHandler implements ChatActionHandler {
  TransactionChatActionHandler({
    required GetAccountsUseCase getAccounts,
    required GetCategoriesUseCase getCategories,
    required CreateTransactionUseCase createTransaction,
  }) : _getAccounts = getAccounts,
       _getCategories = getCategories,
       _createTransaction = createTransaction;

  final GetAccountsUseCase _getAccounts;
  final GetCategoriesUseCase _getCategories;
  final CreateTransactionUseCase _createTransaction;

  @override
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.invalidAmount;

    final categoryName = (meta['category'] as String? ?? '').trim();
    if (categoryName.isEmpty) return strings.chat.handlers.categoryRequired;

    final catResult = await _getCategories(userId: userId);
    // If we can't reach the data, let the action through — better than a
    // false negative blocking a legitimate request.
    if (catResult.isLeft()) return null;
    final categories = catResult.getOrElse(() => []);
    final hasCategory = categories.any(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
    );
    if (!hasCategory) {
      return strings.chat.handlers
          .categoryNotFoundCreateFirst(name: categoryName);
    }

    final accResult = await _getAccounts(userId: userId);
    if (accResult.isLeft()) return null;
    final accounts = accResult.getOrElse(() => []);
    if (accounts.isEmpty) {
      return strings.chat.handlers.transactionCreateAccountFirst;
    }
    final accountName = (meta['account'] as String? ?? '').trim();
    final resolution = resolveAccount(accounts, accountName, locale: locale);
    if (!resolution.isResolved) return resolution.error;
    return null;
  }

  @override
  Future<String> handle({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final typeStr = meta['type'] as String? ?? 'expense';
    final txType = typeStr == 'income'
        ? TransactionType.income
        : TransactionType.expense;

    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.invalidAmount;

    final description = meta['description'] as String? ?? '';
    final dateStr = meta['date'] as String?;
    final date = dateStr != null
        ? DateTime.tryParse(dateStr) ?? DateTime.now()
        : DateTime.now();

    final categoryName = meta['category'] as String? ?? '';
    final catResult = await _getCategories(userId: userId);
    if (catResult.isLeft()) {
      return strings.chat.handlers.transactionLoadCategoriesFailed;
    }
    final categories = catResult.getOrElse(() => []);
    final matchedCat = categories
        .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
        .toList();
    if (matchedCat.isEmpty) {
      return strings.chat.handlers
          .categoryNotFoundCreateFirst(name: categoryName);
    }

    final accountName = meta['account'] as String? ?? '';
    final accResult = await _getAccounts(userId: userId);
    if (accResult.isLeft()) {
      return strings.chat.handlers.transactionLoadAccountsFailed;
    }
    final accounts = accResult.getOrElse(() => []);
    if (accounts.isEmpty) {
      return strings.chat.handlers.transactionCreateAccountFirst;
    }
    final resolution = resolveAccount(accounts, accountName, locale: locale);
    final account = resolution.account;
    if (account == null) {
      return resolution.error ??
          strings.chat.handlers.transactionUnresolvedAccount;
    }

    final transaction = TransactionEntity(
      id: '',
      userId: userId,
      accountId: account.id,
      categoryId: matchedCat.first.id,
      type: txType,
      amount: amount,
      description: description,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _createTransaction(transaction);
    return result.fold(
      (f) => strings.chat.handlers.transactionCreateFailed(error: f.message),
      (tx) => strings.chat.handlers.transactionCreated(
        description: tx.description,
        amount: formatCurrency(tx.amount),
      ),
    );
  }
}
