import { defineSecret } from 'firebase-functions/params';

export const WHATSAPP_ACCESS_TOKEN = defineSecret('WHATSAPP_ACCESS_TOKEN');
export const WHATSAPP_PHONE_ID = defineSecret('WHATSAPP_PHONE_ID');
export const WHATSAPP_VERIFY_TOKEN = defineSecret('WHATSAPP_VERIFY_TOKEN');
export const META_APP_SECRET = defineSecret('META_APP_SECRET');

export const GEMINI_MODEL = 'gemini-2.5-flash';
export const GEMINI_LOCATION = 'us-central1';

export const HISTORY_LIMIT = 50;

// Phone → Firebase UID mapping for the WhatsApp channel. Empty by default
// so the public repo does not expose any personal phone numbers. Populate
// at deploy time (e.g. from a private file or Firebase secret) when the
// WhatsApp pipeline is reactivated. Unknown phones are silently ignored
// by the webhook (returns 200 ACK, does nothing).
export const PHONE_TO_UID: Record<string, string> = {};

// Hardcoded master email — must match `kMasterEmail` in
// `lib/core/constants/access_control.dart` and the literal in
// `firestore.rules`. A unit test in the Flutter side asserts they match.
export const MASTER_EMAIL = 'guilhermeeng99@gmail.com';

export const ALLOWED_EMAILS_COLLECTION = 'allowed_emails';

export const isMasterEmail = (email?: string | null): boolean =>
  (email ?? '').toLowerCase() === MASTER_EMAIL;

export const normalizeEmail = (email: string): string =>
  email.trim().toLowerCase();

export const resolveUserIdByPhone = (phone: string): string | undefined => {
  const normalized = phone.startsWith('+') ? phone : `+${phone}`;
  return PHONE_TO_UID[normalized];
};
