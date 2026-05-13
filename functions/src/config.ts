export const GEMINI_MODEL = 'gemini-2.5-flash';
export const GEMINI_LOCATION = 'us-central1';

export const HISTORY_LIMIT = 50;

// Hardcoded master email — must match `kMasterEmail` in
// `lib/core/constants/access_control.dart` and the literal in
// `firestore.rules`. A unit test in the Flutter side asserts they match.
export const MASTER_EMAIL = 'guilhermeeng99@gmail.com';

export const ALLOWED_EMAILS_COLLECTION = 'allowed_emails';

export const isMasterEmail = (email?: string | null): boolean =>
  (email ?? '').toLowerCase() === MASTER_EMAIL;

export const normalizeEmail = (email: string): string =>
  email.trim().toLowerCase();
