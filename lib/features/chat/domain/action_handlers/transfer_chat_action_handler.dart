import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/chat/domain/action_handlers/account_resolver.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class TransferChatActionHandler implements ChatActionHandler {
  TransferChatActionHandler({
    required GetAccountsUseCase getAccounts,
    required CreateTransferUseCase createTransfer,
  }) : _getAccounts = getAccounts,
       _createTransfer = createTransfer;

  final GetAccountsUseCase _getAccounts;
  final CreateTransferUseCase _createTransfer;

  @override
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.invalidAmount;

    final fromName = (meta['from'] as String? ?? '').trim();
    final toName = (meta['to'] as String? ?? '').trim();
    if (fromName.isEmpty || toName.isEmpty) {
      return strings.chat.handlers.transferAccountsRequired;
    }

    final accResult = await _getAccounts(userId: userId);
    if (accResult.isLeft()) return null;
    final accounts = accResult.getOrElse(() => []);
    if (accounts.length < 2) {
      return strings.chat.handlers.transferMinTwoAccounts;
    }
    final fromR = resolveAccount(accounts, fromName, locale: locale);
    if (!fromR.isResolved) return fromR.error;
    final toR = resolveAccount(accounts, toName, locale: locale);
    if (!toR.isResolved) return toR.error;
    if (fromR.account!.id == toR.account!.id) {
      return strings.chat.handlers.transferSourceDestSame;
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
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.invalidAmount;

    final fromName = (meta['from'] as String? ?? '').trim();
    final toName = (meta['to'] as String? ?? '').trim();
    if (fromName.isEmpty || toName.isEmpty) {
      return strings.chat.handlers.transferAccountsRequired;
    }

    final accResult = await _getAccounts(userId: userId);
    if (accResult.isLeft()) {
      return strings.chat.handlers.transactionLoadAccountsFailed;
    }
    final accounts = accResult.getOrElse(() => []);
    if (accounts.length < 2) {
      return strings.chat.handlers.transferMinTwoAccounts;
    }

    final fromR = resolveAccount(accounts, fromName, locale: locale);
    final fromAccount = fromR.account;
    if (fromAccount == null) {
      return fromR.error ?? strings.chat.handlers.transferUnresolvedSource;
    }
    final toR = resolveAccount(accounts, toName, locale: locale);
    final toAccount = toR.account;
    if (toAccount == null) {
      return toR.error ?? strings.chat.handlers.transferUnresolvedDestination;
    }
    if (fromAccount.id == toAccount.id) {
      return strings.chat.handlers.transferSourceDestSame;
    }

    final description = meta['description'] as String? ?? '';
    final dateStr = meta['date'] as String?;
    final date = dateStr != null
        ? DateTime.tryParse(dateStr) ?? DateTime.now()
        : DateTime.now();
    final now = DateTime.now();

    final expense = TransactionEntity(
      id: '',
      userId: userId,
      accountId: fromAccount.id,
      categoryId: '',
      type: TransactionType.expense,
      amount: amount,
      description: description,
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    final income = TransactionEntity(
      id: '',
      userId: userId,
      accountId: toAccount.id,
      categoryId: '',
      type: TransactionType.income,
      amount: amount,
      description: description,
      date: date,
      createdAt: now,
      updatedAt: now,
    );

    final result = await _createTransfer(expense: expense, income: income);
    return result.fold(
      (f) => strings.chat.handlers.transferCreateFailed(error: f.message),
      (_) => strings.chat.handlers.transferCreated(
        amount: formatCurrency(amount),
        from: fromAccount.name,
        to: toAccount.name,
      ),
    );
  }
}
