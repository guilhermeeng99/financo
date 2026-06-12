# Master Panel Feature Spec

> **Status**: Implemented (shipped)
> **Last updated**: 2026-06-12
> **Coverage**: Entity, Business Rules, Repository, State Machines, UI, Edge Cases

The **Master Panel** is a privileged administration screen reachable only
when the signed-in user's email matches the master email constant
(`isMasterEmail(auth.user.email)` — see rule 5; there is no `isMaster`
flag on `users/{id}`). It lets the admin:

1. **List every registered user** (and see who is master)
2. **Add / remove emails from the access allowlist** (gates onboarding)
3. **Permanently delete a user and all of their data**

This feature is intentionally separated from the regular `profile` and
`access_control` features so the surface area for unauthorized access is
small and reviewable: a single screen, a single cubit, two repositories.

---

## 1. Entity Contract

The master panel reuses two entities — there is no master-specific shape.

### `UserEntity` (from `features/auth`)

| Field       | Type       | Notes                                                                  |
| ----------- | ---------- | ---------------------------------------------------------------------- |
| `id`        | `String`   | Firebase Auth UID                                                      |
| `name`      | `String`   |                                                                        |
| `email`     | `String`   | Compared against `kMasterEmail` to drive the admin gate (see rule 1).  |
| `createdAt` | `DateTime` | First sign-in                                                          |

The master identity is **derived from `email`**, not persisted as a flag on
`users/{id}`. The single source of truth is the constant
`kMasterEmail` in `lib/core/constants/access_control.dart`, mirrored by
`MASTER_EMAIL` in `functions/src/config.ts` and the literal inside
`firestore.rules`. See [access_control.md](./access_control.md).

### `AllowedEmail` (from `features/access_control`)

| Field       | Type       | Notes                                    |
| ----------- | ---------- | ---------------------------------------- |
| `email`     | `String`   | Lower-cased; the Firestore document id   |
| `addedAt`   | `DateTime` | `serverTimestamp` on add                 |
| `note`      | `String?`  | Free-form admin reminder                 |

---

## 2. Business Rules

1. **Master gate.** The route is reachable only through the profile
   section link, which is hidden unless `isMasterEmail(auth.user.email)`
   is `true`. Neither the route guard in `app_router.dart` nor the page
   enforces the gate — a non-master who lands here still triggers
   `load()`, and the backend permission denials surface as
   `MasterPanelError`. That is acceptable because the **authoritative
   gate** is the Firestore security rule (`firestore.rules`) and the
   `deleteUserAsAdmin` Cloud Function — both must verify that
   `request.auth.token.email` (lower-cased) equals the master email
   constant.
2. **Allowlist is the onboarding gate.** A new sign-in is allowed through
   `Authenticated` only when the user's email matches an entry in
   `allowed_emails/` (see `access_control.md`). Removing an entry also
   ends a live session: the target's next `authStateChanges` tick fails
   the gate and signs them out (access_control rule 3).
3. **Deleting a user is irreversible.** Triggers the
   `deleteUserAsAdmin` Cloud Function which:
   - Removes every document owned by that `userId` across the eight
     user-scoped collections (mirrors `clearAccountData`)
   - Deletes the `users/{id}` document itself
   - Deletes the Firebase Auth account
   The admin must type the target's email as confirmation
   (`delete_user_dialog.dart`).
4. **Self-protection.** The UI hides the delete affordance for the
   admin's own row. Attempting to delete oneself via the Cloud Function
   directly is rejected by the function.
5. **Master identity is code-constant.** There is no `isMaster` flag on
   `users/{id}` — the gate is derived from the email at runtime by
   `isMasterEmail`. Promoting another user therefore requires editing the
   `kMasterEmail` / `MASTER_EMAIL` / `firestore.rules` literals in
   lockstep and shipping a release; there is no Firestore-console toggle.

---

## 3. Repository Contract

The master panel orchestrates two existing repositories — there is no
`MasterPanelRepository` aggregating them.

```dart
abstract class MasterUsersRepository {
  Future<Either<Failure, List<UserEntity>>> listAllUsers();
  Future<Either<Failure, void>> deleteUserAsAdmin(String targetUid);
}

abstract class AccessControlRepository {
  Future<Either<Failure, List<AllowedEmail>>> listAllowedEmails();
  Future<Either<Failure, void>> addAllowedEmail({
    required String email,
    String? note,
  });
  Future<Either<Failure, void>> removeAllowedEmail(String email);
  Future<Either<Failure, bool>> isEmailAllowed(String email);
}
```

`MasterUsersRemoteDataSource` is the only entry point that calls the
`deleteUserAsAdmin` Cloud Function. Wiring a second caller would defeat
the audit trail — the function logs each invocation with the caller UID.

---

## 4. State Machine — `MasterPanelCubit`

The cubit exposes a sealed state hierarchy
(`MasterPanelInitial` / `MasterPanelLoading` / `MasterPanelLoaded` /
`MasterPanelError`). `MasterPanelLoaded` carries both slices plus a `busy`
flag for in-place mutations (add/remove email, delete user) that should not
collapse the screen back to a spinner:

```dart
sealed class MasterPanelState {}
class MasterPanelLoaded extends MasterPanelState {
  final List<UserEntity> users;
  final List<AllowedEmailEntity> allowedEmails;
  final bool busy;
}
```

Transitions:

- `load()` → `MasterPanelLoading` → `_loadBoth()` fetches users then
  allowed emails **sequentially** (first failure short-circuits) →
  `MasterPanelLoaded`, or `MasterPanelError` on failure
- `addEmail(email, note)` / `removeEmail(email)` / `deleteUser(uid)` →
  re-emit current `MasterPanelLoaded` with `busy: true` → call use case →
  - **success**: full `_refresh()` — re-runs `_loadBoth` and emits a
    fresh `MasterPanelLoaded` (`busy` back to `false`), or
    `MasterPanelError` if the refetch itself fails
  - **failure**: re-emit the previous `MasterPanelLoaded` with
    `busy: false` (lists untouched)

There is no optimistic append/remove/rollback: successful mutations always
refetch from the backend, so the lists never drift from Firestore. Each
mutation also returns its `Either<Failure, void>` so the page can show a
success or error snackbar directly.

---

## 5. UI Contract

- **`MasterPanelPage`** — `DefaultTabController` with two tabs:
  - **Users** — list each `UserEntity`, render a `MASTER` chip for masters;
    a trash icon exposes the delete action (hidden for master and self
    rows).
  - **Allowlist** — list of `AllowedEmail` entries with note + remove
    action; FAB (allowlist tab only, disabled while `busy`) opens
    `AddAllowedEmailDialog`.
- **`AddAllowedEmailDialog`** — email validator + optional note. Returns
  the typed values to the page, which submits via
  `MasterPanelCubit.addEmail`.
- **`DeleteUserDialog`** — destructive double-confirm. Disables the
  delete button until the typed email exactly matches the target.

All copy lives under `t.masterPanel.*` in slang.

---

## 6. Edge Cases

1. **Non-master opens the route directly.** The page does not gate on
   `isMasterEmail` — `load()` runs as usual, the Firestore rules deny the
   `users/` and `allowed_emails/` queries, and the failure surfaces as
   `MasterPanelError` (error view with retry). No data leaks because the
   backend rules are the authoritative gate.
2. **Removing the only master.** Master identity is a code constant, not a
   per-user flag, so it cannot be "removed" from the UI — only deletion is
   exposed, and `deleteUserAsAdmin` rejects self-delete. Changing who is
   master requires editing the `kMasterEmail` / `MASTER_EMAIL` /
   `firestore.rules` literals in lockstep and shipping a release.
3. **Add an email that already exists.** `AddAllowedEmailUseCase`
   normalizes to lower-case and the Firestore document id is the email —
   so a duplicate `add` becomes a no-op overwrite of `note`/`addedAt`.
4. **Delete an admin's own user.** Hidden from UI and rejected by the
   Cloud Function.
5. **Delete with offline network.** The function call fails; the user
   list is unchanged. The admin can retry.
6. **Removing an email while the target is signed in.** Their session ends
   on the next `authStateChanges` tick: the gate re-checks the allowlist,
   fails, and routes them to `AccessRestrictedPage` (access_control
   rule 3). Requests admitted by the rules before the removal still
   complete.
