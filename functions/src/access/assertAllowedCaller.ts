import { HttpsError } from 'firebase-functions/v2/https';
import type { CallableRequest } from 'firebase-functions/v2/https';
import { isEmailAllowed } from './allowlist';

export interface CallerIdentity {
  uid: string;
  email: string | undefined;
}

/**
 * Resolves the signed-in caller of a callable request.
 *
 * Throws `HttpsError('unauthenticated')` when there is no Firebase Auth
 * context. The Flutter client switches on the error *code*, not the
 * message, so a single message is shared by every callable.
 *
 * Use directly only for callables that layer their own authorization on
 * top (e.g. the master-only `deleteUserAsAdmin`); user-facing callables
 * should call {@link assertAllowedCaller} instead.
 *
 * @param request The incoming callable request.
 * @returns The caller's uid and (possibly undefined) token email.
 * @example
 *   const caller = requireSignedInCaller(request);
 */
export function requireSignedInCaller(request: CallableRequest): CallerIdentity {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign-in required.');
  }
  return { uid, email: request.auth?.token?.email as string | undefined };
}

/**
 * Shared guard for user-facing callables (chatSend, transcribeChatAudio):
 * the caller must be signed in *and* pass the email allowlist (master or
 * an `allowed_emails/{email}` doc).
 *
 * @param request The incoming callable request.
 * @returns The caller identity when allowed.
 * @throws HttpsError 'unauthenticated' (no auth) or 'permission-denied'
 *   (email not allowlisted).
 * @example
 *   const { uid } = await assertAllowedCaller(request);
 */
export async function assertAllowedCaller(
  request: CallableRequest,
): Promise<CallerIdentity> {
  const caller = requireSignedInCaller(request);
  if (!(await isEmailAllowed(caller.email))) {
    throw new HttpsError('permission-denied', 'Not allowed.');
  }
  return caller;
}
