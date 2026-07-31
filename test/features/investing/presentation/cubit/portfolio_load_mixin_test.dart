import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/portfolio_pricing_engine.dart';
import 'package:financo/features/investing/presentation/cubit/portfolio_load_mixin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

/// Minimal host for the mixin. The real hosts are the overview and allocation
/// cubits; testing the mixin on a bare class keeps these cases about the
/// warm/dedupe seam itself rather than either cubit's state machine.
class _MixinHost with PortfolioLoadMixin {
  _MixinHost(this.engine);

  @override
  final PortfolioPricingEngine engine;
}

void main() {
  late MockPortfolioPricingEngine engine;

  final transactions = [AssetTransactionFactory.buy()];
  final held = AssetFactory.stockUs();
  final sold = AssetFactory.stockBr();

  setUpAll(() {
    registerFallbackValue(<AssetTransaction>[]);
    registerFallbackValue(<Asset>[]);
    registerFallbackValue(<String>{});
  });

  setUp(() {
    engine = MockPortfolioPricingEngine();
    when(engine.warmStart).thenAnswer((_) async {});
    when(
      () => engine.heldPositions(any(), any()),
    ).thenReturn((assets: [held], ids: {held.id}));
    when(() => engine.quotesAreFresh(any())).thenAnswer((_) async => false);
    when(() => engine.refreshNetwork(any(), any())).thenAnswer((_) async {});
  });

  group('warmStartOnce', () {
    test('warm-starts the engine on the first call', () async {
      await _MixinHost(engine).warmStartOnce();

      verify(engine.warmStart).called(1);
    });

    test('never warm-starts twice for the same host', () async {
      // Both cubits call this at the top of every `load()`, and the page
      // reloads on each mount — without the guard, every navigation would
      // re-read the whole FX + index cache before the first paint.
      final host = _MixinHost(engine);

      await host.warmStartOnce();
      await host.warmStartOnce();
      await host.warmStartOnce();

      verify(engine.warmStart).called(1);
    });

    test('does not warm-start twice when two loads overlap', () async {
      // Regression, 2026-07-31 audit: the guard used to be a bool set *after*
      // awaiting `engine.warmStart()`, so two overlapping callers both passed
      // it and warmed twice — reachable whenever a page mounts and the user
      // immediately pull-to-refreshes. Memoising the in-flight future fixed it.
      final host = _MixinHost(engine);

      await Future.wait([host.warmStartOnce(), host.warmStartOnce()]);

      verify(engine.warmStart).called(1);
    });

    test('guards per host, not globally', () async {
      // The dashboard and allocation screens each mix this in over their own
      // engine instance; one screen warming up must not suppress the other's.
      final otherEngine = MockPortfolioPricingEngine();
      when(otherEngine.warmStart).thenAnswer((_) async {});

      await _MixinHost(engine).warmStartOnce();
      await _MixinHost(otherEngine).warmStartOnce();

      verify(engine.warmStart).called(1);
      verify(otherEngine.warmStart).called(1);
    });
  });

  group('refreshHeldPositions', () {
    test('refreshes over the network when cached quotes are stale', () async {
      await _MixinHost(engine).refreshHeldPositions(
        transactions,
        [held],
        force: false,
      );

      verify(() => engine.refreshNetwork(any(), any())).called(1);
    });

    test('skips when a peer screen already refreshed in-window', () async {
      // The dedupe seam: overview and allocation price the same portfolio, so
      // opening the second screen must not re-hit the network.
      when(() => engine.quotesAreFresh(any())).thenAnswer((_) async => true);

      await _MixinHost(engine).refreshHeldPositions(
        transactions,
        [held],
        force: false,
      );

      verifyNever(() => engine.refreshNetwork(any(), any()));
    });

    test('force bypasses the freshness check entirely', () async {
      when(() => engine.quotesAreFresh(any())).thenAnswer((_) async => true);

      await _MixinHost(engine).refreshHeldPositions(
        transactions,
        [held],
        force: true,
      );

      // Pull-to-refresh must reach the network even inside the window, and
      // short-circuit evaluation means the window is not even consulted.
      verifyNever(() => engine.quotesAreFresh(any()));
      verify(() => engine.refreshNetwork(any(), any())).called(1);
    });

    test('refreshes only the held assets, not every known asset', () async {
      // Quotes cost network calls per asset — a fully-sold position must not
      // be priced.
      await _MixinHost(engine).refreshHeldPositions(
        transactions,
        [held, sold],
        force: true,
      );

      final captured = verify(
        () => engine.refreshNetwork(captureAny(), any()),
      ).captured.single as List<Asset>;
      expect(captured, [held]);
    });

    test('checks freshness against the held ids', () async {
      await _MixinHost(engine).refreshHeldPositions(
        transactions,
        [held, sold],
        force: false,
      );

      final captured = verify(
        () => engine.quotesAreFresh(captureAny()),
      ).captured.single as Set<String>;
      expect(captured, {held.id});
    });

    test('swallows a network failure so cached prices stay up', () async {
      when(() => engine.refreshNetwork(any(), any())).thenAnswer((_) async {
        throw Exception('offline');
      });

      await expectLater(
        _MixinHost(engine).refreshHeldPositions(
          transactions,
          [held],
          force: true,
        ),
        completes,
      );
    });

    test('swallows a non-Exception error too', () async {
      // The catch is `on Object` on purpose — a plugin can throw a raw Error,
      // and an unhandled one here would tear down the whole load.
      when(
        () => engine.refreshNetwork(any(), any()),
      ).thenThrow(StateError('bad plugin state'));

      await expectLater(
        _MixinHost(engine).refreshHeldPositions(
          transactions,
          [held],
          force: true,
        ),
        completes,
      );
    });
  });
}
