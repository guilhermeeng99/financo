import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/data/repositories/access_control_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../harness/mocks.dart';

void main() {
  late AccessControlRepositoryImpl repository;
  late MockAccessControlRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockAccessControlRemoteDataSource();
    repository = AccessControlRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('isEmailAllowed', () {
    test('returns Right(true) when remote says allowed', () async {
      when(
        () => mockRemote.isEmailAllowed(any()),
      ).thenAnswer((_) async => true);

      final result = await repository.isEmailAllowed('friend@example.com');

      expect(result, const Right<Failure, bool>(true));
    });

    test('returns ServerFailure when remote throws', () async {
      when(
        () => mockRemote.isEmailAllowed(any()),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.isEmailAllowed('friend@example.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('fails closed on an unexpected (non-Server) exception', () async {
      // Security gate: any unexpected error must DENY, never accidentally
      // allow. The generic `on Exception` branch maps to ServerFailure.
      when(
        () => mockRemote.isEmailAllowed(any()),
      ).thenThrow(Exception('network down'));

      final result = await repository.isEmailAllowed('friend@example.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left — gate must fail closed'),
      );
    });
  });

  group('addAllowedEmail', () {
    test('rejects invalid email format with InvalidEmailFormatFailure',
        () async {
      final result = await repository.addAllowedEmail(email: 'not-an-email');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<InvalidEmailFormatFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(
        () => mockRemote.addAllowedEmail(
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      );
    });

    test('rejects master email with MasterEmailAlreadyAllowedFailure',
        () async {
      final result =
          await repository.addAllowedEmail(email: 'guilhermeeng99@gmail.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<MasterEmailAlreadyAllowedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('lowercases email before delegating to remote', () async {
      when(
        () => mockRemote.addAllowedEmail(
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.addAllowedEmail(
        email: '  Friend@Example.com',
        note: 'João',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => mockRemote.addAllowedEmail(
          email: 'friend@example.com',
          note: 'João',
        ),
      ).called(1);
    });
  });

  group('removeAllowedEmail', () {
    test('rejects master with AuthFailure', () async {
      final result =
          await repository.removeAllowedEmail('guilhermeeng99@gmail.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => mockRemote.removeAllowedEmail(any()));
    });

    test('lowercases before deleting', () async {
      when(
        () => mockRemote.removeAllowedEmail(any()),
      ).thenAnswer((_) async {});

      final result = await repository.removeAllowedEmail('Friend@Example.com');

      expect(result.isRight(), isTrue);
      verify(
        () => mockRemote.removeAllowedEmail('friend@example.com'),
      ).called(1);
    });
  });
}
