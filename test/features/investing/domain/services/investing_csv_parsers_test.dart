import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/investing_csv_parsers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const row = 3;

  group('parseAssetKind', () {
    test('accepts the enum name', () {
      expect(parseAssetKind('stockBr', row), AssetKind.stockBr);
      expect(parseAssetKind('fixedIncome', row), AssetKind.fixedIncome);
    });

    test('accepts Portuguese/informal synonyms', () {
      expect(parseAssetKind('ação', row), AssetKind.stockBr);
      expect(parseAssetKind('fii', row), AssetKind.fiiBr);
      expect(parseAssetKind('bdr', row), AssetKind.bdrBr);
      expect(parseAssetKind('cripto', row), AssetKind.crypto);
      expect(parseAssetKind('tesouro', row), AssetKind.treasury);
      expect(parseAssetKind('renda fixa', row), AssetKind.fixedIncome);
      expect(parseAssetKind('fundo', row), AssetKind.fund);
      expect(parseAssetKind('dinheiro', row), AssetKind.cash);
    });

    test('is accent, case and space insensitive', () {
      expect(parseAssetKind('  AÇÃO  ', row), AssetKind.stockBr);
      expect(parseAssetKind('Renda Fixa', row), AssetKind.fixedIncome);
      expect(parseAssetKind('CRIPTO', row), AssetKind.crypto);
    });

    test('throws on empty or blank input', () {
      expect(() => parseAssetKind('', row), throwsFormatException);
      expect(() => parseAssetKind('   ', row), throwsFormatException);
    });

    test('throws on an unknown value', () {
      expect(() => parseAssetKind('bogus', row), throwsFormatException);
    });
  });

  group('assetKindDefaults', () {
    test('US kinds default to the US market in USD', () {
      expect(assetKindDefaults(AssetKind.etfUs), (Market.us, Currency.usd));
    });

    test('crypto defaults to the global market in USD', () {
      expect(
        assetKindDefaults(AssetKind.crypto),
        (Market.global, Currency.usd),
      );
    });

    test('everything else defaults to the BR market in BRL', () {
      expect(assetKindDefaults(AssetKind.stockBr), (Market.br, Currency.brl));
    });
  });

  group('parseMarket', () {
    test('accepts enum names and synonyms', () {
      expect(parseMarket('br', row), Market.br);
      expect(parseMarket('brasil', row), Market.br);
      expect(parseMarket('EUA', row), Market.us);
      expect(parseMarket('united states', row), Market.us);
      expect(parseMarket('global', row), Market.global);
    });

    test('returns null when empty (caller applies a default)', () {
      expect(parseMarket('', row), isNull);
      expect(parseMarket('   ', row), isNull);
    });

    test('throws on an unknown value', () {
      expect(() => parseMarket('mars', row), throwsFormatException);
    });
  });

  group('parseCurrency', () {
    test('accepts enum names and symbol/word synonyms', () {
      expect(parseCurrency('brl', row), Currency.brl);
      expect(parseCurrency(r'R$', row), Currency.brl);
      expect(parseCurrency('reais', row), Currency.brl);
      expect(parseCurrency(r'US$', row), Currency.usd);
      expect(parseCurrency('dólar', row), Currency.usd);
      expect(parseCurrency('euro', row), Currency.eur);
      expect(parseCurrency('€', row), Currency.eur);
    });

    test('returns null when empty (caller applies a default)', () {
      expect(parseCurrency('', row), isNull);
    });

    test('throws on an unknown value', () {
      expect(() => parseCurrency('yen', row), throwsFormatException);
    });
  });

  group('parseTransactionKind', () {
    test('accepts Portuguese/informal synonyms', () {
      expect(parseTransactionKind('compra', row), TransactionKind.buy);
      expect(parseTransactionKind('venda', row), TransactionKind.sell);
      expect(parseTransactionKind('dividendo', row), TransactionKind.dividend);
      expect(parseTransactionKind('provento', row), TransactionKind.dividend);
    });

    test('is accent, case and space insensitive', () {
      expect(parseTransactionKind(' COMPRA ', row), TransactionKind.buy);
      expect(parseTransactionKind('Venda', row), TransactionKind.sell);
    });

    test('defaults to buy when empty or blank', () {
      expect(parseTransactionKind('', row), TransactionKind.buy);
      expect(parseTransactionKind('   ', row), TransactionKind.buy);
    });

    test('throws on an unknown value', () {
      expect(() => parseTransactionKind('swap', row), throwsFormatException);
    });
  });
}
