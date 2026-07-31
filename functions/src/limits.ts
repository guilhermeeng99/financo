import { HttpsError } from 'firebase-functions/v2/https';

/**
 * Request-size and content-type limits for the AI callables.
 *
 * Every one of these guards paid Vertex capacity: `chatSend` and
 * `transcribeChatAudio` forward their payload straight to Gemini, so without a
 * ceiling a single allowlisted account can drive unbounded spend (and blow the
 * 512MiB function memory) with one oversized request. The allowlist gate keeps
 * strangers out; these keep an authenticated caller honest.
 *
 * Caps are deliberately far above what the Flutter client produces — a normal
 * chat turn is a few hundred characters and a picked photo lands well under a
 * megabyte — so they only ever fire on abuse or a client bug.
 */

/** Longest single chat message accepted, in characters. */
export const MAX_CHAT_CONTENT_CHARS = 8_000;

/** Most history turns replayed into the model. Older turns are dropped. */
export const MAX_HISTORY_TURNS = 50;

/** Longest single history turn accepted, in characters. Longer ones truncate. */
export const MAX_HISTORY_TURN_CHARS = 4_000;

/** Largest base64 image payload, in characters (~5 MiB decoded). */
export const MAX_IMAGE_BASE64_CHARS = 7_000_000;

/** Largest base64 audio payload, in characters (~10 MiB decoded). */
export const MAX_AUDIO_BASE64_CHARS = 14_000_000;

/** Image types the chat accepts, matching what `chat_input.dart` produces. */
export const ALLOWED_IMAGE_MIME_TYPES: ReadonlySet<string> = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
]);

/**
 * Audio types the transcriber accepts. `chat_audio_recorder_impl.dart` sends
 * `audio/webm` on web and `audio/mp4` elsewhere; the rest are near neighbours
 * a future recorder swap could plausibly emit.
 */
export const ALLOWED_AUDIO_MIME_TYPES: ReadonlySet<string> = new Set([
  'audio/webm',
  'audio/mp4',
  'audio/m4a',
  'audio/aac',
  'audio/mpeg',
  'audio/ogg',
  'audio/wav',
]);

/** A validated `inlineData` payload ready to hand to Vertex. */
export interface InlineData {
  data: string;
  mimeType: string;
}

/**
 * Validates a base64 inline attachment against a type allowlist and a size
 * ceiling, throwing `invalid-argument` rather than letting an oversized or
 * unexpected payload reach the model.
 *
 * Returns `undefined` when [raw] is absent, so optional attachments stay
 * optional; a *malformed* attachment always throws instead of being silently
 * dropped, which would turn "my photo didn't upload" into a silent no-op.
 *
 * @param raw The caller-supplied `{ data, mimeType }`, if any.
 * @param label Field name used in the error message (e.g. `image`).
 * @param allowedMimeTypes Accepted content types.
 * @param maxChars Ceiling on the base64 string length.
 * @example
 *   const image = validateInlineData(
 *     request.data?.image, 'image',
 *     ALLOWED_IMAGE_MIME_TYPES, MAX_IMAGE_BASE64_CHARS,
 *   );
 */
export function validateInlineData(
  raw: unknown,
  label: string,
  allowedMimeTypes: ReadonlySet<string>,
  maxChars: number,
): InlineData | undefined {
  if (raw === undefined || raw === null) return undefined;

  const candidate = raw as Partial<InlineData>;
  if (
    typeof candidate.data !== 'string' ||
    typeof candidate.mimeType !== 'string'
  ) {
    throw new HttpsError(
      'invalid-argument',
      `${label}.data and ${label}.mimeType are required.`,
    );
  }
  if (candidate.data.length === 0) {
    throw new HttpsError('invalid-argument', `${label}.data cannot be empty.`);
  }
  if (candidate.data.length > maxChars) {
    throw new HttpsError(
      'invalid-argument',
      `${label} exceeds the maximum accepted size.`,
    );
  }
  // Compare on the bare type so a charset/codec parameter
  // (`audio/webm;codecs=opus`) still matches its allowlist entry.
  const baseType = candidate.mimeType.split(';')[0].trim().toLowerCase();
  if (!allowedMimeTypes.has(baseType)) {
    throw new HttpsError(
      'invalid-argument',
      `${label}.mimeType '${baseType}' is not supported.`,
    );
  }
  return { data: candidate.data, mimeType: baseType };
}

/**
 * Rejects a chat message longer than [MAX_CHAT_CONTENT_CHARS].
 *
 * @param content The caller-supplied message text.
 * @returns The same string, once it is known to be within the cap.
 * @example
 *   const content = assertChatContentWithinLimit(raw);
 */
export function assertChatContentWithinLimit(content: string): string {
  if (content.length > MAX_CHAT_CONTENT_CHARS) {
    throw new HttpsError(
      'invalid-argument',
      'Message is too long.',
    );
  }
  return content;
}
