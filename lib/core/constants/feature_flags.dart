/// Compile-time flags gating features during phased rollout.
///
/// Toggle at build time with `--dart-define`, e.g.
/// `flutter run --dart-define=INVESTING_V2=true`.
library;

/// Whether the V2 investing module (real buy/sell transactions, market-valued
/// multi-currency holdings, quotes/FX, snapshots, allocation, CSV import) is
/// live. The rollout is complete — the legacy tracking-only investments module
/// has been removed (F7), so this is now `true` unconditionally. Kept as a
/// named constant so the nav guards read intentionally rather than being
/// silently unconditional.
///
/// See `docs/specs/investing.md` and `docs/investanco-integration-plan.md`.
const bool kInvestingV2 = true;
