import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
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
  chat_messages: number;
  fcm_tokens: number;
}

interface DeleteUserAsAdminResponse {
  deletedCounts: DeletedCounts;
}

const FIRESTORE_BATCH_LIMIT = 500;
const PER_USER_COLLECTIONS: ReadonlyArray<keyof DeletedCounts> = [
  'accounts',
  'transactions',
  'categories',
  'bills',
  'budgets',
  'chat_messages',
];

/**
 * Cascading user delete invoked by the master from the Flutter master
 * panel. Steps run in this order so a partial failure leaves Auth alive
 * (re-running succeeds because each Firestore step is "delete where exists"):
 *
 *   1. accounts where userId == targetUid
 *   2. transactions where userId == targetUid
 *   3. categories where userId == targetUid
 *   4. bills where userId == targetUid
 *   5. budgets where userId == targetUid
 *   6. chat_messages where userId == targetUid
 *   7. users/{targetUid}/fcmTokens/* (subcollection)
 *   8. users/{targetUid}
 *   9. allowed_emails/{targetEmail} if present
 *  10. Firebase Auth user (admin.auth().deleteUser)
 */
export async function deleteUserAsAdmin(
  data: DeleteUserAsAdminRequest,
  callerEmail: string | undefined,
  callerUid: string,
): Promise<DeleteUserAsAdminResponse> {
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

  const db = admin.firestore();

  // Resolve the target's email — needed for the allowlist cleanup and
  // for the master self-delete defense in depth. Missing user doc is OK
  // (the user may have been partially deleted already).
  const userDoc = await db.collection('users').doc(targetUid).get();
  const targetEmail = userDoc.exists
    ? normalizeEmail((userDoc.get('email') as string | undefined) ?? '')
    : '';

  if (targetEmail && isMasterEmail(targetEmail)) {
    throw new HttpsError(
      'failed-precondition',
      'Cannot delete the master account.',
    );
  }

  const counts: DeletedCounts = {
    accounts: 0,
    transactions: 0,
    categories: 0,
    bills: 0,
    budgets: 0,
    chat_messages: 0,
    fcm_tokens: 0,
  };

  for (const collection of PER_USER_COLLECTIONS) {
    counts[collection] = await deleteWhere(
      db.collection(collection).where('userId', '==', targetUid),
    );
  }

  counts.fcm_tokens = await deleteWhere(
    db.collection('users').doc(targetUid).collection('fcmTokens'),
  );

  if (userDoc.exists) {
    await db.collection('users').doc(targetUid).delete();
  }

  if (targetEmail) {
    const allowedRef = db
      .collection(ALLOWED_EMAILS_COLLECTION)
      .doc(targetEmail);
    const allowedSnap = await allowedRef.get();
    if (allowedSnap.exists) {
      await allowedRef.delete();
    }
  }

  try {
    await admin.auth().deleteUser(targetUid);
  } catch (error: unknown) {
    const code = (error as { code?: string })?.code;
    if (code !== 'auth/user-not-found') {
      logger.error('deleteUser failed for Auth user', { targetUid, error });
      throw new HttpsError('internal', 'Failed to delete Auth user.');
    }
  }

  return { deletedCounts: counts };
}

/**
 * Iteratively deletes documents matching the given query in batches of
 * 500. Returns the total number of deleted documents. Safe to re-run on
 * an empty result set (returns 0).
 */
async function deleteWhere(
  query:
    | FirebaseFirestore.Query<FirebaseFirestore.DocumentData>
    | FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>,
): Promise<number> {
  let deleted = 0;
  for (;;) {
    const snapshot = await query.limit(FIRESTORE_BATCH_LIMIT).get();
    if (snapshot.empty) break;
    const batch = admin.firestore().batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += snapshot.size;
    if (snapshot.size < FIRESTORE_BATCH_LIMIT) break;
  }
  return deleted;
}
