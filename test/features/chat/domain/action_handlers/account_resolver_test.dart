import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/account_resolver.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/account_factory.dart';

void main() {
  late AppLocale locale;
  late Translations strings;

  setUp(() {
    locale = AppLocale.en;
    strings = locale.translations;
  });

  group('resolveAccount — missing query (chat spec §10)', () {
    test('empty query fails with the "missing" message', () {
      final result = resolveAccount(
        [AccountFactory.checking(name: 'Nubank Gui')],
        '',
        locale: locale,
      );

      expect(result.isResolved, isFalse);
      expect(result.account, isNull);
      expect(result.error, strings.chat.handlers.resolveAccountMissing);
    });

    test('blank (whitespace-only) query fails with the "missing" message', () {
      final result = resolveAccount(
        [AccountFactory.checking(name: 'Nubank Gui')],
        '   ',
        locale: locale,
      );

      expect(result.isResolved, isFalse);
      expect(result.error, strings.chat.handlers.resolveAccountMissing);
    });
  });

  group('resolveAccount — exact match', () {
    test('exact case-insensitive name match resolves that account', () {
      final target = AccountFactory.checking(
        id: 'acc-target',
        name: 'Nubank Gui',
      );
      final accounts = [
        AccountFactory.checking(id: 'acc-other', name: 'Inter Savings'),
        target,
      ];

      final result = resolveAccount(accounts, 'nubank gui', locale: locale);

      expect(result.isResolved, isTrue);
      expect(result.account, target);
      expect(result.error, isNull);
    });

    test('exact match wins over a competing fuzzy candidate', () {
      // "Nubank" exactly matches the first account; it also appears as a
      // word inside the second, which would otherwise be a fuzzy candidate.
      // Exact resolution must short-circuit and never report ambiguity.
      final exact = AccountFactory.checking(id: 'acc-exact', name: 'Nubank');
      final fuzzy = AccountFactory.creditCard(
        id: 'acc-fuzzy',
        name: 'Nubank Credit',
      );

      final result = resolveAccount([exact, fuzzy], 'Nubank', locale: locale);

      expect(result.isResolved, isTrue);
      expect(result.account, exact);
    });
  });

  group('resolveAccount — fuzzy word-set match', () {
    test('partial words resolve to the single matching account', () {
      // "cartão mila" against "Cartão Nubank Mila": every query word is a
      // substring of some account word, so the word-set match succeeds even
      // though "nubank" sits between the matching words.
      final target = AccountFactory.creditCard(
        id: 'acc-mila',
        name: 'Cartão Nubank Mila',
      );
      final accounts = [
        AccountFactory.checking(id: 'acc-gui', name: 'Conta Itaú Gui'),
        target,
      ];

      final result = resolveAccount(accounts, 'cartão mila', locale: locale);

      expect(result.isResolved, isTrue);
      expect(result.account, target);
    });
  });

  group('resolveAccount — zero matches (chat spec §10)', () {
    test('no candidate fails with the not-found message carrying the query',
        () {
      const query = 'Nonexistent Bank';
      final result = resolveAccount(
        [AccountFactory.checking(name: 'Nubank Gui')],
        query,
        locale: locale,
      );

      expect(result.isResolved, isFalse);
      expect(result.account, isNull);
      expect(
        result.error,
        strings.chat.handlers.resolveAccountNotFound(query: query),
      );
      // The raw query (original casing) must survive into the message so the
      // user can see exactly what failed to match.
      expect(result.error, contains(query));
    });

    test('empty account list fails with not-found rather than crashing', () {
      const query = 'Anything';
      final result = resolveAccount(
        const <AccountEntity>[],
        query,
        locale: locale,
      );

      expect(result.isResolved, isFalse);
      expect(
        result.error,
        strings.chat.handlers.resolveAccountNotFound(query: query),
      );
    });
  });

  group('resolveAccount — ambiguous match (chat spec §10)', () {
    test('multiple fuzzy candidates fail with the candidate names, never '
        'silently picking one', () {
      // "Nubank" is a substring of a word in both account names, so both are
      // word-set candidates. Resolution must refuse and list both.
      final first = AccountFactory.checking(
        id: 'acc-1',
        name: 'Nubank Gui',
      );
      final second = AccountFactory.creditCard(
        id: 'acc-2',
        name: 'Nubank Mila',
      );

      const query = 'Nubank';
      final result = resolveAccount([first, second], query, locale: locale);

      expect(result.isResolved, isFalse);
      expect(result.account, isNull);

      const expectedNames = '"Nubank Gui", "Nubank Mila"';
      expect(
        result.error,
        strings.chat.handlers.resolveAccountMultiple(
          query: query,
          names: expectedNames,
        ),
      );
      // Both candidate names must be carried so the user can disambiguate.
      expect(result.error, contains('Nubank Gui'));
      expect(result.error, contains('Nubank Mila'));
    });
  });
}
