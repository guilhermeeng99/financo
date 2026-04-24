import { defineSecret } from 'firebase-functions/params';

export const WHATSAPP_ACCESS_TOKEN = defineSecret('WHATSAPP_ACCESS_TOKEN');
export const WHATSAPP_PHONE_ID = defineSecret('WHATSAPP_PHONE_ID');
export const WHATSAPP_VERIFY_TOKEN = defineSecret('WHATSAPP_VERIFY_TOKEN');
export const META_APP_SECRET = defineSecret('META_APP_SECRET');

export const GEMINI_MODEL = 'gemini-2.5-flash';
export const GEMINI_LOCATION = 'us-central1';

export const HISTORY_LIMIT = 50;

export const PHONE_TO_UID: Record<string, string> = {
  '+5571983485225': 'gQOgYd1DYmeOcBHmwSteWvewq102',
  // Meta/WhatsApp sometimes strips the leading 9 from Brazilian mobile numbers.
  '+557183485225': 'gQOgYd1DYmeOcBHmwSteWvewq102',
};

// Allowlist of Firebase Auth UIDs permitted to invoke callable functions.
// Personal-use app: only the owner's UID is accepted.
export const ALLOWED_UIDS: readonly string[] = [
  'gQOgYd1DYmeOcBHmwSteWvewq102',
];

export const isUidAllowed = (uid: string | undefined | null): boolean =>
  uid !== undefined && uid !== null && ALLOWED_UIDS.includes(uid);

export const resolveUserIdByPhone = (phone: string): string | undefined => {
  const normalized = phone.startsWith('+') ? phone : `+${phone}`;
  return PHONE_TO_UID[normalized];
};
