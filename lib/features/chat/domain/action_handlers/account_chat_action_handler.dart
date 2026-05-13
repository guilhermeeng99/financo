import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class AccountChatActionHandler implements ChatActionHandler {
  AccountChatActionHandler({
    required CreateAccountUseCase createAccount,
    required GetAccountsUseCase getAccounts,
    required DeleteAccountUseCase deleteAccount,
  }) : _createAccount = createAccount,
       _getAccounts = getAccounts,
       _deleteAccount = deleteAccount;

  final CreateAccountUseCase _createAccount;
  final GetAccountsUseCase _getAccounts;
  final DeleteAccountUseCase _deleteAccount;

  @override
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async => null;

  @override
  Future<String> handle({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final action = meta['action'] as String?;
    if (action == 'create') {
      return _create(userId: userId, meta: meta, locale: locale);
    }
    if (action == 'delete') {
      return _delete(userId: userId, meta: meta, locale: locale);
    }
    return locale.translations.chat.handlers.unknownAccountAction;
  }

  Future<String> _create({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final bankStr = meta['bank'] as String? ?? '';
    final bank = BankBrand.resolveAlias(bankStr) ?? BankType.others;
    final type = (meta['type'] as String?) == 'creditCard'
        ? AccountType.creditCard
        : AccountType.checking;

    String? linkedAccountId;
    if (type == AccountType.creditCard && meta['linkedAccountName'] != null) {
      final linkedName = meta['linkedAccountName'] as String;
      final accResult = await _getAccounts(userId: userId);
      accResult.fold(
        (_) {},
        (accounts) {
          final linked = accounts
              .where((a) => a.name.toLowerCase() == linkedName.toLowerCase())
              .toList();
          if (linked.isNotEmpty) linkedAccountId = linked.first.id;
        },
      );
    }

    final account = AccountEntity(
      id: '',
      userId: userId,
      name: meta['name'] as String? ?? 'Account',
      type: type,
      bank: bank,
      initialBalance: (meta['balance'] as num?)?.toDouble() ?? 0,
      creditLimit: (meta['creditLimit'] as num?)?.toDouble(),
      closingDay: meta['closingDay'] as int?,
      dueDay: meta['dueDay'] as int?,
      linkedAccountId: linkedAccountId,
      createdAt: DateTime.now(),
    );

    final result = await _createAccount(account);
    return result.fold(
      (f) => strings.chat.handlers.accountCreateFailed(error: f.message),
      (a) => strings.chat.handlers.accountCreated(name: a.name),
    );
  }

  Future<String> _delete({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final name = meta['name'] as String? ?? '';
    final listResult = await _getAccounts(userId: userId);
    return listResult.fold(
      (f) => strings.chat.handlers.accountLoadFailed(error: f.message),
      (accounts) async {
        final match = accounts
            .where((a) => a.name.toLowerCase() == name.toLowerCase())
            .toList();
        if (match.isEmpty) {
          return strings.chat.handlers.accountNotFound(name: name);
        }
        final delResult = await _deleteAccount(match.first.id);
        return delResult.fold(
          (f) => strings.chat.handlers.accountDeleteFailed(error: f.message),
          (_) => strings.chat.handlers.accountDeleted(name: name),
        );
      },
    );
  }
}
