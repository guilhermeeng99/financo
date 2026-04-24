import * as crypto from 'crypto';
import { verifySignature } from '../src/whatsapp/signature';

const sign = (body: string, secret: string): string =>
  'sha256=' + crypto.createHmac('sha256', secret).update(body).digest('hex');

describe('verifySignature', () => {
  const secret = 'test-app-secret';
  const body = '{"entry":[]}';

  it('accepts valid signature', () => {
    expect(verifySignature(body, sign(body, secret), secret)).toBe(true);
  });

  it('rejects missing header', () => {
    expect(verifySignature(body, undefined, secret)).toBe(false);
  });

  it('rejects header without sha256= prefix', () => {
    expect(verifySignature(body, 'deadbeef', secret)).toBe(false);
  });

  it('rejects tampered body', () => {
    const signature = sign(body, secret);
    expect(verifySignature('{"entry":[42]}', signature, secret)).toBe(false);
  });

  it('rejects wrong secret', () => {
    expect(verifySignature(body, sign(body, 'other'), secret)).toBe(false);
  });

  it('rejects non-hex signature payload', () => {
    expect(verifySignature(body, 'sha256=zzz', secret)).toBe(false);
  });
});
