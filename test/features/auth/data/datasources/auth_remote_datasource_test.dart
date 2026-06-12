import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockGoogleSignIn googleSignIn;
  late FirebaseFirestore firestore;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    googleSignIn = MockGoogleSignIn();
    firestore = FakeFirebaseFirestore();
    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth,
      firestore: firestore,
      googleSignIn: googleSignIn,
    );
  });

  group('signOut', () {
    test('signs out from both Google and Firebase Auth', () async {
      when(() => googleSignIn.signOut()).thenAnswer((_) async {});
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(() => googleSignIn.signOut()).called(1);
      verify(() => firebaseAuth.signOut()).called(1);
    });

    // Regression: on Web, GoogleSignIn.initialize() is intentionally skipped
    // (DI/init), so calling googleSignIn.signOut() throws StateError — an
    // Error, not an Exception. Previously the inner `on Exception` clause did
    // not catch it and the failure bubbled up, leaving the bloc handler with
    // no emitted state and the UI stuck on the profile page.
    test(
      'still calls Firebase signOut when GoogleSignIn throws StateError',
      () async {
        when(() => googleSignIn.signOut()).thenThrow(
          StateError('GoogleSignIn must be initialized before use.'),
        );
        when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

        await dataSource.signOut();

        verify(() => firebaseAuth.signOut()).called(1);
      },
    );

    test(
      'still calls Firebase signOut when GoogleSignIn throws Exception',
      () async {
        when(
          () => googleSignIn.signOut(),
        ).thenThrow(Exception('Google sign-out failed'));
        when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

        await dataSource.signOut();

        verify(() => firebaseAuth.signOut()).called(1);
      },
    );

    test('throws AuthException when Firebase signOut fails', () async {
      when(() => googleSignIn.signOut()).thenAnswer((_) async {});
      when(
        () => firebaseAuth.signOut(),
      ).thenThrow(Exception('Firebase unreachable'));

      expect(dataSource.signOut(), throwsA(isA<AuthException>()));
    });
  });
}
