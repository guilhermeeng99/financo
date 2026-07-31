import { getAuth } from 'firebase-admin/auth';
import {
  getFirestore,
  type CollectionReference,
  type DocumentData,
  type Firestore,
  type Query,
} from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/logger';
import {
  ALLOWED_EMAILS_COLLECTION,
  isMasterEmail,
  normalizeEmail,
} from '../config';

interface DeleteUserAsAdminRequest {
  targetUid: string;
}

interface DeletedCounts {
  accounts: number;
  transactions: number;
  categories: number;
  bills: number;
  budgets: number;
  asset_classes: number;
  asset_holdings: number;
  institutions: number;
  investment_assets: number;
  investment_transactions: number;
  investment_snapshots: number;
  chat_messages: number;
  fcm_tokens: number;
}

interface DeleteUserAsAdminResponse {
  deletedCounts: DeletedCounts;
}

/** What `resolveTargetUser` learned about the user being deleted. */
interface TargetUser {
  userDocExists: boolean;
  /** Normalized email, or '' when the user doc is missing it. */
  email: string;
}

const FIRESTORE_BATCH_LIMIT = 500;

// Every top-level collection scoped by `userId` that a full user delete must
// sweep. Exported so a test can assert none are forgotten (a missing entry
// orphans that collection's docs after a delete).
//
// This list is duplicated, by necessity, across a language boundary — the
// Flutter clear-account-data path keeps its own copy in
// `lib/core/database/user_scoped_collections.dart`. Adding a user-scoped
// collection means editing BOTH, plus `firestore.rules` and the CLAUDE.md
// collection map. Each side has a test pinning the exact expected set so a
// drift shows up as a failing assertion rather than silently orphaned docs.
//
// `bills` and `asset_holdings` are retired (2026-06-10 and F7) but stay here:
// a wipe must clear historical rows too, and legacy docs are precisely the
// ones nothing else would ever touch again.
export const PER_USER_COLLECTIONS: ReadonlyArray<keyof DeletedCounts> = [
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

/**
 * Cascading user delete invoked by the master from the Flutter master
 * panel. Steps run in this order so a partial failure leaves Auth alive
 * (re-running succeeds because each Firestore step is "delete where exists"):
 *
 *   1. every collection in PER_USER_COLLECTIONS, where userId == targetUid,
 *      in the order declared there
 *   2. users/{targetUid}/fcmTokens/* (subcollection)
 *   3. users/{targetUid}
 *   4. allowed_emails/{targetEmail} if present
 *   5. Firebase Auth user (getAuth().deleteUser)
 *
 * Step 1 is deliberately not spelled out collection-by-collection here — the
 * previous enumeration silently went stale when the F8 investing collections
 * landed, so the list has exactly one home now.
 */
export async function deleteUserAsAdmin(
  data: DeleteUserAsAdminRequest,
  callerEmail: string | undefined,
  callerUid: string,
): Promise<DeleteUserAsAdminResponse> {
  const targetUid = validateDeleteRequest(data, callerEmail, callerUid);
  const db = getFirestore();

  const target = await resolveTargetUser(db, targetUid);
  assertTargetIsNotMaster(target.email);

  const counts = await cascadeDeleteUserData(db, targetUid, target.userDocExists);
  await removeAllowlistEntry(db, target.email);
  await deleteAuthUser(targetUid);

  return { deletedCounts: counts };
}

/**
 * Guard step: master-only caller, well-formed targetUid, and the master
 * cannot delete their own account (uid-level self-delete check; the
 * email-level one happens after the target's email is resolved).
 */
function validateDeleteRequest(
  data: DeleteUserAsAdminRequest,
  callerEmail: string | undefined,
  callerUid: string,
): string {
  if (!isMasterEmail(callerEmail)) {
    throw new HttpsError('permission-denied', 'Master access required.');
  }

  const targetUid = (data?.targetUid ?? '').toString().trim();
  if (!targetUid) {
    throw new HttpsError('invalid-argument', 'targetUid is required.');
  }
  if (targetUid === callerUid) {
    throw new HttpsError(
      'failed-precondition',
      'Master cannot delete their own account.',
    );
  }
  return targetUid;
}

/**
 * Resolves the target's email — needed for the allowlist cleanup and
 * for the master self-delete defense in depth. Missing user doc is OK
 * (the user may have been partially deleted already).
 */
async function resolveTargetUser(
  db: Firestore,
  targetUid: string,
): Promise<TargetUser> {
  const userDoc = await db.collection('users').doc(targetUid).get();
  const email = userDoc.exists
    ? normalizeEmail((userDoc.get('email') as string | undefined) ?? '')
    : '';
  return { userDocExists: userDoc.exists, email };
}

/**
 * Defense in depth on top of the uid check: even if the master's data
 * were targeted via a different uid, refuse to delete the master account.
 */
function assertTargetIsNotMaster(targetEmail: string): void {
  if (targetEmail && isMasterEmail(targetEmail)) {
    throw new HttpsError(
      'failed-precondition',
      'Cannot delete the master account.',
    );
  }
}

const emptyDeletedCounts = (): DeletedCounts => ({
  accounts: 0,
  transactions: 0,
  categories: 0,
  bills: 0,
  budgets: 0,
  asset_classes: 0,
  asset_holdings: 0,
  institutions: 0,
  investment_assets: 0,
  investment_transactions: 0,
  investment_snapshots: 0,
  chat_messages: 0,
  fcm_tokens: 0,
});

/**
 * Sweeps every per-user top-level collection, the fcmTokens subcollection,
 * and finally the user doc itself.
 */
async function cascadeDeleteUserData(
  db: Firestore,
  targetUid: string,
  userDocExists: boolean,
): Promise<DeletedCounts> {
  const counts = emptyDeletedCounts();

  for (const collection of PER_USER_COLLECTIONS) {
    counts[collection] = await deleteWhere(
      db.collection(collection).where('userId', '==', targetUid),
    );
  }

  counts.fcm_tokens = await deleteWhere(
    db.collection('users').doc(targetUid).collection('fcmTokens'),
  );

  if (userDocExists) {
    await db.collection('users').doc(targetUid).delete();
  }
  return counts;
}

/**
 * Allowlist cleanup (step 11): revoke access so the deleted user cannot
 * simply sign in again and recreate their account.
 */
async function removeAllowlistEntry(
  db: Firestore,
  targetEmail: string,
): Promise<void> {
  if (!targetEmail) return;
  const allowedRef = db
    .collection(ALLOWED_EMAILS_COLLECTION)
    .doc(targetEmail);
  const allowedSnap = await allowedRef.get();
  if (allowedSnap.exists) {
    await allowedRef.delete();
  }
}

/**
 * Auth deletion (step 12) runs last so a partial failure leaves Auth
 * alive and the whole cascade re-runnable. 'auth/user-not-found' is
 * tolerated for the same reason: a retry after a prior partial success
 * must not fail.
 */
async function deleteAuthUser(targetUid: string): Promise<void> {
  try {
    await getAuth().deleteUser(targetUid);
  } catch (error: unknown) {
    const code = (error as { code?: string })?.code;
    if (code !== 'auth/user-not-found') {
      logger.error('deleteUser failed for Auth user', { targetUid, error });
      throw new HttpsError('internal', 'Failed to delete Auth user.');
    }
  }
}

/**
 * Iteratively deletes documents matching the given query in batches of
 * 500. Returns the total number of deleted documents. Safe to re-run on
 * an empty result set (returns 0).
 */
async function deleteWhere(
  query: Query<DocumentData> | CollectionReference<DocumentData>,
): Promise<number> {
  let deleted = 0;
  for (;;) {
    const snapshot = await query.limit(FIRESTORE_BATCH_LIMIT).get();
    if (snapshot.empty) break;
    // Batch from the query's own Firestore instance, not a fresh
    // `getFirestore()` — the two are the same handle in production but
    // diverge under a test that injects a second app.
    const batch = query.firestore.batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += snapshot.size;
    if (snapshot.size < FIRESTORE_BATCH_LIMIT) break;
  }
  return deleted;
}
