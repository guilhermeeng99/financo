import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/institutions_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/investing_factories.dart';

void main() {
  late AppDatabase db;
  late InstitutionsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.institutionsDao;
  });

  tearDown(() => db.close());

  group('upsertInstitution + getInstitutions', () {
    test('round-trips an institution exactly', () async {
      final avenue = InstitutionFactory.avenue();

      await dao.upsertInstitution(avenue);

      expect((await dao.getInstitutions(userId)).single, avenue);
    });

    test('round-trips the F8 display hints', () async {
      await dao.upsertInstitution(
        InstitutionFactory.nubank().copyWith(bank: 'nubank', color: 0xFF8A05BE),
      );

      final read = (await dao.getInstitutions(userId)).single;
      expect(read.bank, 'nubank');
      expect(read.color, 0xFF8A05BE);
    });

    test('leaves the optional display hints null when unset', () async {
      await dao.upsertInstitution(InstitutionFactory.nubank());

      final read = (await dao.getInstitutions(userId)).single;
      expect(read.bank, isNull);
      expect(read.color, isNull);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertInstitution(InstitutionFactory.nubank());
      await dao.upsertInstitution(
        InstitutionFactory.nubank(name: 'Nu Invest'),
      );

      final all = await dao.getInstitutions(userId);
      expect(all, hasLength(1));
      expect(all.single.name, 'Nu Invest');
    });
  });

  group('getInstitutions', () {
    test('scopes to the user and orders by name', () async {
      await dao.insertAllInstitutions([
        InstitutionFactory.nubank(),
        InstitutionFactory.avenue(),
        InstitutionFactory.nubank(id: 'inst-foreign', userId: 'user-2'),
      ]);

      final institutions = await dao.getInstitutions(userId);

      expect(institutions.map((i) => i.name).toList(), ['Avenue', 'Nubank']);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getInstitutions(userId), isEmpty);
    });
  });

  group('insertAllInstitutions', () {
    test('writes the whole batch and is safe to replay', () async {
      final batch = [InstitutionFactory.nubank(), InstitutionFactory.avenue()];

      await dao.insertAllInstitutions(batch);
      await dao.insertAllInstitutions(batch);

      expect(await dao.getInstitutions(userId), hasLength(2));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllInstitutions([]);

      expect(await dao.getInstitutions(userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteInstitution removes one row only', () async {
      await dao.insertAllInstitutions([
        InstitutionFactory.nubank(),
        InstitutionFactory.avenue(),
      ]);

      await dao.deleteInstitution('inst-avenue');

      expect(
        (await dao.getInstitutions(userId)).map((i) => i.id).toList(),
        ['inst-nubank'],
      );
    });

    test('deleteAllInstitutions clears every user', () async {
      await dao.insertAllInstitutions([
        InstitutionFactory.nubank(),
        InstitutionFactory.avenue(id: 'inst-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllInstitutions();

      expect(await dao.getInstitutions(userId), isEmpty);
      expect(await dao.getInstitutions('user-2'), isEmpty);
    });
  });

  group('degraded rows', () {
    test('falls back instead of throwing on unknown enum names', () async {
      await db
          .into(db.localInstitutions)
          .insert(
            LocalInstitutionsCompanion.insert(
              id: 'inst-junk',
              userId: userId,
              name: 'Legacy',
              kind: 'neobank',
              currency: 'gbp',
              createdAt: DateTime(2024),
            ),
          );

      final read = (await dao.getInstitutions(userId)).single;
      expect(read.kind, InstitutionKind.other);
      expect(read.currency, Currency.brl);
    });
  });
}
