import { HttpsError } from 'firebase-functions/v2/https';
import {
  ALLOWED_AUDIO_MIME_TYPES,
  ALLOWED_IMAGE_MIME_TYPES,
  assertChatContentWithinLimit,
  MAX_AUDIO_BASE64_CHARS,
  MAX_CHAT_CONTENT_CHARS,
  MAX_IMAGE_BASE64_CHARS,
  validateInlineData,
} from '../src/limits';

const image = (over: Partial<{ data: string; mimeType: string }> = {}) => ({
  data: 'AAAA',
  mimeType: 'image/jpeg',
  ...over,
});

const validateImage = (raw: unknown) =>
  validateInlineData(
    raw,
    'image',
    ALLOWED_IMAGE_MIME_TYPES,
    MAX_IMAGE_BASE64_CHARS,
  );

describe('validateInlineData', () => {
  it('returns undefined for an absent attachment', () => {
    expect(validateImage(undefined)).toBeUndefined();
    expect(validateImage(null)).toBeUndefined();
  });

  it('accepts a well-formed payload', () => {
    expect(validateImage(image())).toEqual({
      data: 'AAAA',
      mimeType: 'image/jpeg',
    });
  });

  it('normalises the mime type and strips parameters', () => {
    const result = validateInlineData(
      { data: 'AAAA', mimeType: 'Audio/WebM;codecs=opus' },
      'audio',
      ALLOWED_AUDIO_MIME_TYPES,
      MAX_AUDIO_BASE64_CHARS,
    );
    expect(result?.mimeType).toBe('audio/webm');
  });

  it.each([
    ['a missing data field', { mimeType: 'image/png' }],
    ['a missing mimeType field', { data: 'AAAA' }],
    ['a non-string data field', { data: 42, mimeType: 'image/png' }],
  ])('rejects %s', (_label, raw) => {
    expect(() => validateImage(raw)).toThrow(HttpsError);
  });

  it('rejects empty data rather than silently dropping it', () => {
    expect(() => validateImage(image({ data: '' }))).toThrow(HttpsError);
  });

  // The cap is what stops one allowlisted account from driving unbounded
  // paid Vertex usage with a single oversized request.
  it('rejects a payload over the size cap', () => {
    const oversized = image({ data: 'A'.repeat(MAX_IMAGE_BASE64_CHARS + 1) });
    expect(() => validateImage(oversized)).toThrow(HttpsError);
  });

  it('accepts a payload exactly at the size cap', () => {
    const atLimit = image({ data: 'A'.repeat(MAX_IMAGE_BASE64_CHARS) });
    expect(validateImage(atLimit)?.data.length).toBe(MAX_IMAGE_BASE64_CHARS);
  });

  it('rejects a mime type outside the allowlist', () => {
    expect(() => validateImage(image({ mimeType: 'application/pdf' }))).toThrow(
      HttpsError,
    );
    // An audio type must not pass the image allowlist.
    expect(() => validateImage(image({ mimeType: 'audio/webm' }))).toThrow(
      HttpsError,
    );
  });

  it('accepts every type the Flutter client actually sends', () => {
    // chat_input.dart
    for (const mimeType of ['image/png', 'image/webp', 'image/heic', 'image/jpeg']) {
      expect(validateImage(image({ mimeType }))?.mimeType).toBe(mimeType);
    }
    // chat_audio_recorder_impl.dart: audio/webm on web, audio/mp4 elsewhere
    for (const mimeType of ['audio/webm', 'audio/mp4']) {
      const result = validateInlineData(
        { data: 'AAAA', mimeType },
        'audio',
        ALLOWED_AUDIO_MIME_TYPES,
        MAX_AUDIO_BASE64_CHARS,
      );
      expect(result?.mimeType).toBe(mimeType);
    }
  });
});

describe('assertChatContentWithinLimit', () => {
  it('passes content within the cap through unchanged', () => {
    expect(assertChatContentWithinLimit('oi')).toBe('oi');
  });

  it('accepts content exactly at the cap', () => {
    const atLimit = 'a'.repeat(MAX_CHAT_CONTENT_CHARS);
    expect(assertChatContentWithinLimit(atLimit)).toHaveLength(
      MAX_CHAT_CONTENT_CHARS,
    );
  });

  it('rejects content over the cap', () => {
    const tooLong = 'a'.repeat(MAX_CHAT_CONTENT_CHARS + 1);
    expect(() => assertChatContentWithinLimit(tooLong)).toThrow(HttpsError);
  });
});
