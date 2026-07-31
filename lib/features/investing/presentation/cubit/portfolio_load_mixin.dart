import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/portfolio_pricing_engine.dart';

/// The load-cycle steps the overview and allocation cubits share around their
/// own cache-first emit + compute/snapshot step: a one-shot warm start and the
/// best-effort network refresh of the held positions. Extracted so the two
/// cubits keep identical refresh behaviour without duplicating the guard and
/// the try/skip logic. The host cubit exposes its [engine] and calls these.
mixin PortfolioLoadMixin {
  /// The pricing engine the host cubit owns (mutable FX/index state).
  PortfolioPricingEngine get engine;

  Future<void>? _warmStart;

  /// Warm-starts [engine] exactly once per cubit lifetime (seeding FX + index
  /// series from the durable cache before the first paint).
  ///
  /// Memoises the in-flight future rather than flipping a bool after the
  /// `await`: a plain flag set on completion lets two overlapping callers both
  /// pass the guard and warm twice, which is exactly the case this exists to
  /// prevent. Reachable whenever a page mounts and the user immediately
  /// pull-to-refreshes. Concurrent callers now await the same future.
  Future<void> warmStartOnce() {
    return _warmStart ??= engine.warmStart();
  }

  /// Best-effort network refresh of the currently held positions, skipped when
  /// a peer screen already refreshed within the freshness window (and this
  /// isn't a forced reload). A network failure is swallowed so the cached
  /// prices stay on screen.
  Future<void> refreshHeldPositions(
    List<AssetTransaction> transactions,
    List<Asset> assets, {
    required bool force,
  }) async {
    final held = engine.heldPositions(transactions, assets);
    final skip = !force && await engine.quotesAreFresh(held.ids);
    if (skip) return;
    try {
      await engine.refreshNetwork(held.assets, transactions);
    } on Object {
      // Network failure — keep the cached prices on screen.
    }
  }
}
