import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/master_panel/data/datasources/master_users_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late MasterUsersRemoteDataSourceImpl datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    when(() => functions.httpsCallable('deleteUserAsAdmin'))
        .thenReturn(callable);
    datasource = MasterUsersRemoteDataSourceImpl(
      firestore: firestore,
      functions: functions,
    );
  });

  group('listAllUsers', () {
    test('returns every user document, newest first', () async {
      await firestore.collection('users').doc('uid-old').set(
            UserFactory.model(
              id: 'uid-old',
              name: 'Old',
              createdAt: DateTime(2025),
            ).toJson(),
          );
      await firestore.collection('users').doc('uid-new').set(
            UserFactory.model(
              id: 'uid-new',
              name: 'New',
              createdAt: DateTime(2026),
            ).toJson(),
          );

      final users = await datasource.listAllUsers();

      expect(users.map((u) => u.id).toList(), ['uid-new', 'uid-old']);
      expect(users.first.name, 'New');
    });

    test('returns an empty list when no users exist', () async {
      expect(await datasource.listAllUsers(), isEmpty);
    });
  });

  group('deleteUserAsAdmin', () {
    test('invokes the callable with the target uid', () async {
      final result = MockHttpsCallableResult<dynamic>();
      when(() => callable.call<dynamic>(any<dynamic>()))
          .thenAnswer((_) async => result);

      await datasource.deleteUserAsAdmin('uid-target');

      final payload = verify(
        () => callable.call<dynamic>(captureAny<dynamic>()),
      ).captured.single as Map<String, dynamic>;
      expect(payload, {'targetUid': 'uid-target'});
    });

    test('maps permission-denied to AuthException', () async {
      final exception = MockFirebaseFunctionsException();
      when(() => exception.code).thenReturn('permission-denied');
      when(() => exception.message).thenReturn('Not the master.');
      when(() => callable.call<dynamic>(any<dynamic>())).thenThrow(exception);

      expect(
        () => datasource.deleteUserAsAdmin('uid-target'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'Not the master.'),
        ),
      );
    });

    test('maps unauthenticated to AuthException', () async {
      final exception = MockFirebaseFunctionsException();
      when(() => exception.code).thenReturn('unauthenticated');
      when(() => exception.message).thenReturn(null);
      when(() => callable.call<dynamic>(any<dynamic>())).thenThrow(exception);

      expect(
        () => datasource.deleteUserAsAdmin('uid-target'),
        throwsA(isA<AuthException>()),
      );
    });

    test('maps any other callable error to ServerException', () async {
      final exception = MockFirebaseFunctionsException();
      when(() => exception.code).thenReturn('internal');
      when(() => exception.message).thenReturn('boom');
      when(() => callable.call<dynamic>(any<dynamic>())).thenThrow(exception);

      expect(
        () => datasource.deleteUserAsAdmin('uid-target'),
        throwsA(
          isA<ServerException>().having((e) => e.message, 'message', 'boom'),
        ),
      );
    });

    test('maps non-Firebase exceptions to ServerException', () async {
      when(() => callable.call<dynamic>(any<dynamic>()))
          .thenThrow(Exception('socket closed'));

      expect(
        () => datasource.deleteUserAsAdmin('uid-target'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
