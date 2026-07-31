/// Every top-level Firestore collection whose documents carry a `userId` and
/// therefore belong to exactly one account.
///
/// This is the single Dart-side source of truth for "what does the user own".
/// Deleting an account means sweeping all of these; missing one leaves orphan
/// documents that no later code path will ever reach again.
///
/// **Cross-language duplicate — read before editing.** The Cloud Function that
/// performs the master-panel user delete keeps its own copy in
/// `functions/src/admin/deleteUser.ts` (`PER_USER_COLLECTIONS`), because a
/// constant cannot cross the Dart/TypeScript boundary. Adding a user-scoped
/// collection means editing **both**, plus `firestore.rules` and the CLAUDE.md
/// collection map. Both sides have a test pinning the exact expected set, so a
/// divergence fails an assertion instead of silently orphaning data — which is
/// how the F8 investing collections went unswept until the 2026-07-31 audit.
///
/// Retired collections stay listed on purpose: `bills` (superseded 2026-06-10)
/// and `asset_holdings` (superseded by F7) still hold historical rows, and
/// legacy data is exactly what nothing else would clean up.
///
/// Example:
/// ```dart
/// for (final collection in kUserScopedCollections) {
///   await _deleteCollectionDocs(collection, userId);
/// }
/// ```
const kUserScopedCollections = <String>[
  'accounts',
  'transactions',
  'categories',
  'bills',
  'budgets',
  'asset_classes',
  'asset_holdings',
  'institutions',
  'investment_assets',
  'investment_transactions',
  'investment_snapshots',
  'chat_messages',
];
