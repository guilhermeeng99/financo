import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('guardServer', () {
    test('wraps the body result in Right', () async {
      final result = await guardServer(() async => 42);
      expect(result, const Right<Failure, int>(42));
    });

    test('maps ServerException to Left(ServerFailure) with its message',
        () async {
      final result = await guardServer<int>(
        () async => throw const ServerException('boom'),
      );
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'boom');
        },
        (_) => fail('expected a failure'),
      );
    });

    test('does not catch non-ServerException errors', () {
      expect(
        () => guardServer<int>(() async => throw StateError('nope')),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('guardServerVoid', () {
    test('returns Right(null) on success', () async {
      final result = await guardServerVoid(() async {});
      expect(result.isRight(), isTrue);
    });

    test('maps ServerException to Left(ServerFailure)', () async {
      final result = await guardServerVoid(
        () async => throw const ServerException('x'),
      );
      expect(result.isLeft(), isTrue);
    });
  });
}
