# Profile Feature Spec

> **Status**: Implemented (shipped)
> **Last updated**: 2026-05-13
> **Coverage**: Entity, Business Rules, Repository, State Machines, UI, Edge Cases

The **Profile** feature surfaces the signed-in user's read-only identity
(name, email, photo, build version), exposes app-level preferences
(theme, palettes, language), and hosts the **danger zone** that wipes
every user-scoped document on the backend plus the entire local cache.

The page is reachable from the main navigation as a top-level tab
(`Perfil`), positioned alongside Dashboard, Planning, Investments and Chat.

---

## 1. Entity Contract

The profile feature reuses `UserEntity` from the auth feature — there is no
profile-specific entity. The renderer reads:

| Field       | Type       | Notes                                       |
| ----------- | ---------- | ------------------------------------------- |
| `id`        | `String`   | Firebase Auth UID                           |
| `name`      | `String`   | Display name                                |
| `email`     | `String`   | Account email                               |
| `photoUrl`  | `String?`  | Provider-issued avatar URL (Google)         |
| `createdAt` | `DateTime` | First sign-in timestamp                     |

**Invariants**

1. `id` is non-empty and stable across sessions.
2. `email` is the same as the auth credential — never edited from this
   screen (account-rename is out of scope).
3. The local cache (`UsersDao`) is the source of truth while a session is
   active; Firestore is read-through only.

---

## 2. Business Rules

1. **Cache-first read.** `getProfile(userId)` returns the locally cached
   `UserEntity` if present, otherwise fetches `users/{userId}` from
   Firestore and upserts the result locally.
2. **Local mirror on update.** `updateProfile(user)` writes to Firestore
   first, then upserts the same record into `UsersDao`. If the Firestore
   write fails, the local cache is left untouched.
3. **Clear account data is irreversible.** Wipes every document owned by
   `userId` across legacy **bills**, **transactions**, **chat_messages**,
   **categories**, **accounts**, **budgets**, **asset_classes** and
   **asset_holdings**, then calls `AppDatabase.clearAllTables()` to drop the
   local cache. The user is asked to type their email as confirmation before
   the wipe runs (see `clear_account_data_dialog.dart`).
4. **No partial wipe.** All eight remote collections must be cleared. Adding
   a new user-scoped collection requires updating
   `ProfileRemoteDataSourceImpl._userScopedCollections` — otherwise orphan
   rows remain after the wipe (regression covered by
   `test/features/profile/data/datasources/profile_remote_datasource_test.dart`).
5. **Sign-out is separate.** Wiping data does NOT sign the user out — they
   can re-onboard immediately. Sign-out is a distinct action exposed via
   the danger zone.
6. **Build version is read-only.** The footer (`AppVersionFooter`) shows
   `AppVersion` injected from DI at startup. It never re-reads — a hot
   reload of `package_info_plus` is unsupported.

---

## 3. Repository Contract

```dart
abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile(String userId);
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);
  Future<Either<Failure, void>> clearAccountData(String userId);
}
```

All three return `ServerFailure` on backend errors; the wipe never
returns a partial-success state (the caller can't act on it — either
everything was deleted or nothing was).

`ProfileRemoteDataSource` is the only layer that talks to Firestore. The
repository delegates remote work to it and persists the local mirror via
`UsersDao` and `AppDatabase`.

---

## 4. State Machine — ProfileCubit

```
       ┌────────────┐
       │  Initial   │
       └─────┬──────┘
             │ loadProfile()
             ▼
       ┌────────────┐
       │  Loading   │
       └─────┬──────┘
             │ getProfile() result
             ▼
   ┌─────────┴──────────┐
   ▼                    ▼
┌────────┐         ┌────────┐
│Loaded  │         │ Error  │
└────────┘         └────────┘
```

The cubit only handles the read path. Theme/palette/language toggles
live in their own cubits (`ThemeCubit`, `LightPaletteCubit`,
`DarkPaletteCubit`, `AppLocaleCubit`) and do not write to `users/`.

The danger-zone dialog talks directly to `ClearAccountDataUseCase`; the
cubit is intentionally untouched so a successful wipe followed by sign-out
doesn't leave a stale `Loaded` state hanging on a defunct user id.

---

## 5. UI Contract

- **`ProfilePage`** — Material list grouped into sections:
  - **Your data** — accounts and categories shortcuts
  - **Preferences** — theme, palettes, language
  - **Get the app** — download Android APK (web only)
  - **Account** — sign out
  - **Danger zone** — clear data
  - **Master** — visible only when `AuthBloc.state.user.isMaster` is true;
    links to `MasterPanelPage` (see `master_panel.md`).
- **`ClearAccountDataDialog`** — two-step confirm: a typed email match
  unlocks the destructive button. Disables itself while the wipe runs to
  prevent double-tap.

---

## 6. Edge Cases

1. **Network down during wipe.** Repository returns `ServerFailure`; the
   local cache is **not** cleared (we don't strand a user offline with no
   local data but an intact remote dataset).
2. **User signs in on a new device after a wipe.** Both stores are empty;
   the startup sync sees nothing to pull. Spec is consistent.
3. **Wipe initiated, user backgrounds the app.** The Firestore batch runs
   to completion on the device — there is no per-doc progress indicator.
   If the app is killed mid-batch, some collections may be empty while
   others still hold data; the next "clear" call is idempotent and will
   finish the job.
4. **Master user wipes their own data.** Their `allowlist`/`isMaster`
   metadata lives under `users/{id}` and **survives** the wipe — only the
   eight user-scoped collections are touched (this is intentional: master
   privileges must persist across personal wipes).
5. **Concurrent updateProfile.** Last-write-wins (Firestore
   `update`). The local cache is overwritten with whatever shape the last
   call had — no manual conflict resolution.
