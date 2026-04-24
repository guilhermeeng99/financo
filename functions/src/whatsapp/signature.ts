import * as crypto from 'crypto';

export const verifySignature = (
  rawBody: Buffer | string,
  header: string | undefined,
  appSecret: string,
): boolean => {
  if (!header) return false;
  const prefix = 'sha256=';
  if (!header.startsWith(prefix)) return false;
  const received = header.slice(prefix.length);
  const expected = crypto
    .createHmac('sha256', appSecret)
    .update(rawBody)
    .digest('hex');

  try {
    const a = Buffer.from(received, 'hex');
    const b = Buffer.from(expected, 'hex');
    if (a.length !== b.length) return false;
    return crypto.timingSafeEqual(a, b);
  } catch {
    return false;
  }
};
