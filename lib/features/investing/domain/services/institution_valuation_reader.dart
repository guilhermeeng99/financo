import 'package:equatable/equatable.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/services/portfolio_pricing_engine.dart';

/// The market valuation of one institution's holdings, consolidated to the base
/// currency (BRL). Lets the Dashboard show an investment account's live market
/// value instead of a hand-kept principal balance (F8 — see
/// `docs/specs/investing_account_unification.md`).
class InstitutionValuation extends Equatable {
  /// Creates an institution valuation.
  const InstitutionValuation({
    required this.marketValue,
    required this.invested,
    required this.priceStale,
    required this.fxMissing,
  });

  /// A zero valuation in BRL (an institution with no open holdings).
  const InstitutionValuation.zero()
    : marketValue = const Money.zero(Currency.brl),
      invested = const Money.zero(Currency.brl),
      priceStale = false,
      fxMissing = false;

  /// Current market value of the institution's holdings (BRL).
  final Money marketValue;

  /// Cost basis of the open positions (BRL).
  final Money invested;

  /// True when any holding's price is missing/stale (value fell back to cost).
  final bool priceStale;

  /// True when any foreign holding lacked an FX rate and was therefore excluded
  /// from the consolidated [marketValue].
  final bool fxMissing;

  /// Unrealized profit/loss (market − invested), BRL.
  Money get unrealizedPL => marketValue - invested;

  @override
  List<Object?> get props => [marketValue, invested, priceStale, fxMissing];
}

/// Prices each institution's holdings from the local caches (no network) so a
/// consumer outside the investing screens — namely the Dashboard — can show the
/// same market value the Portfolio page shows, keyed by institution id.
///
/// Read-only and best-effort: any load failure yields an empty map so the
/// Dashboard degrades to its cash-only view rather than surfacing an error.
/// This is the single intentional join between the accounts/dashboard world and
/// the investing valuation engine (F8.2 — see
/// `docs/specs/investing_account_unification.md`).
///
/// Example:
/// ```dart
/// final byInstitution = await reader.read(userId);
/// final avenue = byInstitution['avenue-id'] ?? InstitutionValuation.zero();
/// ```
class InstitutionValuationReader {
  /// Creates the reader over the investing repositories and the shared pricing
  /// engine (a fresh [PortfolioPricingEngine] instance from the DI factory).
  InstitutionValuationReader({
    required AssetTransactionRepository transactionRepository,
    required AssetRepository assetRepository,
    required PortfolioPricingEngine pricingEngine,
  }) : _transactionRepository = transactionRepository,
       _assetRepository = assetRepository,
       _engine = pricingEngine;

  final AssetTransactionRepository _transactionRepository;
  final AssetRepository _assetRepository;
  final PortfolioPricingEngine _engine;

  /// Returns institution id → [InstitutionValuation] for every institution that
  /// currently holds at least one position. Institutions with no holdings are
  /// absent from the map (callers treat a miss as [InstitutionValuation.zero]).
  Future<Map<String, InstitutionValuation>> read(String userId) async {
    final txsResult = await _transactionRepository.getTransactions(
      userId: userId,
    );
    final assetsResult = await _assetRepository.getAssets(userId: userId);

    final transactions = txsResult.getOrElse(() => const <AssetTransaction>[]);
    final assets = assetsResult.getOrElse(() => const <Asset>[]);
    if (transactions.isEmpty) return const {};

    // Warm-start (FX + index series from the durable cache) then price from the
    // local quote cache — no network, so the Dashboard load stays cheap and
    // reflects the same values as the Portfolio page's cache-first paint.
    await _engine.warmStart();
    final priced = await _engine.priceFromCache(transactions, assets);
    final portfolio = priced.portfolio;

    final institutionIds = <String>{
      for (final holding in portfolio.holdings) holding.institutionId,
    };

    final byInstitution = <String, InstitutionValuation>{};
    for (final id in institutionIds) {
      final subset = portfolio.forInstitution(id);
      byInstitution[id] = InstitutionValuation(
        marketValue: subset.totalValueBase,
        invested: subset.totalInvestedBase,
        priceStale: subset.holdings.any((h) => h.priceStale),
        fxMissing: subset.holdings.any((h) => h.fxMissing),
      );
    }
    return byInstitution;
  }
}
