import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/notifications/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMessaging extends Mock implements FirebaseMessaging {}

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockLocalNotifications extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  group('NotificationService.shouldDeliver', () {
    test('delivers when message uid matches current uid', () {
      expect(
        NotificationService.shouldDeliver(
          messageUserId: 'alice',
          currentUid: 'alice',
        ),
        isTrue,
      );
    });

    test('drops when message uid is a foreign account', () {
      // Concretely: this is the regression — Cloud Function pushed for
      // userId B, but the device is signed in as A. Must NOT display.
      expect(
        NotificationService.shouldDeliver(
          messageUserId: 'bob',
          currentUid: 'alice',
        ),
        isFalse,
      );
    });

    test('drops scoped message when no user is signed in', () {
      expect(
        NotificationService.shouldDeliver(
          messageUserId: 'alice',
          currentUid: null,
        ),
        isFalse,
      );
      expect(
        NotificationService.shouldDeliver(
          messageUserId: 'alice',
          currentUid: '',
        ),
        isFalse,
      );
    });

    test(
      'delivers unscoped messages regardless of sign-in state '
      '(backwards-compat for un-targeted pushes)',
      () {
        expect(
          NotificationService.shouldDeliver(
            messageUserId: null,
            currentUid: 'alice',
          ),
          isTrue,
        );
        expect(
          NotificationService.shouldDeliver(
            messageUserId: '',
            currentUid: null,
          ),
          isTrue,
        );
      },
    );
  });

  group('NotificationService.removeTokenOnSignOut', () {
    late _MockMessaging messaging;
    late FakeFirebaseFirestore firestore;
    late _MockAuth auth;
    late _MockLocalNotifications local;
    late NotificationService service;

    setUp(() {
      messaging = _MockMessaging();
      firestore = FakeFirebaseFirestore();
      auth = _MockAuth();
      local = _MockLocalNotifications();
      service = NotificationService(
        messaging: messaging,
        firestore: firestore,
        auth: auth,
        localNotifications: local,
      );
    });

    Future<void> seedToken(String userId, String token) async {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .set({'token': token, 'platform': 'android'});
    }

    test(
      'fetches the current FCM token from the plugin and deletes its doc',
      () async {
        // Reason this is the hardened behavior: the older implementation
        // kept the token in an in-memory field that was null after an
        // app restart between sign-in and sign-out — so the orphan-token
        // bug surfaced precisely when removeTokenOnSignOut was needed.
        await seedToken('uid-1', 'tok-123');
        when(() => messaging.getToken()).thenAnswer((_) async => 'tok-123');

        await service.removeTokenOnSignOut('uid-1');

        verify(() => messaging.getToken()).called(1);
        final remaining = await firestore
            .collection('users')
            .doc('uid-1')
            .collection('fcmTokens')
            .get();
        expect(remaining.docs, isEmpty);
      },
    );

    test('does not touch other users while deleting the current token',
        () async {
      // The cross-account isolation case: both A (current) and B (test
      // account) have the same physical token registered. Sign-out on A
      // must only delete A's copy.
      await seedToken('uid-A', 'tok-shared');
      await seedToken('uid-B', 'tok-shared');
      when(() => messaging.getToken()).thenAnswer((_) async => 'tok-shared');

      await service.removeTokenOnSignOut('uid-A');

      final a = await firestore
          .collection('users')
          .doc('uid-A')
          .collection('fcmTokens')
          .get();
      final b = await firestore
          .collection('users')
          .doc('uid-B')
          .collection('fcmTokens')
          .get();
      expect(a.docs, isEmpty);
      expect(b.docs, hasLength(1));
    });

    test('no-op when getToken returns null', () async {
      await seedToken('uid-1', 'tok-123');
      when(() => messaging.getToken()).thenAnswer((_) async => null);

      await service.removeTokenOnSignOut('uid-1');

      final remaining = await firestore
          .collection('users')
          .doc('uid-1')
          .collection('fcmTokens')
          .get();
      expect(remaining.docs, hasLength(1));
    });

    test('no-op when userId is empty', () async {
      await service.removeTokenOnSignOut('');
      verifyNever(() => messaging.getToken());
    });
  });
}
