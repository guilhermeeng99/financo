import * as admin from 'firebase-admin';
import {
  ALLOWED_EMAILS_COLLECTION,
  isMasterEmail,
  normalizeEmail,
} from '../config';

/**
 * True when the authenticated email may use the app — master always
 * passes; everyone else needs a doc in `allowed_emails/{email}`.
 *
 * Reads Firestore once per call. Functions runtime + Firestore client
 * caching make this cheap enough for the personal-use scale we target;
 * if it ever becomes a hot path, wrap in an in-memory LRU.
 */
export async function isEmailAllowed(
  email: string | undefined | null,
): Promise<boolean> {
  if (!email) return false;
  const normalized = normalizeEmail(email);
  if (isMasterEmail(normalized)) return true;
  const doc = await admin
    .firestore()
    .collection(ALLOWED_EMAILS_COLLECTION)
    .doc(normalized)
    .get();
  return doc.exists;
}
