import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/models/institution_model.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  InstitutionModel roundTrip(InstitutionModel model) =>
      InstitutionModel.fromMap(id: model.id, data: model.toJson());

  Map<String, dynamic> rawInstitution({
    Object? kind = 'broker',
    Object? currency = 'brl',
  }) => {
    'userId': 'user-1',
    'name': 'XP',
    'kind': kind,
    'currency': currency,
    'createdAt': Timestamp.fromDate(DateTime(2024)),
  };

  group('round-trip', () {
    test('preserves every field of a USD international broker', () {
      final model = InstitutionModel.fromEntity(InstitutionFactory.avenue());

      expect(roundTrip(model), model);
    });

    test('preserves the F8 display hints', () {
      final model = InstitutionModel.fromEntity(
        InstitutionFactory.nubank().copyWith(
          bank: 'nubank',
          color: 0xFF8A05BE,
        ),
      );

      final decoded = roundTrip(model);

      expect(decoded.bank, 'nubank');
      expect(decoded.color, 0xFF8A05BE);
    });

    test('leaves the optional display hints null when unset', () {
      final model = InstitutionModel.fromEntity(InstitutionFactory.nubank());

      final decoded = roundTrip(model);

      expect(decoded.bank, isNull);
      expect(decoded.color, isNull);
    });

    test('reads a colour stored as a double back as an int', () {
      // Firestore numbers come back as `num`; an ARGB int written from web can
      // arrive as a double, and a raw `as int` cast would throw.
      final model = InstitutionModel.fromMap(
        id: 'inst-1',
        data: {...rawInstitution(), 'color': 4287245758.0},
      );

      expect(model.color, 4287245758);
    });
  });

  group('enum fallbacks', () {
    test('unknown kind falls back to InstitutionKind.other', () {
      final model = InstitutionModel.fromMap(
        id: 'inst-1',
        data: rawInstitution(kind: 'neobank'),
      );

      expect(model.kind, InstitutionKind.other);
    });

    test('unknown currency falls back to Currency.brl', () {
      final model = InstitutionModel.fromMap(
        id: 'inst-1',
        data: rawInstitution(currency: 'gbp'),
      );

      expect(model.currency, Currency.brl);
    });

    test('every InstitutionKind round-trips', () {
      for (final kind in InstitutionKind.values) {
        final decoded = InstitutionModel.fromMap(
          id: 'inst-1',
          data: rawInstitution(kind: kind.name),
        );
        expect(decoded.kind, kind, reason: 'kind ${kind.name}');
      }
    });
  });
}
