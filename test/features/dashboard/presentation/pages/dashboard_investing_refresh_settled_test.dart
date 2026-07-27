import 'package:financo/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/presentation/cubit/investing_overview_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for [investingRefreshSettled] — the listenWhen predicate
/// that re-reads the Dashboard once the investing overview finishes its network
/// refresh (which warms the market-quote cache the Dashboard prices from).
void main() {
  InvestingOverviewLoaded loaded({required bool isRefreshing}) =>
      InvestingOverviewLoaded(
        portfolio: PortfolioValuation.empty(),
        assetsById: const {},
        isRefreshing: isRefreshing,
      );

  const loading = InvestingOverviewLoading();

  group('investingRefreshSettled', () {
    test('fires when refresh settles (isRefreshing true → false)', () {
      expect(
        investingRefreshSettled(
          loaded(isRefreshing: true),
          loaded(isRefreshing: false),
        ),
        isTrue,
      );
    });

    test('fires when it first settles from a non-loaded state', () {
      expect(
        investingRefreshSettled(loading, loaded(isRefreshing: false)),
        isTrue,
      );
    });

    test('does not fire while still refreshing', () {
      expect(
        investingRefreshSettled(
          loaded(isRefreshing: true),
          loaded(isRefreshing: true),
        ),
        isFalse,
      );
    });

    test('does not fire when a refresh starts (settled → refreshing)', () {
      expect(
        investingRefreshSettled(
          loaded(isRefreshing: false),
          loaded(isRefreshing: true),
        ),
        isFalse,
      );
    });

    test('does not fire on a no-op settled → settled rebuild', () {
      expect(
        investingRefreshSettled(
          loaded(isRefreshing: false),
          loaded(isRefreshing: false),
        ),
        isFalse,
      );
    });

    test('does not fire when the current state is not loaded', () {
      expect(
        investingRefreshSettled(loaded(isRefreshing: true), loading),
        isFalse,
      );
      expect(investingRefreshSettled(loading, loading), isFalse);
    });
  });
}
