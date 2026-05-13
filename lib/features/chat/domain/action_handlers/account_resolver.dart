import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';

/// Outcome of resolving a user-supplied account name (e.g. from an AI
/// action block) against the account list. Either an unambiguous match
/// (`account` set), or an error message ready to show to the user.
class AccountResolution {
  const AccountResolution._({this.account, this.error});

  const AccountResolution.matched(AccountEntity matched)
    : this._(account: matched);
  const AccountResolution.failed(String message) : this._(error: message);

  final AccountEntity? account;
  final String? error;

  bool get isResolved => account != null;
}

/// Two-tier account resolution: exact case-insensitive, then word-set
/// match (every query word appears in the account name as a substring, or
/// vice versa). Word-set covers the common case where the user types
/// "cartão mila" and the registered account is "Cartão Nubank Mila" —
/// contiguous-substring would miss it because "nubank" sits between the
/// matching words. Returns an error on zero or multiple matches —
/// never silently picks an arbitrary account, which would write the
/// transaction to the wrong card and still report success (chat spec §10).
///
/// [locale] carries the language of the current chat conversation so the
/// rejection message matches the AI's reply locale rather than the app UI.
AccountResolution resolveAccount(
  List<AccountEntity> accounts,
  String query, {
  required AppLocale locale,
}) {
  final strings = locale.translations;
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return AccountResolution.failed(
      strings.chat.handlers.resolveAccountMissing,
    );
  }

  final exact = accounts
      .where((a) => a.name.toLowerCase() == normalized)
      .toList();
  if (exact.isNotEmpty) return AccountResolution.matched(exact.first);

  final fuzzy = accounts
      .where((a) => _wordsMatch(normalized, a.name.toLowerCase()))
      .toList();

  if (fuzzy.length == 1) return AccountResolution.matched(fuzzy.first);
  if (fuzzy.isEmpty) {
    return AccountResolution.failed(
      strings.chat.handlers.resolveAccountNotFound(query: query),
    );
  }
  final names = fuzzy.map((a) => '"${a.name}"').join(', ');
  return AccountResolution.failed(
    strings.chat.handlers.resolveAccountMultiple(query: query, names: names),
  );
}

bool _wordsMatch(String query, String accountName) {
  final qWords = _tokens(query);
  final aWords = _tokens(accountName);
  if (qWords.isEmpty || aWords.isEmpty) return false;
  final qInA = qWords.every((w) => aWords.any((a) => a.contains(w)));
  final aInQ = aWords.every((a) => qWords.any((w) => w.contains(a)));
  return qInA || aInQ;
}

List<String> _tokens(String s) =>
    s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
