import { PER_USER_COLLECTIONS } from '../src/admin/deleteUser';

describe('PER_USER_COLLECTIONS', () => {
  // Every user-scoped top-level collection a full user delete must sweep.
  // Missing entries orphan that collection's docs after a delete.
  const EXPECTED_COLLECTIONS = [
    'accounts',
    'transactions',
    'categories',
    'bills',
    'budgets',
    'asset_classes',
    'asset_holdings',
    'chat_messages',
  ] as const;

  it.each(EXPECTED_COLLECTIONS)('includes the %s collection', (collection) => {
    expect(PER_USER_COLLECTIONS).toContain(collection);
  });

  // Regression: asset_classes/asset_holdings were the bug fix — a user
  // delete must not orphan investment data.
  it('includes the investment collections (regression)', () => {
    expect(PER_USER_COLLECTIONS).toContain('asset_classes');
    expect(PER_USER_COLLECTIONS).toContain('asset_holdings');
  });

  it('covers exactly the expected collections with no extras', () => {
    expect([...PER_USER_COLLECTIONS].sort()).toEqual(
      [...EXPECTED_COLLECTIONS].sort(),
    );
  });

  it('has no duplicate entries', () => {
    const unique = new Set(PER_USER_COLLECTIONS);
    expect(unique.size).toBe(PER_USER_COLLECTIONS.length);
  });
});
