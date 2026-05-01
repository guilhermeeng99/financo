import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/profile/domain/usecases/clear_account_data_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockAppDatabase database;
  late ClearAccountDataUseCase useCase;

  const userId = 'user-1';
  const otherUserId = 'user-2';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    database = _MockAppDatabase();
    when(database.clearAllTables).thenAnswer((_) async {});
    useCase = ClearAccountDataUseCase(
      firestore: firestore,
      database: database,
    );
  });

  Future<void> seed(String collection, String ownerId, {int count = 1}) async {
    for (var i = 0; i < count; i++) {
      await firestore.collection(collection).add({'userId': ownerId});
    }
  }

  Future<int> count(String collection, String ownerId) async {
    final snap = await firestore
        .collection(collection)
        .where('userId', isEqualTo: ownerId)
        .get();
    return snap.docs.length;
  }

  group('ClearAccountDataUseCase', () {
    test('deletes bills along with the other user-scoped collections',
        () async {
      await seed('bills', userId, count: 2);
      await seed('transactions', userId);
      await seed('chat_messages', userId);
      await seed('categories', userId);
      await seed('accounts', userId);

      final result = await useCase(userId);

      expect(result.isRight(), true);
      expect(await count('bills', userId), 0);
      expect(await count('transactions', userId), 0);
      expect(await count('chat_messages', userId), 0);
      expect(await count('categories', userId), 0);
      expect(await count('accounts', userId), 0);
      verify(database.clearAllTables).called(1);
    });

    test('does not touch documents owned by other users', () async {
      await seed('bills', userId);
      await seed('bills', otherUserId, count: 3);

      final result = await useCase(userId);

      expect(result.isRight(), true);
      expect(await count('bills', userId), 0);
      expect(await count('bills', otherUserId), 3);
    });

    test('returns ServerFailure when clearAllTables throws', () async {
      when(database.clearAllTables).thenThrow(Exception('drift down'));

      final result = await useCase(userId);

      expect(
        result.fold((l) => l, (_) => null),
        isA<ServerFailure>(),
      );
    });
  });
}
