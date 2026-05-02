import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BankBrand registry', () {
    test('every BankType value has a registered brand', () {
      // Guards against forgetting a registry entry when adding a new
      // BankType — would otherwise blow up at runtime via StateError.
      for (final type in BankType.values) {
        final brand = BankBrand.of(type);
        expect(
          brand.label,
          isNotEmpty,
          reason: '${type.name} is missing a label',
        );
      }
    });

    test('non-others brands have a non-empty abbreviation', () {
      for (final type in BankType.values) {
        if (type == BankType.others) continue;
        expect(
          BankBrand.of(type).abbreviation,
          isNotEmpty,
          reason: '${type.name} needs an abbreviation for the avatar',
        );
      }
    });
  });

  group('BankBrand.resolveAlias', () {
    test('resolves exact label match', () {
      expect(BankBrand.resolveAlias('Nubank'), BankType.nubank);
      expect(BankBrand.resolveAlias('Itaú'), BankType.itau);
    });

    test('is case-insensitive', () {
      expect(BankBrand.resolveAlias('NUBANK'), BankType.nubank);
      expect(BankBrand.resolveAlias('itau'), BankType.itau);
    });

    test('strips diacritics', () {
      expect(BankBrand.resolveAlias('Itau'), BankType.itau);
      expect(BankBrand.resolveAlias('itaú'), BankType.itau);
    });

    test('resolves common short aliases', () {
      expect(BankBrand.resolveAlias('nu'), BankType.nubank);
      expect(BankBrand.resolveAlias('bb'), BankType.bancoDoBrasil);
      expect(BankBrand.resolveAlias('cef'), BankType.caixa);
      expect(BankBrand.resolveAlias('btg'), BankType.btg);
    });

    test('distinguishes NuInvest from Nubank', () {
      expect(BankBrand.resolveAlias('NuInvest'), BankType.nuInvest);
      expect(BankBrand.resolveAlias('nu invest'), BankType.nuInvest);
      // Easynvest was the pre-acquisition brand name; users may still
      // type it when migrating from older statements.
      expect(BankBrand.resolveAlias('Easynvest'), BankType.nuInvest);
    });

    test('resolves multi-word labels', () {
      expect(
        BankBrand.resolveAlias('Banco do Brasil'),
        BankType.bancoDoBrasil,
      );
      expect(BankBrand.resolveAlias('Mercado Pago'), BankType.mercadoPago);
      expect(BankBrand.resolveAlias('BTG Pactual'), BankType.btg);
    });

    test('resolves enum.name strings emitted by AI tools', () {
      expect(BankBrand.resolveAlias('mercadoPago'), BankType.mercadoPago);
      expect(BankBrand.resolveAlias('bancoDoBrasil'), BankType.bancoDoBrasil);
    });

    test('returns null for empty / unknown input', () {
      expect(BankBrand.resolveAlias(''), isNull);
      expect(BankBrand.resolveAlias('   '), isNull);
      expect(BankBrand.resolveAlias('xpto-bank'), isNull);
    });
  });
}
