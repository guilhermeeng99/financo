import { readFileSync } from 'fs';
import { join } from 'path';
import { PER_USER_COLLECTIONS } from '../src/admin/deleteUser';

/**
 * Every top-level collection in `firestore.rules` whose ownership is gated by
 * `ownsCreate()` / `ownsResource()` — i.e. every collection whose documents
 * belong to exactly one user, and which a full user delete must therefore
 * sweep.
 *
 * Deriving the expectation from the rules file rather than restating the list
 * here is the whole point: the previous version of this test hard-coded its
 * own copy of the collections, so when F8 added `institutions`,
 * `investment_assets`, `investment_transactions` and `investment_snapshots`,
 * the list and its "no extras" assertion went stale together and the suite
 * stayed green while a user delete silently orphaned all four. A new
 * collection cannot ship without security rules, so the rules file is the one
 * anchor that moves for an independent reason.
 */
function userScopedCollectionsFromRules(): string[] {
  const rules = readFileSync(
    join(__dirname, '..', '..', 'firestore.rules'),
    'utf8',
  );
  // Top-level `match /<name>/{<var>} { … }` blocks. Nested matches (e.g.
  // users/{userId}/fcmTokens) are indented deeper and excluded by the
  // leading-whitespace bound; subcollections are swept by their own step.
  const blocks = rules.matchAll(
    /^ {4}match \/([a-z_]+)\/\{[^}]+\} \{([\s\S]*?)^ {4}\}/gm,
  );
  const owned: string[] = [];
  for (const [, name, body] of blocks) {
    if (body.includes('ownsCreate()') || body.includes('ownsResource()')) {
      owned.push(name);
    }
  }
  return owned.sort();
}

describe('PER_USER_COLLECTIONS', () => {
  it('sweeps every user-scoped collection declared in firestore.rules', () => {
    const fromRules = userScopedCollectionsFromRules();

    // Guard the guard: if the regex ever stops matching, the assertion below
    // would trivially pass against an empty list.
    expect(fromRules.length).toBeGreaterThanOrEqual(10);
    expect(fromRules).toContain('accounts');

    expect([...PER_USER_COLLECTIONS].sort()).toEqual(fromRules);
  });

  // Regression, 2026-07-31 audit: these four shipped with F8 and were never
  // added to the sweep, so deleting a user left their entire investing
  // history behind in Firestore.
  it.each([
    'institutions',
    'investment_assets',
    'investment_transactions',
    'investment_snapshots',
  ])('includes the %s collection (F8 regression)', (collection) => {
    expect(PER_USER_COLLECTIONS).toContain(collection);
  });

  // Retired collections stay listed: a wipe must clear historical rows, and
  // legacy data is exactly what nothing else would ever clean up.
  it.each(['bills', 'asset_holdings'])(
    'still sweeps the retired %s collection',
    (collection) => {
      expect(PER_USER_COLLECTIONS).toContain(collection);
    },
  );

  it('has no duplicate entries', () => {
    const unique = new Set(PER_USER_COLLECTIONS);
    expect(unique.size).toBe(PER_USER_COLLECTIONS.length);
  });
});
