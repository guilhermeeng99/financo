# Master Panel Feature Spec

> **Status**: Implemented (shipped)
> **Last updated**: 2026-05-13
> **Coverage**: Entity, Business Rules, Repository, State Machines, UI, Edge Cases

The **Master Panel** is a privileged administration screen reachable only
when the signed-in user's `users/{id}.isMaster` flag is `true`. It lets
the admin:

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
| `email`     | `String`   | Lower-cased; uniqueness is enforced      |
| `note`      | `String?`  | Free-form admin reminder                 |
| `addedAt`   | `DateTime` |                                          |
| `addedBy`   | `String?`  | UID of the master who added the entry    |

---

## 2. Business Rules

1. **Master gate.** The page is only routable when
   `isMasterEmail(auth.user.email)` is `true`. The route guard in
   `app_router.dart` does not enforce this — the navigation menu hides
   the link, and the page itself short-circuits to a permission error
   if hit directly. This is defence-in-depth, not the primary control;
   the **authoritative gate** is the Firestore security rule
   (`firestore.rules`) and the `deleteUserAsAdmin` Cloud Function —
   both must verify that `request.auth.token.email` (lower-cased) equals
   the master email constant.
2. **Allowlist is the onboarding gate.** A new sign-in is allowed through
   `Authenticated` only when the user's email matches an entry in
   `allowed_emails/` (see `access_control.md`). Removing an entry does
   NOT sign the existing user out — it only blocks future sign-ins.
3. **Deleting a user is irreversible.** Triggers the
   `deleteUserAsAdmin` Cloud Function which:
   - Removes every document owned by that `userId` across the six
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
  Future<Either<Failure, List<UserEntity>>> listAll();
  Future<Either<Failure, void>> deleteUser(String userId);
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

The cubit holds three independent slices in one state:

```dart
class MasterPanelState {
  final List<UserEntity> users;
  final List<AllowedEmail> allowlist;
  final bool isLoading;
  final Failure? error;
}
```

Transitions:

- `loadAll()` → `isLoading: true` → fetch users + allowlist in parallel
  → `isLoading: false` + populated lists, or `error` set on failure
- `addEmail(email, note)` → optimistic append → call repository →
  rollback on failure
- `removeEmail(email)` → optimistic remove → rollback on failure
- `deleteUser(userId)` → call function → on success, remove from `users`

The cubit does NOT auto-refresh: every mutation re-emits the optimistic
list. Stale data is corrected on next manual reload.

---

## 5. UI Contract

- **`MasterPanelPage`** — `DefaultTabController` with two tabs:
  - **Users** — list each `UserEntity`, render a `MASTER` chip for masters,
    long-press / overflow exposes the delete action.
  - **Allowlist** — list of `AllowedEmail` entries with note + remove
    action; FAB opens `AddAllowedEmailDialog`.
- **`AddAllowedEmailDialog`** — email validator + optional note. Submits
  through `AddAllowedEmailUseCase`.
- **`DeleteUserDialog`** — destructive double-confirm. Disables the
  delete button until the typed email exactly matches the target.

All copy lives under `t.masterPanel.*` in slang.

---

## 6. Edge Cases

1. **Non-master opens the route directly.** The cubit detects an empty
   `auth.user.isMaster` and refuses to load; the page renders the
   restricted-access state. Backend rules block the queries regardless.
2. **Removing the only master.** The master panel does not currently
   prevent removing the only master's `isMaster` flag (out of scope of
   this UI — only deletion is exposed, and `deleteUserAsAdmin` rejects
   self-delete). Leaving the system with zero masters requires a manual
   Firestore console edit.
3. **Add an email that already exists.** `AddAllowedEmailUseCase`
   normalizes to lower-case and the Firestore document id is the email —
   so a duplicate `add` becomes a no-op overwrite of `note`/`addedAt`.
4. **Delete an admin's own user.** Hidden from UI and rejected by the
   Cloud Function.
5. **Delete with offline network.** The function call fails; the user
   list is unchanged. The admin can retry.
6. **Removing an email while the target is signed in.** Their current
   session keeps working (sessions don't check the allowlist on every
   request). Next cold start, the access gate kicks in and redirects to
   `AccessRestrictedPage`.
