import 'package:financo/core/money/currency.dart';
import 'package:financo/core/utils/string_normalize.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/gen/i18n/strings.g.dart';

/// Cell parsers shared by the investing CSV importers (assets + transactions).
/// Each throws a [FormatException] tagged with the offending `row` so the
/// importer surfaces a row-pointing message. Matching is accent/case/space
/// insensitive. See `docs/specs/investing_csv_import.md`.

String _key(String raw) => normalizeForMatch(raw).replaceAll(' ', '');

/// Every accepted spelling of an [AssetKind]; the enum `name` is always valid.
const _assetKindSynonyms = <String, AssetKind>{
  'stockbr': AssetKind.stockBr,
  'acaobr': AssetKind.stockBr,
  'acao': AssetKind.stockBr,
  'fiibr': AssetKind.fiiBr,
  'fii': AssetKind.fiiBr,
  'etfbr': AssetKind.etfBr,
  'bdrbr': AssetKind.bdrBr,
  'bdr': AssetKind.bdrBr,
  'stockus': AssetKind.stockUs,
  'acaous': AssetKind.stockUs,
  'stock': AssetKind.stockUs,
  'etfus': AssetKind.etfUs,
  'etf': AssetKind.etfUs,
  'crypto': AssetKind.crypto,
  'cripto': AssetKind.crypto,
  'treasury': AssetKind.treasury,
  'tesouro': AssetKind.treasury,
  'fixedincome': AssetKind.fixedIncome,
  'rendafixa': AssetKind.fixedIncome,
  'fund': AssetKind.fund,
  'fundo': AssetKind.fund,
  'cash': AssetKind.cash,
  'caixa': AssetKind.cash,
  'dinheiro': AssetKind.cash,
};

/// Parses the `kind` cell into an [AssetKind]. Empty or unknown → throws.
AssetKind parseAssetKind(String raw, int row) {
  final key = _key(raw);
  if (key.isEmpty) {
    throw FormatException(t.csvImport.errors.assetKindEmpty(row: row));
  }
  final byName = _byEnumName(AssetKind.values, key);
  final kind = byName ?? _assetKindSynonyms[key];
  if (kind == null) {
    throw FormatException(
      t.csvImport.errors.assetKindInvalid(row: row, value: raw),
    );
  }
  return kind;
}

/// The default `(market, currency)` for a [kind], used when the CSV omits
/// those columns.
(Market, Currency) assetKindDefaults(AssetKind kind) => switch (kind) {
  AssetKind.stockUs || AssetKind.etfUs => (Market.us, Currency.usd),
  AssetKind.crypto => (Market.global, Currency.usd),
  _ => (Market.br, Currency.brl),
};

/// Parses the optional `market` cell. Empty → null (caller applies a default).
Market? parseMarket(String raw, int row) {
  final key = _key(raw);
  if (key.isEmpty) return null;
  final market = _byEnumName(Market.values, key) ?? _marketSynonyms[key];
  if (market == null) {
    throw FormatException(
      t.csvImport.errors.marketInvalid(row: row, value: raw),
    );
  }
  return market;
}

const _marketSynonyms = <String, Market>{
  'brasil': Market.br,
  'brazil': Market.br,
  'usa': Market.us,
  'eua': Market.us,
  'unitedstates': Market.us,
  'global': Market.global,
};

/// Parses the optional `currency` cell. Empty → null (caller applies a
/// default).
Currency? parseCurrency(String raw, int row) {
  final key = _key(raw);
  if (key.isEmpty) return null;
  final currency = _byEnumName(Currency.values, key) ?? _currencySynonyms[key];
  if (currency == null) {
    throw FormatException(
      t.csvImport.errors.currencyInvalid(row: row, value: raw),
    );
  }
  return currency;
}

const _currencySynonyms = <String, Currency>{
  r'r$': Currency.brl,
  'real': Currency.brl,
  'reais': Currency.brl,
  r'us$': Currency.usd,
  'dollar': Currency.usd,
  'dolar': Currency.usd,
  'euro': Currency.eur,
  '€': Currency.eur,
};

/// Parses the optional `operation` cell. Empty → [TransactionKind.buy].
TransactionKind parseTransactionKind(String raw, int row) {
  final key = _key(raw);
  if (key.isEmpty) return TransactionKind.buy;
  final kind =
      _byEnumName(TransactionKind.values, key) ?? _operationSynonyms[key];
  if (kind == null) {
    throw FormatException(
      t.csvImport.errors.operationInvalid(row: row, value: raw),
    );
  }
  return kind;
}

const _operationSynonyms = <String, TransactionKind>{
  'compra': TransactionKind.buy,
  'buy': TransactionKind.buy,
  'venda': TransactionKind.sell,
  'sell': TransactionKind.sell,
  'dividendo': TransactionKind.dividend,
  'dividend': TransactionKind.dividend,
  'provento': TransactionKind.dividend,
  'proventos': TransactionKind.dividend,
};

T? _byEnumName<T extends Enum>(List<T> values, String key) {
  for (final value in values) {
    if (value.name.toLowerCase() == key) return value;
  }
  return null;
}
