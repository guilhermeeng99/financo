// `show Value` only — drift's query builder exports matcher-shadowing names.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/user_factory.dart';

void main() {
  late AppDatabase db;
  late UsersDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.usersDao;
  });

  tearDown(() => db.close());

  group('upsertUser + getUser', () {
    test('round-trips a user without custom targets', () async {
      final user = UserFactory.entity(photoUrl: 'https://example.com/a.png');

      await dao.upsertUser(user);

      expect(await dao.getUser(user.id), user);
    });

    test('round-trips a customised 50/30/20 split', () async {
      final user = UserFactory.entity().copyWith(
        fiftyThirtyTwentyTargets: const FiftyThirtyTwentyTargets(
          needs: 60,
          wants: 20,
          savings: 20,
        ),
      );

      await dao.upsertUser(user);

      final read = await dao.getUser(user.id);
      expect(read!.fiftyThirtyTwentyTargets!.needs, 60);
      expect(read.fiftyThirtyTwentyTargets!.wants, 20);
      expect(read.fiftyThirtyTwentyTargets!.savings, 20);
    });

    test('leaves the targets null when never customised', () async {
      // Null means "use the classic default", which is a different state from
      // a user who deliberately picked 50/30/20.
      await dao.upsertUser(UserFactory.entity());

      expect((await dao.getUser('user-1'))!.fiftyThirtyTwentyTargets, isNull);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertUser(UserFactory.entity());
      await dao.upsertUser(UserFactory.entity(name: 'Renamed'));

      expect((await dao.getUser('user-1'))!.name, 'Renamed');
    });

    test('returns null for an unknown id', () async {
      expect(await dao.getUser('nope'), isNull);
    });
  });

  test('fills a partially-written target row from the classic split', () async {
    // A row with only some components set would otherwise build an invalid
    // object whose parts do not sum to 100.
    await db
        .into(db.localUsers)
        .insert(
          LocalUsersCompanion.insert(
            id: 'user-partial',
            name: 'Partial',
            email: 'partial@example.com',
            createdAt: DateTime(2024),
            fiftyThirtyTwentyNeeds: const Value(70),
          ),
        );

    final read = await dao.getUser('user-partial');
    expect(read!.fiftyThirtyTwentyTargets!.needs, 70);
    expect(
      read.fiftyThirtyTwentyTargets!.wants,
      FiftyThirtyTwentyTargets.classic.wants,
    );
    expect(
      read.fiftyThirtyTwentyTargets!.savings,
      FiftyThirtyTwentyTargets.classic.savings,
    );
  });

  test('deleteAllUsers clears the table', () async {
    await dao.upsertUser(UserFactory.entity());
    await dao.upsertUser(UserFactory.entity(id: 'user-2'));

    await dao.deleteAllUsers();

    expect(await dao.getUser('user-1'), isNull);
    expect(await dao.getUser('user-2'), isNull);
  });
}
