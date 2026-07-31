import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/models/asset_model.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  /// Firestore hands `fromMap` back exactly what `toJson` wrote, so a
  /// serialise → deserialise cycle is the contract this model has to hold.
  AssetModel roundTrip(AssetModel model) =>
      AssetModel.fromMap(id: model.id, data: model.toJson());

  /// The smallest map `fromMap` accepts; enum cells are filled per-test so the
  /// fallback cases below vary one field at a time.
  Map<String, dynamic> rawAsset({
    Object? kind = 'etfUs',
    Object? market = 'us',
    Object? currency = 'usd',
  }) => {
    'userId': 'user-1',
    'ticker': 'VOO',
    'name': 'Vanguard S&P 500',
    'kind': kind,
    'market': market,
    'currency': currency,
    'createdAt': Timestamp.fromDate(DateTime(2024)),
  };

  group('round-trip', () {
    test('preserves every field of a US stock', () {
      final model = AssetModel.fromEntity(AssetFactory.stockUs());

      final decoded = roundTrip(model);

      expect(decoded, model);
    });

    test('preserves the metadata map, including the allocation link', () {
      final model = AssetModel.fromEntity(
        AssetFactory.stockBr(
          metadata: const {
            'allocationClassId': 'class-stocks',
            'allocationTargetPercent': '12.5',
            'fiRate': '110',
          },
        ),
      );

      final decoded = roundTrip(model);

      expect(decoded.metadata, model.metadata);
    });

    test('keeps institutionId null when the asset is unlinked', () {
      final model = AssetModel.fromEntity(
        AssetFactory.stockBr(institutionId: null),
      );

      final json = model.toJson();

      // Omitted rather than written as an explicit null, so a legacy unlinked
      // asset does not gain the key on rewrite.
      expect(json.containsKey('institutionId'), isFalse);
      expect(roundTrip(model).institutionId, isNull);
    });
  });

  group('enum fallbacks', () {
    // These moved to `enumByName` (lib/core/utils/enum_parse.dart), which
    // degrades instead of throwing: one hand-edited or renamed stored value
    // must not crash the whole assets screen.
    test('unknown kind falls back to AssetKind.cash', () {
      final model = AssetModel.fromMap(
        id: 'a-1',
        data: rawAsset(kind: 'debentureBr'),
      );

      expect(model.kind, AssetKind.cash);
    });

    test('unknown market falls back to Market.global', () {
      final model = AssetModel.fromMap(
        id: 'a-1',
        data: rawAsset(market: 'lse'),
      );

      expect(model.market, Market.global);
    });

    test('unknown currency falls back to Currency.brl', () {
      final model = AssetModel.fromMap(
        id: 'a-1',
        data: rawAsset(currency: 'gbp'),
      );

      expect(model.currency, Currency.brl);
    });

    test('missing and non-string enum cells fall back too', () {
      final model = AssetModel.fromMap(
        id: 'a-1',
        data: rawAsset(kind: null, market: 7, currency: null),
      );

      expect(model.kind, AssetKind.cash);
      expect(model.market, Market.global);
      expect(model.currency, Currency.brl);
    });

    test('every AssetKind still deserializes, not just selectable ones', () {
      // The form only offers `selectableKinds`, but existing rows carry the
      // retired kinds — they must keep round-tripping.
      for (final kind in AssetKind.values) {
        final decoded = AssetModel.fromMap(
          id: 'a-1',
          data: rawAsset(kind: kind.name),
        );
        expect(decoded.kind, kind, reason: 'kind ${kind.name}');
      }
    });
  });

  group('createdAt', () {
    test('reads an ISO string as well as a Timestamp', () {
      final model = AssetModel.fromMap(
        id: 'a-1',
        data: {...rawAsset(), 'createdAt': '2024-03-05T00:00:00.000'},
      );

      expect(model.createdAt, DateTime(2024, 3, 5));
    });
  });
}
