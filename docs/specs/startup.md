# Startup Feature Spec

The startup feature is the **gate between auth resolution and the app shell**. It owns the splash route (`/startup`), waits for `AuthBloc` to settle, runs the initial Firestore→Drift sync for authenticated users, and tells the router where to go next.

It has no domain or data layer — only a cubit (`StartupCubit`) and a page (`StartupPage`). It composes two collaborators: `AuthBloc` (auth state stream) and `SyncService` (the cross-feature snapshot fetcher in `core/sync/`).

## Responsibilities

1. Wait until auth has resolved (no rendering against `AuthInitial` / `AuthLoading`).
2. For authenticated users, run `SyncService.fullSync()` once before any feature page mounts so the local Drift cache is seeded.
3. Surface progress as a two-step bar (auth check → data sync).
4. Drive the router redirect away from `/startup`:
   - `Authenticated` → `/` (dashboard)
   - `Unauthenticated` → `/onboarding`
   - `AccessDenied` is **not** handled here — `AppRouter`'s redirect rule sends those to `/access-restricted` before the page sees them.
5. Recover from sync failure with an in-page retry (no auto-retry, no router escape).

## Collaborators

```dart
StartupCubit({
  required AuthBloc authBloc,
  required SyncService syncService,
});
```

- `AuthBloc` — read-only: the cubit reads `_authBloc.state` and listens to `_authBloc.stream`. It never dispatches events.
- `SyncService.fullSync({ userId, user })` — the only sync entry point. Throws `Exception` on any phase failure; cubit catches and emits `StartupError`.

## Business Rules

1. **Single-shot initialization** — `initialize()` is invoked exactly once by `StartupPage.initState`. Re-entry only happens via the error-state retry button.
2. **Auth-first** — the cubit always emits `StartupLoading('Checking authentication...', 0)` first, regardless of the current `AuthBloc` state, so the UI animates in consistently.
3. **Synchronous fast path** — if `AuthBloc.state` is already `Authenticated` or `Unauthenticated` at `initialize()` time, no stream subscription is created.
4. **Stream slow path** — if `AuthBloc.state` is `AuthInitial` (or any non-terminal state), the cubit subscribes to `_authBloc.stream` and waits for the first terminal event:
   - `Authenticated` → completes with `true`
   - `Unauthenticated` or `AuthError` → completes with `false`
   - The subscription is cancelled before `_waitForAuth()` returns.
5. **Sync only when authenticated** — `SyncService.fullSync()` is only called on the authenticated branch. Unauthenticated and error branches skip it entirely.
6. **Sync progress sentinel** — the cubit emits `StartupLoading('Syncing data...', 0.3)` immediately before invoking `fullSync`. The `0.3` literal is asserted by tests; the page derives the localized step label from this threshold (`progress >= 0.3` → "syncing data" copy, else "checking auth").
7. **Sync failure is terminal here** — any `Exception` from `fullSync` is mapped to `StartupError(e.toString())`. The user must retry; the cubit does not fall through to `StartupAuthenticated`.
8. **`AccessDenied` short-circuit** — `AccessDenied` is not a terminal state for `_waitForAuth`; the router redirects out of `/startup` before this branch is reached. If a deny somehow lands on the stream, it is ignored (no completion).

## State Machine

```dart
sealed class StartupState extends Equatable
StartupInitial
StartupLoading({ step: String, progress: double })
StartupAuthenticated({ userId: String })
StartupUnauthenticated
StartupError(message: String)
```

**Transitions:**

```
StartupInitial ──initialize()──→ StartupLoading('Checking authentication...', 0)

StartupLoading('Checking…', 0) ──auth = Unauthenticated──→ StartupUnauthenticated
                               ──auth = AuthError──────→ StartupUnauthenticated   [treated as not signed in]
                               ──auth = Authenticated──→ StartupLoading('Syncing data...', 0.3)

StartupLoading('Syncing…', 0.3) ──fullSync ok─→ StartupAuthenticated(userId)
                                ──fullSync throw─→ StartupError(message)

StartupError ──retry tap → initialize()──→ StartupLoading('Checking…', 0) → …
```

The cubit never returns to `StartupInitial` once `initialize()` has run. Retry from `StartupError` re-emits `StartupLoading` directly.

## Page Behavior

`StartupPage` is the only consumer of `StartupCubit`. Wiring:

- `initState` → `context.read<StartupCubit>().initialize()` (fire-and-forget; the cubit owns the future).
- `BlocListener<StartupCubit, StartupState>`:
  - `StartupAuthenticated` → `context.go(AppRoutes.dashboard)`
  - `StartupUnauthenticated` → `context.go(AppRoutes.onboarding)`
- `BlocBuilder` renders the progress bar (`progress` field of `StartupLoading`, 0 for initial, 1 for terminal non-error states) or the `_ErrorBlock` on `StartupError`.
- The step label is derived from `progress` rather than the raw `step` string so the cubit copy stays plain English (and tests can assert it).

## Edge Cases

- **`AuthBloc` already terminal** — fast path runs synchronously; `_waitForAuth` does not subscribe.
- **`AuthError` while waiting** — treated as `Unauthenticated`. The user is bounced to `/onboarding` and can try Google sign-in again.
- **`AccessDenied` arrives before auth resolves** — router redirect short-circuits before `StartupPage` finishes rendering; cubit may still be in `StartupLoading` when the page is torn down. Cubit `close()` is fine — the pending stream subscription is cancelled inside `_waitForAuth`'s `finally` (via `await subscription.cancel()`).
- **Stream completer race** — `_waitForAuth` guards every `complete()` with `!completer.isCompleted` so duplicate terminal events from the bloc do not throw.
- **Sync partial failure** — `SyncService.fullSync` is two-phase: it fetches all collections from Firestore (network), then atomically clears + repopulates Drift. A throw before the local phase leaves the previous local cache intact; a throw inside the local phase is unlikely (Drift is local) but would leave Drift in an inconsistent state — the retry path will re-run the full snapshot and overwrite again.
- **Retry while still loading** — not possible: the retry button is only rendered for `StartupError`, which is terminal.

## Lifecycle & DI

- Registered as `registerLazySingleton<StartupCubit>` (session-independent): a single instance is resolved from the service locator and provided app-wide via `FinancoApp`'s `MultiBlocProvider` — see `lib/app/di/injection_container.dart` and `lib/app/app_widget.dart`.
- The cubit holds no resources beyond a single transient stream subscription inside `_waitForAuth` (cancelled before the future resolves).

## i18n

All page copy lives under `t.startup.*`:

- `t.startup.tagline` — under the brand mark.
- `t.startup.stepCheckingAuth` / `t.startup.stepSyncingData` / `t.startup.stepReady` — progress labels.
- `t.startup.errorTitle` / `t.startup.errorRetry` — error block.

The cubit's `step` strings (`'Checking authentication...'`, `'Syncing data...'`) are **plain English literals** asserted by tests — they are intentionally not run through slang because they're internal sentinels, not user-facing copy.

## Testing

`test/features/startup/presentation/cubit/startup_cubit_test.dart` covers:

- Initial state.
- Fast path: already `Authenticated` → sync called → `StartupAuthenticated`.
- Sync failure → `StartupError`.
- Fast path: already `Unauthenticated` → no sync call → `StartupUnauthenticated`.
- Slow path: subscribes to stream and resolves on `Authenticated`.
- Slow path: subscribes to stream and resolves on `Unauthenticated`.
- Loading sentinels: first emission is `('Checking authentication...', 0)`; second is `('Syncing data...', 0.3)` before completion.
- `AuthInitial` keeps the cubit in `StartupLoading` until the stream emits a terminal state.

Mocks: `MockAuthBloc extends MockBloc<AuthEvent, AuthState>`, `MockSyncService` from `test/harness/mocks.dart`. No widget tests on the page — the routing side-effects are exercised through the cubit's terminal states.
