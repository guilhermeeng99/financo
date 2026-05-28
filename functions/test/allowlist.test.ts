import * as admin from 'firebase-admin';
import { isEmailAllowed } from '../src/access/allowlist';
import {
  ALLOWED_EMAILS_COLLECTION,
  MASTER_EMAIL,
  isMasterEmail,
  normalizeEmail,
} from '../src/config';

// Minimal firebase-admin stub: only the
// firestore().collection().doc().get() chain the allowlist touches.
jest.mock('firebase-admin', () => {
  const get = jest.fn();
  const doc = jest.fn(() => ({ get }));
  const collection = jest.fn(() => ({ doc }));
  const firestore = jest.fn(() => ({ collection }));
  return { firestore, __mocks: { firestore, collection, doc, get } };
});

// Typed handle on the stub created above so tests can drive .get() results
// and assert the arguments forwarded down the chain.
const mocks = (admin as unknown as {
  __mocks: {
    firestore: jest.Mock;
    collection: jest.Mock;
    doc: jest.Mock;
    get: jest.Mock;
  };
}).__mocks;

describe('config helpers', () => {
  it('normalizeEmail trims and lower-cases', () => {
    expect(normalizeEmail('  Foo@BAR.com  ')).toBe('foo@bar.com');
  });

  it('isMasterEmail matches the master regardless of case', () => {
    expect(isMasterEmail(MASTER_EMAIL.toUpperCase())).toBe(true);
    expect(isMasterEmail('someone@else.com')).toBe(false);
  });

  it('isMasterEmail treats null/undefined as non-master', () => {
    expect(isMasterEmail(null)).toBe(false);
    expect(isMasterEmail(undefined)).toBe(false);
  });
});

describe('isEmailAllowed', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns false for null without touching firestore', async () => {
    await expect(isEmailAllowed(null)).resolves.toBe(false);
    expect(mocks.firestore).not.toHaveBeenCalled();
  });

  it('returns false for undefined without touching firestore', async () => {
    await expect(isEmailAllowed(undefined)).resolves.toBe(false);
    expect(mocks.firestore).not.toHaveBeenCalled();
  });

  it('returns false for empty string without touching firestore', async () => {
    await expect(isEmailAllowed('')).resolves.toBe(false);
    expect(mocks.firestore).not.toHaveBeenCalled();
  });

  it('returns true for the master email without touching firestore', async () => {
    await expect(isEmailAllowed(MASTER_EMAIL)).resolves.toBe(true);
    expect(mocks.firestore).not.toHaveBeenCalled();
  });

  it('returns true for the master email in uppercase (normalized)', async () => {
    await expect(isEmailAllowed(MASTER_EMAIL.toUpperCase())).resolves.toBe(true);
    expect(mocks.firestore).not.toHaveBeenCalled();
  });

  it('returns true for the master email with surrounding whitespace', async () => {
    await expect(isEmailAllowed(`  ${MASTER_EMAIL}  `)).resolves.toBe(true);
    expect(mocks.firestore).not.toHaveBeenCalled();
  });

  it('returns true when the allowlist doc exists', async () => {
    mocks.get.mockResolvedValueOnce({ exists: true });
    await expect(isEmailAllowed('allowed@example.com')).resolves.toBe(true);
    expect(mocks.collection).toHaveBeenCalledWith(ALLOWED_EMAILS_COLLECTION);
  });

  it('returns false when the allowlist doc is absent', async () => {
    mocks.get.mockResolvedValueOnce({ exists: false });
    await expect(isEmailAllowed('stranger@example.com')).resolves.toBe(false);
    expect(mocks.collection).toHaveBeenCalledWith(ALLOWED_EMAILS_COLLECTION);
  });

  it('passes the lower-cased, trimmed email to .doc()', async () => {
    mocks.get.mockResolvedValueOnce({ exists: true });
    await isEmailAllowed('  Allowed@Example.COM  ');
    expect(mocks.doc).toHaveBeenCalledWith('allowed@example.com');
  });
});
