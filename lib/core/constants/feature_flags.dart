/// Compile-time flags gating features during phased rollout.
///
/// Toggle at build time with `--dart-define`, e.g.
/// `flutter run --dart-define=INVESTING_V2=true`.
library;

/// Gates the V2 investing module (real buy/sell transactions, market-valued
/// multi-currency holdings, quotes/FX, snapshots) while it is built out in
/// phases. Defaults to `false` so the legacy tracking-only investments module
/// keeps serving `/investments` until the port is complete and this flips.
///
/// See `docs/specs/investing.md` §0.9 and `docs/investanco-integration-plan.md`.
const bool kInvestingV2 = bool.fromEnvironment('INVESTING_V2');
