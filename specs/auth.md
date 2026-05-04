# Auth & Profile Feature Spec

## Entity Contract

```dart
UserEntity {
  id:        String    (required, Firebase Auth UID / Firestore doc ID)
  name:      String    (required)
  email:     String    (required)
  photoUrl:  String?   (nullable, Google profile picture URL)
  createdAt: DateTime  (required, set on sign-up)
}
```

No computed properties. Equatable by all fields.

## Business Rules

The app is **Google-only**. There is no email/password sign-in, no public sign-up, and no `SignInPage` — the unauthenticated landing is the `OnboardingPage` (final slide hosts the Google button). See [access_control.md](./access_control.md) for the allowlist gate that wraps every rule below.

1. **Google sign-in** — platform-specific: redirect flow on web (avoids COOP popup issues), `google_sign_in` on mobile. First-time users get a Firestore profile created automatically.
2. **Google sign-in resilience** — if Firestore is unavailable after Firebase Auth succeeds, returns a minimal profile from Firebase Auth data (non-fatal).
3. **Google sign-in cancellation** — if user cancels the dialog on mobile, `GoogleSignInException` is caught and mapped to `AuthFailure`.
4. **Allowlist gate** — after Firebase Auth + profile fetch, `signInWithGoogle` / `getCurrentUser` / `authStateChanges` apply the master + allowlist check. Blocked users get `Left(AccessDeniedFailure)` (after a forced `signOut`) on the imperative paths, or a `null` emission on the stream. See `access_control.md` rules 2–5.
5. **Sign-out** — platform-specific: on Web the `google_sign_in` plugin is *not* initialised (Firebase's `signInWithPopup` owns the GSI lifecycle), so calling `googleSignIn.signOut()` would throw `StateError`; the datasource skips it on Web and relies solely on `_auth.signOut()`. On mobile, Google sign-out is attempted but is non-fatal — any failure (Exception or Error) is swallowed so Firebase sign-out always executes. On success, the repository clears all local data via `SyncService.clearLocalData()`.
6. **Sign-out error handling** — result is folded: failure emits `AuthError`, success emits `Unauthenticated`.
7. **getCurrentUser** — checks Firebase Auth session, fetches Firestore profile, upserts local if found. If authenticated user has no Firestore profile (e.g. first-time Google redirect on web), creates the profile automatically.
8. **authStateChanges** — stream from Firebase Auth mapped to Firestore profile fetch. Returns null on Firestore error (non-fatal) or when the allowlist gate revokes a live session.
9. **Error mapping** — `AuthException` → `AuthFailure`, `AccessDeniedException` → `AccessDeniedFailure`, generic `Exception` → `ServerFailure`. Applied consistently across all repository methods.
10. **Local persistence** — every successful sign-in path upserts the user to local Drift DB via `UsersDao`.

## Repository Contract

```dart
abstract class AuthRepository {
  /// Google-only sign-in. Returns `Left(AccessDeniedFailure)` if the
  /// authenticated email is not in the allowlist (the user is signed
  /// out before the failure is returned, so no dangling session remains).
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream of session changes after the allowlist gate. Emits `null`
  /// when the user is signed out OR when the session was force-revoked
  /// because they lost access.
  Stream<UserEntity?> get authStateChanges;
}
```

**Behavior:**
- signInWithGoogle → remote call + allowlist gate + DAO upsert → Right(user)
- signOut → remote call + clearLocalData → Right(null)
- getCurrentUser → remote call + allowlist gate, upsert if non-null → Right(user?)
- authStateChanges → delegates to remote datasource stream, gated by allowlist
- All methods catch `AccessDeniedException` → `Left(AccessDeniedFailure)`, then `AuthException` → `Left(AuthFailure)`, then `Exception` → `Left(ServerFailure)`

## Model Serialization

**Firestore → Model (`fromFirestore`):**

| Firestore field | Dart field | Type cast |
|---|---|---|
| `doc.id` | `id` | `String` |
| `name` | `name` | `String` |
| `email` | `email` | `String` |
| `photoUrl` | `photoUrl` | `String?` |
| `createdAt` | `createdAt` | `Timestamp → DateTime` |

**Model → Firestore (`toJson`):**
- Serializes all fields except `id` (Firestore doc ID is separate).
- `createdAt` serialized as `Timestamp`.
- `photoUrl` included even when null.

**fromEntity:** direct field copy, preserving all values.

## State Machines

### AuthBloc

**Events:**
- `AuthCheckRequested` — check current session
- `AuthGoogleSignInRequested` — Google login
- `AuthSignOutRequested` — logout
- `AuthUserChanged(user)` — internal, dispatched from the `authStateChanges` subscription

**States:**
- `AuthInitial`
- `AuthLoading`
- `Authenticated(user: UserEntity)`
- `Unauthenticated`
- `AccessDenied(email: String)` — emitted when the allowlist gate blocks a sign-in or revokes a live session
- `AuthError(failure: Failure)`

**Transitions:**

```
AuthInitial ──CheckRequested──→ Authenticated(user)  [user found]
                               → Unauthenticated      [null or failure]
                               → AccessDenied(email)  [allowlist gate blocks]

Any ──GoogleSignInRequested──→ AuthLoading → Authenticated     [allowed]
                                           → AccessDenied(...) [not allowed; repo signs out before return]
                                           → AuthError         [other failure]

Any ──SignOutRequested──→ Unauthenticated  [success]
                        → AuthError        [failure]

Authenticated(user) ──allowlist removed remotely──→ AccessDenied(email)
```

### StartupCubit

Lives in its own feature; see [startup.md](./startup.md). It subscribes to `AuthBloc.stream`, runs `SyncService.fullSync()` for authenticated users, and drives the `/startup` → `/dashboard` or `/onboarding` redirect.

## Profile

### ProfileRepository Contract

```dart
abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile(String userId);
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);
}
```

**Behavior:**
- `getProfile` → local-first: try `UsersDao.getUser()`, fallback to Firestore + upsert local.
- `updateProfile` → remote-first: update Firestore, then upsert local. Uses `UserModel.fromEntity()` for serialization.
- Both return `Left(ServerFailure)` on exception.

### ProfileCubit

**States:**
- `ProfileInitial`
- `ProfileLoading`
- `ProfileLoaded(user: UserEntity)`
- `ProfileError(failure: Failure)`

```
Initial ──loadProfile()──→ Loading → Loaded(user)  [success]
                                   → Error(failure) [failure]

Loaded ──loadProfile(forceRefresh: false)──→ (no-op)
Loaded ──loadProfile(forceRefresh: true)──→ Loading → ...
```

## Edge Cases

- **Sign-out failure** — surfaced to UI via `AuthError`, not silently ignored.
- **Google sign-in cancelled** — `GoogleSignInException` caught, mapped to `AuthFailure`.
- **Google sign-out failure** — non-fatal, Firebase sign-out still proceeds.
- **Firestore unavailable during Google sign-in** — returns minimal profile from Firebase Auth data.
- **Email not on allowlist** — repository signs out, returns `AccessDeniedFailure`; AuthBloc emits `AccessDenied(email)`; router pushes `/access-restricted`.
- **Allowlist removed mid-session** — next `authStateChanges` tick sees the gate fail and emits `null` → `Unauthenticated` (or `AccessDenied` if the email is captured).
- **getCurrentUser with no session** — returns `Right(null)`, no DAO call.
- **getCurrentUser with session but no Firestore doc** — creates profile from Firebase Auth data (handles Google redirect on web).
- **authStateChanges Firestore error** — returns null (stream doesn't crash).
- **Profile local cache hit** — Firestore not called at all.
- **Empty profile fields** — name defaults to `'User'`, email to `''` from Firebase Auth.

## Firestore

**Collection:** `users/{userId}`

Fields: `name`, `email`, `photoUrl`, `createdAt`

No composite indexes needed — queries are by document ID only.
