import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';

/// Test data builders for the V2 investing module. Never hardcode entities in
/// tests — compose from these (project convention, CLAUDE.md Testing Rules).
class InstitutionFactory {
  const InstitutionFactory._();

  static Institution avenue({
    String id = 'inst-avenue',
    String userId = 'user-1',
    String name = 'Avenue',
    InstitutionKind kind = InstitutionKind.internationalBroker,
    Currency currency = Currency.usd,
    DateTime? createdAt,
  }) {
    return Institution(
      id: id,
      userId: userId,
      name: name,
      kind: kind,
      currency: currency,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static Institution nubank({
    String id = 'inst-nubank',
    String userId = 'user-1',
    String name = 'Nubank',
    InstitutionKind kind = InstitutionKind.bank,
    Currency currency = Currency.brl,
    DateTime? createdAt,
  }) {
    return Institution(
      id: id,
      userId: userId,
      name: name,
      kind: kind,
      currency: currency,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}

class AssetFactory {
  const AssetFactory._();

  static Asset stockUs({
    String id = 'asset-aapl',
    String userId = 'user-1',
    String ticker = 'AAPL',
    String name = 'Apple Inc.',
    AssetKind kind = AssetKind.stockUs,
    Market market = Market.us,
    Currency currency = Currency.usd,
    String? institutionId = 'inst-avenue',
    Map<String, String> metadata = const {},
    DateTime? createdAt,
  }) {
    return Asset(
      id: id,
      userId: userId,
      ticker: ticker,
      name: name,
      kind: kind,
      market: market,
      currency: currency,
      institutionId: institutionId,
      metadata: metadata,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static Asset stockBr({
    String id = 'asset-petr4',
    String userId = 'user-1',
    String ticker = 'PETR4',
    String name = 'Petrobras PN',
    AssetKind kind = AssetKind.stockBr,
    Market market = Market.br,
    Currency currency = Currency.brl,
    String? institutionId = 'inst-nubank',
    Map<String, String> metadata = const {},
    DateTime? createdAt,
  }) {
    return Asset(
      id: id,
      userId: userId,
      ticker: ticker,
      name: name,
      kind: kind,
      market: market,
      currency: currency,
      institutionId: institutionId,
      metadata: metadata,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}

class AssetTransactionFactory {
  const AssetTransactionFactory._();

  static AssetTransaction buy({
    String id = 'tx-buy-1',
    String userId = 'user-1',
    String institutionId = 'inst-avenue',
    String assetId = 'asset-aapl',
    double quantity = 10,
    Money? unitPrice,
    Money? fees,
    Currency currency = Currency.usd,
    DateTime? date,
    DateTime? createdAt,
    String? notes,
  }) {
    final price = unitPrice ?? Money.fromMajor(100, currency);
    final fee = fees ?? Money.zero(currency);
    final when = date ?? DateTime(2024, 1, 10);
    return AssetTransaction(
      id: id,
      userId: userId,
      institutionId: institutionId,
      assetId: assetId,
      kind: TransactionKind.buy,
      quantity: quantity,
      unitPrice: price,
      fees: fee,
      amount: price * quantity,
      date: when,
      createdAt: createdAt ?? when,
      updatedAt: createdAt ?? when,
      notes: notes,
    );
  }

  static AssetTransaction sell({
    String id = 'tx-sell-1',
    String userId = 'user-1',
    String institutionId = 'inst-avenue',
    String assetId = 'asset-aapl',
    double quantity = 4,
    Money? unitPrice,
    Money? fees,
    Currency currency = Currency.usd,
    DateTime? date,
    DateTime? createdAt,
    String? notes,
  }) {
    final price = unitPrice ?? Money.fromMajor(150, currency);
    final fee = fees ?? Money.zero(currency);
    final when = date ?? DateTime(2024, 2, 10);
    return AssetTransaction(
      id: id,
      userId: userId,
      institutionId: institutionId,
      assetId: assetId,
      kind: TransactionKind.sell,
      quantity: quantity,
      unitPrice: price,
      fees: fee,
      amount: price * quantity,
      date: when,
      createdAt: createdAt ?? when,
      updatedAt: createdAt ?? when,
      notes: notes,
    );
  }

  static AssetTransaction dividend({
    String id = 'tx-div-1',
    String userId = 'user-1',
    String institutionId = 'inst-avenue',
    String assetId = 'asset-aapl',
    Money? amount,
    Currency currency = Currency.usd,
    DateTime? date,
    DateTime? createdAt,
    String? notes,
  }) {
    final total = amount ?? Money.fromMajor(20, currency);
    final when = date ?? DateTime(2024, 3, 10);
    return AssetTransaction(
      id: id,
      userId: userId,
      institutionId: institutionId,
      assetId: assetId,
      kind: TransactionKind.dividend,
      quantity: 0,
      unitPrice: Money.zero(currency),
      fees: Money.zero(currency),
      amount: total,
      date: when,
      createdAt: createdAt ?? when,
      updatedAt: createdAt ?? when,
      notes: notes,
    );
  }
}

class SnapshotFactory {
  const SnapshotFactory._();

  static Snapshot day({
    String userId = 'user-1',
    DateTime? date,
    Money? totalValue,
    Money? totalInvested,
    Money? unrealizedPL,
    Currency currency = Currency.brl,
  }) {
    final value = totalValue ?? Money.fromMajor(1000, currency);
    final invested = totalInvested ?? Money.fromMajor(800, currency);
    return Snapshot(
      userId: userId,
      date: date ?? DateTime(2024, 1, 10),
      totalValue: value,
      totalInvested: invested,
      unrealizedPL: unrealizedPL ?? (value - invested),
    );
  }
}
