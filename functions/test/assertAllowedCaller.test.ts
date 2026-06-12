import { HttpsError } from 'firebase-functions/v2/https';
import type { CallableRequest } from 'firebase-functions/v2/https';
import { isEmailAllowed } from '../src/access/allowlist';
import {
  assertAllowedCaller,
  requireSignedInCaller,
} from '../src/access/assertAllowedCaller';

// The allowlist is mocked at its module boundary: master-email and
// Firestore-doc behaviour is already covered by allowlist.test.ts, so here
// we only verify the guard's wiring (what it forwards, what it throws).
jest.mock('../src/access/allowlist', () => ({
  isEmailAllowed: jest.fn(),
}));

const mockIsEmailAllowed = isEmailAllowed as jest.MockedFunction<
  typeof isEmailAllowed
>;

// Minimal CallableRequest stand-in — the guards only read `request.auth`.
const requestWith = (auth: unknown): CallableRequest =>
  ({ auth, data: {} } as unknown as CallableRequest);

// The Flutter client switches on the HttpsError *code*, so the code (not
// the message) is the contract these tests pin down.
const codeOf = (fn: () => unknown): string => {
  try {
    fn();
  } catch (error) {
    expect(error).toBeInstanceOf(HttpsError);
    return (error as HttpsError).code;
  }
  throw new Error('expected the guard to throw');
};

describe('requireSignedInCaller', () => {
  it('throws unauthenticated when the request has no auth context', () => {
    expect(codeOf(() => requireSignedInCaller(requestWith(undefined)))).toBe(
      'unauthenticated',
    );
  });

  it('throws unauthenticated when auth has no uid', () => {
    expect(
      codeOf(() =>
        requireSignedInCaller(
          requestWith({ token: { email: 'someone@example.com' } }),
        ),
      ),
    ).toBe('unauthenticated');
  });

  it('returns uid and token email for a signed-in caller', () => {
    const caller = requireSignedInCaller(
      requestWith({ uid: 'user-1', token: { email: 'someone@example.com' } }),
    );

    expect(caller).toEqual({ uid: 'user-1', email: 'someone@example.com' });
  });

  it('returns undefined email when the token carries none', () => {
    const caller = requireSignedInCaller(
      requestWith({ uid: 'user-1', token: {} }),
    );

    expect(caller).toEqual({ uid: 'user-1', email: undefined });
  });
});

describe('assertAllowedCaller', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('throws unauthenticated before consulting the allowlist', async () => {
    await expect(
      assertAllowedCaller(requestWith(undefined)),
    ).rejects.toMatchObject({ code: 'unauthenticated' });
    expect(mockIsEmailAllowed).not.toHaveBeenCalled();
  });

  it('throws permission-denied when the email is not allowlisted', async () => {
    mockIsEmailAllowed.mockResolvedValueOnce(false);

    await expect(
      assertAllowedCaller(
        requestWith({ uid: 'user-1', token: { email: 'stranger@example.com' } }),
      ),
    ).rejects.toMatchObject({ code: 'permission-denied' });
    expect(mockIsEmailAllowed).toHaveBeenCalledWith('stranger@example.com');
  });

  it('returns the caller identity when the email is allowed', async () => {
    mockIsEmailAllowed.mockResolvedValueOnce(true);

    await expect(
      assertAllowedCaller(
        requestWith({ uid: 'user-1', token: { email: 'allowed@example.com' } }),
      ),
    ).resolves.toEqual({ uid: 'user-1', email: 'allowed@example.com' });
  });

  it('forwards an undefined email to the allowlist (which rejects it)', async () => {
    mockIsEmailAllowed.mockResolvedValueOnce(false);

    await expect(
      assertAllowedCaller(requestWith({ uid: 'user-1', token: {} })),
    ).rejects.toMatchObject({ code: 'permission-denied' });
    expect(mockIsEmailAllowed).toHaveBeenCalledWith(undefined);
  });
});
