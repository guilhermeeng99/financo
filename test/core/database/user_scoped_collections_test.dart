import 'dart:io';

import 'package:financo/core/database/user_scoped_collections.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every top-level collection in `firestore.rules` gated by `ownsCreate()` /
/// `ownsResource()` — i.e. owned by exactly one user, and therefore something
/// an account wipe must clear.
///
/// The expectation is derived from the rules file rather than restated here on
/// purpose. The Cloud Function side had a guard test that hard-coded its own
/// copy of the list, so when F8 added the four investing collections the list
/// and its "no extras" assertion went stale together and stayed green while
/// both delete paths orphaned data. A collection cannot ship without security
/// rules, so the rules file is the one anchor that moves independently.
List<String> _userScopedCollectionsFromRules() {
  final rules = File('firestore.rules').readAsStringSync();
  // Top-level `match /<name>/{<var>} { ... }` blocks, bounded by their
  // 4-space indent so nested matches (users/{userId}/fcmTokens) are excluded —
  // subcollections are swept by their own step.
  final blockPattern = RegExp(
    r'^ {4}match /([a-z_]+)/\{[^}]+\} \{([\s\S]*?)^ {4}\}',
    multiLine: true,
  );
  final owned = <String>[];
  for (final match in blockPattern.allMatches(rules)) {
    final name = match.group(1)!;
    final body = match.group(2)!;
    if (body.contains('ownsCreate()') || body.contains('ownsResource()')) {
      owned.add(name);
    }
  }
  return owned..sort();
}

void main() {
  group('kUserScopedCollections', () {
    test('covers every user-scoped collection in firestore.rules', () {
      final fromRules = _userScopedCollectionsFromRules();

      // Guard the guard: a regex that stops matching would make the
      // assertion below pass trivially against an empty list.
      expect(fromRules.length, greaterThanOrEqualTo(10));
      expect(fromRules, contains('accounts'));

      expect([...kUserScopedCollections]..sort(), fromRules);
    });

    // Regression, 2026-07-31 audit: these four shipped with F8 and were never
    // added to the wipe, so "clear account data" left the user's whole
    // investing history in Firestore.
    test('includes the F8 investing collections (regression)', () {
      expect(
        kUserScopedCollections,
        containsAll([
          'institutions',
          'investment_assets',
          'investment_transactions',
          'investment_snapshots',
        ]),
      );
    });

    // Retired collections stay listed: a wipe must clear historical rows, and
    // legacy data is exactly what nothing else would ever clean up.
    test('still wipes the retired collections', () {
      expect(
        kUserScopedCollections,
        containsAll(['bills', 'asset_holdings']),
      );
    });

    test('has no duplicate entries', () {
      expect(
        kUserScopedCollections.toSet().length,
        kUserScopedCollections.length,
      );
    });
  });
}
