# Access Control Spec

Personal-use app. Only emails in `allowed_emails/` may use the app. The owner (`guilhermeeng99@gmail.com`) is the **master** — bypasses the allowlist and can manage other users via a settings panel. Authentication is **Google-only**: there is no email/password sign-in and no public sign-up.

## Entity: AllowedEmailEntity

| Field   | Type     | Required | Notes                                                |
|---------|----------|----------|------------------------------------------------------|
| email   | String   | yes      | Lowercased; doc id in Firestore                      |
| addedAt | DateTime | yes      | Set by master at creation time                       |
| note    | String?  | no       | Free-text label (e.g. friend's name) — master-only   |

- Extends `Equatable` — props: all fields.
- `email` is **stored and compared lowercased**. No dot/plus normalization (Gmail-specific quirks ignored on purpose — we want the exact address Google returns).

## Entity: AppUserEntity (master view)

Reuses `UserEntity` from auth — `{ id, name, email, photoUrl, createdAt }`. Listed by master via `users/` collection scan.

## Constants

`lib/core/constants/access_control.dart`:

```dart
const kMasterEmail = 'guilhermeeng99@gmail.com';
bool isMasterEmail(String? email) => email?.toLowerCase() == kMasterEmail;
```

`functions/src/config.ts`:

```ts
export const MASTER_EMAIL = 'guilhermeeng99@gmail.com';
export const isMasterEmail = (email?: string | null): boolean =>
  (email ?? '').toLowerCase() === MASTER_EMAIL;
```

`firestore.rules` carries the same literal in the `isMaster()` helper. **Three sources of truth — must be kept in sync.** A test asserts they match.

## Business rules

### Authentication

1. **Google-only sign-in** — the only auth path. `AuthRepository.signIn(email, password)` and `signUp(...)` are removed; the `/sign-up` and `/sign-in` routes are deleted; the `OnboardingPage` doubles as the auth landing — its final slide hosts the single `GoogleSignInButton` plus the "access by invite only" disclaimer.
2. **Post-sign-in allowlist gate** — after Firebase Auth succeeds and the Firestore profile is fetched/created, the repository checks `isMasterEmail(user.email)` first; if false, it queries `allowed_emails/{user.email.toLowerCase()}` and returns `Left(AccessDeniedFailure)` if the doc does not exist. On `AccessDeniedFailure` the repository **must call `signOut`** before returning, so the Firebase Auth session is not left dangling.
3. **Allowlist gate on session resume** — `getCurrentUser` and `authStateChanges` apply the same gate. If a previously-allowed user is removed from the allowlist while they had a live session, their next stream tick / app restart signs them out.
4. **`AccessDeniedFailure`** — new sealed `Failure` with the requesting email as its single field. Drives the `AccessRestrictedPage` UI.
5. **Master never blocked** — `isMasterEmail(email) == true` short-circuits the allowlist check in repository, rules, and Cloud Functions. Master does not need a doc in `allowed_emails`.

### Allowlist management (master only)

6. **List** — master reads `allowed_emails/` ordered by `addedAt` desc.
7. **Add** — master writes `allowed_emails/{email.toLowerCase()}` with `{ addedAt: serverTimestamp(), note? }`. Re-adding an existing email updates `addedAt` and `note`.
8. **Remove** — master deletes `allowed_emails/{email.toLowerCase()}`. **Removing an email does not delete the user's data** — for that, master uses the cascade delete (rule 11). After removal, the user's next request fails the gate and gets signed out.
9. **Cannot remove master** — UI hides the option; repository asserts `email != kMasterEmail` and returns `AuthFailure` if attempted (defense in depth — master is not in `allowed_emails` so this is mostly a UI guard).

### Master users panel

10. **List users** — master reads `users/` (no filter). Result includes self.
11. **Cascade delete** — master invokes the `deleteUserAsAdmin({ targetUid })` callable Cloud Function. Cannot delete self (UI hides; function rejects with `failed-precondition`). Cascade order:
    1. `accounts` where `userId == targetUid`
    2. `transactions` where `userId == targetUid`
    3. `categories` where `userId == targetUid`
    4. `bills` where `userId == targetUid`
    5. `budgets` where `userId == targetUid`
    6. `asset_classes` where `userId == targetUid`
    7. `asset_holdings` where `userId == targetUid`
    8. `chat_messages` where `userId == targetUid`
    9. `users/{targetUid}/fcmTokens/*`
    10. `users/{targetUid}` itself
    11. `allowed_emails/{targetEmail}` (if present)
    12. Firebase Auth user via `admin.auth().deleteUser(targetUid)`
    Each Firestore step uses batched writes of 500 (Firestore limit). All 9 Firestore steps run before the Auth delete — so a partial failure leaves the Auth user alive and a re-run cleans up. Idempotent: re-running on a partially-deleted user finishes the job without error.
12. **Type-to-confirm** — UI requires master to type the target's email exactly (case-insensitive comparison) before the delete button enables.

## Repository contracts

### `AuthRepository` (modified)

```dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
```

`signIn` and `signUp` are **removed**. `getCurrentUser` and `signInWithGoogle` apply the allowlist gate before returning `Right(user)`.

### `AccessControlRepository` (new)

```dart
abstract class AccessControlRepository {
  Future<Either<Failure, bool>> isEmailAllowed(String email);
  Future<Either<Failure, List<AllowedEmailEntity>>> listAllowedEmails();
  Future<Either<Failure, void>> addAllowedEmail({
    required String email,
    String? note,
  });
  Future<Either<Failure, void>> removeAllowedEmail(String email);
}
```

- `isEmailAllowed`: returns `true` if `isMasterEmail(email)` OR the doc `allowed_emails/{email.toLowerCase()}` exists.
- `listAllowedEmails`: `Left(AuthFailure)` if caller is not master (rules enforce, plus client-side guard).
- `addAllowedEmail`: lowercases email before write. Rejects empty / invalid email format with `AuthFailure`.

### `MasterUsersRepository` (new)

```dart
abstract class MasterUsersRepository {
  Future<Either<Failure, List<UserEntity>>> listAllUsers();
  Future<Either<Failure, void>> deleteUserAsAdmin(String targetUid);
}
```

- `listAllUsers`: queries `users/` ordered by `createdAt` desc.
- `deleteUserAsAdmin`: invokes the Cloud Function. Returns `AuthFailure` on `unauthenticated` / `permission-denied`, `ServerFailure` on anything else.

## Cloud Function: `deleteUserAsAdmin`

```
Input:  { targetUid: string }
Auth:   request.auth.token.email == MASTER_EMAIL  (else permission-denied)
Output: { deletedCounts: { accounts, transactions, categories, bills, budgets, asset_classes, asset_holdings, chat_messages, fcm_tokens } }
```

Errors:
- `unauthenticated` if no `request.auth`.
- `permission-denied` if email is not master.
- `failed-precondition` if `targetUid == request.auth.uid` (master cannot delete self) or `targetUid` resolves to the master email (defense in depth).
- `not-found` is **not** thrown — missing user is treated as a no-op success (idempotency).
- `internal` for unexpected Admin SDK / Firestore errors.

The chat callables (`chatSend`, `transcribeChatAudio`) replace their hardcoded `isUidAllowed` check with an email-based check via `request.auth.token.email`: master always allowed, otherwise `allowed_emails/{email}` doc must exist. The hardcoded `ALLOWED_UIDS` constant is removed.

## State machines

### `AuthBloc` (modified)

States gain `AccessDenied(email)` (extends `Unauthenticated` semantically — router treats it like unauthenticated for navigation).

```
Authenticated(user) ──allowlist removed remotely──→ AccessDenied(email)
                                                  → router pushes AccessRestrictedPage
                                                  → user taps "back" → SignOut → OnboardingPage
```

`AuthGoogleSignInRequested`:

```
AuthLoading → Authenticated(user)            [allowed]
            → AccessDenied(email)            [not allowed; repository signs out before return]
            → AuthError(failure)             [other failure]
```

Events `AuthSignInRequested` and `AuthSignUpRequested` are **removed**.

### `MasterPanelCubit`

States:
- `MasterPanelInitial`
- `MasterPanelLoading`
- `MasterPanelLoaded({ users, allowedEmails })`
- `MasterPanelError(failure)`

Actions emit `MasterPanelLoading` while running, then re-load:
- `addEmail(email, note?)` → on success, refetch list
- `removeEmail(email)` → on success, refetch list
- `deleteUser(uid, email)` → on success, refetch users list

## Routes

- `AppRoutes.signUp` — **removed** (no public sign-up)
- `AppRoutes.signIn` — **removed**; the unauthenticated landing is now `AppRoutes.onboarding` and the Google button lives on the onboarding's final slide.
- `AppRoutes.accessRestricted = '/access-restricted'` — **added**, root navigator, no shell
- `AppRoutes.masterPanel = '/master-panel'` — **added**, sub-page in shell, master-only

Router redirect:
- `AccessDenied` state → push `/access-restricted` regardless of current location, except when already there.
- Non-master attempting `/master-panel` → redirect to `/profile`.

## UI

### Auth landing

There is no dedicated `SignInPage`. The `OnboardingPage` is the auth landing: a 3-step feature carousel whose final slide replaces the previous "Get Started" CTA with a single `GoogleSignInButton` plus the "access by invite only" disclaimer. The `Skip` action animates the pager to the final slide rather than navigating away. No form fields, no dividers, no "no account?" link.

### `AccessRestrictedPage` (new)

- Centered icon + title `"Acesso restrito"` (or English equivalent).
- Body: `"Pede pro Guilherme liberar seu email:"` + the email in mono.
- Single button `"Voltar"` → triggers `AuthSignOutRequested`.
- Reachable only from the redirect — not in nav.

### `MasterPanelPage` (new)

Two-tab layout (TabBar):

**Tab 1 — Users** (default)
- List of `users/` with avatar, name, email.
- `kMasterEmail` row has badge "Master" and no trash icon.
- Tap trash → `DeleteUserDialog` (type-to-confirm email).

**Tab 2 — Allowlist**
- List of `allowed_emails/` with email, addedAt (formatted), note.
- FAB "+" → `AddAllowedEmailDialog` (email field + optional note).
- Trash icon per row → confirm dialog → remove.

### `ProfilePage` (modified)

When `currentUser.email == kMasterEmail`, render an extra section "Master" with one row: "Painel master" → `context.push(AppRoutes.masterPanel)`. Hidden for everyone else.

## Firestore rules

```
function isAllowed() {
  return request.auth != null && (
    isMaster() ||
    exists(/databases/$(database)/documents/allowed_emails/$(request.auth.token.email.lower()))
  );
}

function isMaster() {
  return request.auth != null
    && request.auth.token.email != null
    && request.auth.token.email.lower() == 'guilhermeeng99@gmail.com';
}

function ownsResource() {
  return resource.data.userId == request.auth.uid;
}
```

Per collection (`accounts`, `transactions`, `categories`, `bills`, `budgets`, `asset_classes`, `asset_holdings`, `chat_messages`):
- `create`: `isAllowed() && request.resource.data.userId == request.auth.uid`
- `read, update, delete`: `(isAllowed() && ownsResource()) || isMaster()`

For `users/{userId}`:
- `read, update, create, delete`: `(isAllowed() && request.auth.uid == userId) || isMaster()`
- `users/{userId}/fcmTokens/{tokenId}`: `(isAllowed() && request.auth.uid == userId) || isMaster()`

For `allowed_emails/{email}`:
- `read`: `isAllowed()`  *(any allowed user can read — needed by client gate; cheap)*
- `create, update, delete`: `isMaster()`

For listing `users/` (master panel): the read rule above allows master to list since master matches the `isMaster()` branch on every doc.

## Edge cases

1. **Master removes their own email from allowlist** — no-op (master is not in allowlist). UI does not show a master-email row in the allowlist tab.
2. **Master deletes another user who is currently signed in on another device** — that device's next `authStateChanges` tick fails the gate and the user is signed out. Their stale local Drift cache stays until they sign in again (where it clears). Acceptable.
3. **Email casing mismatch** — Google may return mixed-case emails; we always lowercase for both writes and reads. The `users/{uid}` doc keeps Firebase's casing for display purposes only.
4. **First-time master sign-in with empty allowlist** — master is allowed by master-bypass; allowlist tab shows empty list until they add someone.
5. **Cloud Function partial failure (e.g. Firestore times out mid-cascade)** — Auth user is **not** deleted (Auth delete is last). Re-running succeeds because each step is "delete where exists". Master sees error toast and can retry.
6. **Cloud Function called by non-master** — `permission-denied`. Mapped to `AuthFailure` in repository.
7. **Allowlist doc with uppercase email by mistake** — only matched against the exact lowercase doc id, so the gate would deny. Add operation always lowercases, so this can only happen via direct Firestore console edit. Document this in the spec; no special handling.
8. **Sign-in with provider that hides email** — Apple Sign-In would hide the email in some flows. Out of scope: only Google is supported.
9. **Race: master removes email A while A's request is in-flight** — request was admitted by rules at start; finishes normally. Next request fails. Acceptable (no transactional guarantees needed for personal use).
10. **Master accidentally deletes themselves through a backdoor** — defended at three layers: UI hides the option, function rejects `targetUid == request.auth.uid`, and function rejects when target's email resolves to master.

## Testing

Tests live under `test/features/access_control/` mirroring the source tree. Bug-fix and regression tests added inline.

- `AccessControlRepository`: allowlist hit/miss, master bypass, listAllowedEmails for non-master returns failure, add/remove flows.
- `MasterUsersRepository`: list users; deleteUserAsAdmin success / permission-denied / failed-precondition mapping.
- `AuthRepositoryImpl`: post-sign-in gate (master, allowed, blocked), `signOut` invoked on block, `getCurrentUser` gate.
- `AuthBloc`: `AuthGoogleSignInRequested` emits `AccessDenied(email)` on block; emits `Authenticated(user)` on master.
- `MasterPanelCubit`: load, add, remove, delete-user transitions.
- Constants test: `kMasterEmail`, `MASTER_EMAIL` (functions), and the literal in `firestore.rules` are all equal.
- Cloud Function: master-only auth gate, cascade order, idempotency on already-deleted user, self-delete rejection.

## Verification

1. Master signs in → sees Master section in profile → Painel master → list of users + allowlist tab.
2. Add a friend's email in the allowlist tab → friend signs in with Google → enters the app.
3. Remove that friend → friend's app tick → AccessRestrictedPage → sign out.
4. Master deletes a friend with data → all collections cleaned, Auth user gone, allowlist row removed.
5. Non-master tries `/master-panel` URL directly → redirected to `/profile`.
