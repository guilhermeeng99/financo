import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_targets_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockProfileRepository repo;
  late GetFiftyThirtyTwentyTargetsUseCase useCase;

  setUp(() {
    repo = MockProfileRepository();
    useCase = GetFiftyThirtyTwentyTargetsUseCase(repo);
  });

  UserEntity buildUser({FiftyThirtyTwentyTargets? targets}) => UserEntity(
    id: 'user-1',
    name: 'Test',
    email: 't@e.com',
    createdAt: DateTime(2024),
    fiftyThirtyTwentyTargets: targets,
  );

  test('returns user-configured targets when present', () async {
    const custom = FiftyThirtyTwentyTargets(
      needs: 0.6,
      wants: 0.2,
      savings: 0.2,
    );
    when(() => repo.getProfile(any())).thenAnswer(
      (_) async => Right<Failure, UserEntity>(buildUser(targets: custom)),
    );

    final result = await useCase('user-1');

    expect(
      result,
      equals(const Right<Failure, FiftyThirtyTwentyTargets>(custom)),
    );
  });

  test('falls back to classic when user has no custom targets', () async {
    when(() => repo.getProfile(any())).thenAnswer(
      (_) async => Right<Failure, UserEntity>(buildUser()),
    );

    final result = await useCase('user-1');

    expect(
      result,
      equals(
        const Right<Failure, FiftyThirtyTwentyTargets>(
          FiftyThirtyTwentyTargets.classic,
        ),
      ),
    );
  });

  test('propagates failure from profile repo', () async {
    when(() => repo.getProfile(any())).thenAnswer(
      (_) async => const Left<Failure, UserEntity>(ServerFailure()),
    );

    final result = await useCase('user-1');

    expect(result, isA<Left<Failure, FiftyThirtyTwentyTargets>>());
  });
}
