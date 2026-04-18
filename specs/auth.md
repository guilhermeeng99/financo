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

1. **Email/password sign-in** — authenticates via Firebase Auth, fetches Firestore profile, upserts local DB.
2. **Google sign-in** — platform-specific: redirect flow on web (avoids COOP popup issues), `google_sign_in` on mobile. First-time users get a Firestore profile created automatically.
3. **Google sign-in resilience** — if Firestore is unavailable after Firebase Auth succeeds, returns a minimal profile from Firebase Auth data (non-fatal).
4. **Google sign-in cancellation** — if user cancels the dialog on mobile, `GoogleSignInException` is caught and mapped to `AuthFailure`.
5. **Sign-up** — creates Firebase Auth account, creates Firestore profile, upserts local DB.
6. **Sign-out** — Google sign-out is non-fatal (failure doesn't block Firebase sign-out). Firebase sign-out always executes. On success, clears all local data via `SyncService.clearLocalData()`.
7. **Sign-out error handling** — result is folded: failure emits `AuthError`, success emits `Unauthenticated`.
8. **getCurrentUser** — checks Firebase Auth session, fetches Firestore profile, upserts local if found. If authenticated user has no Firestore profile (e.g. first-time Google redirect on web), creates the profile automatically.
9. **authStateChanges** — stream from Firebase Auth mapped to Firestore profile fetch. Returns null on Firestore error (non-fatal).
10. **Error mapping** — `AuthException` → `AuthFailure`, generic `Exception` → `ServerFailure`. Applied consistently across all repository methods.
11. **Local persistence** — all sign-in/sign-up paths upsert the user to local Drift DB via `UsersDao`.

## Repository Contract

```dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
```

**Behavior:**
- signIn/signInWithGoogle/signUp → remote call + DAO upsert → Right(user)
- signOut → remote call + clearLocalData → Right(null)
- getCurrentUser → remote call, upsert if non-null → Right(user?)
- authStateChanges → delegates to remote datasource stream
- All methods catch `AuthException` → `Left(AuthFailure)`, then `Exception` → `Left(ServerFailure)`

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
- `AuthSignInRequested(email, password)` — email/password login
- `AuthSignUpRequested(name, email, password)` — registration
- `AuthGoogleSignInRequested` — Google login
- `AuthSignOutRequested` — logout

**States:**
- `AuthInitial`
- `AuthLoading`
- `Authenticated(user: UserEntity)`
- `Unauthenticated`
- `AuthError(failure: Failure)`

**Transitions:**

```
AuthInitial ──CheckRequested──→ Authenticated(user)  [user found]
                               → Unauthenticated      [null or failure]

Any ──SignInRequested──→ AuthLoading → Authenticated   [success]
                                     → AuthError       [failure]

Any ──SignUpRequested──→ AuthLoading → Authenticated   [success]
                                     → AuthError       [failure]

Any ──GoogleSignInRequested──→ AuthLoading → Authenticated [success]
                                           → AuthError     [failure]

Any ──SignOutRequested──→ Unauthenticated  [success]
                        → AuthError        [failure]
```

### StartupCubit

**States:**
- `StartupInitial`
- `StartupLoading(step: String, progress: double)`
- `StartupAuthenticated(userId: String)`
- `StartupUnauthenticated`
- `StartupError(message: String)`

**Behavior:**
- Constructor subscribes to `AuthBloc.stream`
- `initialize()` emits `StartupLoading("Checking authentication...", 0)`, then checks current AuthBloc state
- On `Authenticated` → emits `StartupLoading("Syncing data...", 0.3)`, runs `SyncService.fullSync()`, emits `StartupAuthenticated(userId)`
- On sync failure → emits `StartupError(message)`
- On `Unauthenticated` → emits `StartupUnauthenticated`
- Cancels stream subscription on `close()`

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
- **getCurrentUser with no session** — returns `Right(null)`, no DAO call.
- **getCurrentUser with session but no Firestore doc** — creates profile from Firebase Auth data (handles Google redirect on web).
- **authStateChanges Firestore error** — returns null (stream doesn't crash).
- **Profile local cache hit** — Firestore not called at all.
- **Empty profile fields** — name defaults to `'User'`, email to `''` from Firebase Auth.

## Firestore

**Collection:** `users/{userId}`

Fields: `name`, `email`, `photoUrl`, `createdAt`

No composite indexes needed — queries are by document ID only.
