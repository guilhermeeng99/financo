import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/usecases/update_fifty_thirty_twenty_targets_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockProfileRepository repo;
  late UpdateFiftyThirtyTwentyTargetsUseCase useCase;

  setUp(() {
    repo = MockProfileRepository();
    useCase = UpdateFiftyThirtyTwentyTargetsUseCase(repo);
  });

  final baseUser = UserEntity(
    id: 'user-1',
    name: 'Test',
    email: 't@e.com',
    createdAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(
      UserEntity(
        id: 'fallback',
        name: 'x',
        email: 'x',
        createdAt: DateTime(2024),
      ),
    );
  });

  test('rejects invalid targets before touching the repo', () async {
    const invalid = FiftyThirtyTwentyTargets(
      needs: 0.5,
      wants: 0.5,
      savings: 0.5,
    );

    final result = await useCase(userId: 'user-1', targets: invalid);

    expect(result, isA<Left<Failure, FiftyThirtyTwentyTargets>>());
    verifyNever(() => repo.getProfile(any()));
    verifyNever(() => repo.updateProfile(any()));
  });

  test('persists valid targets via getProfile + updateProfile', () async {
    const valid = FiftyThirtyTwentyTargets(
      needs: 0.6,
      wants: 0.3,
      savings: 0.1,
    );
    when(() => repo.getProfile(any())).thenAnswer(
      (_) async => Right<Failure, UserEntity>(baseUser),
    );
    when(() => repo.updateProfile(any())).thenAnswer(
      (invocation) async => Right<Failure, UserEntity>(
        invocation.positionalArguments.first as UserEntity,
      ),
    );

    final result = await useCase(userId: 'user-1', targets: valid);

    expect(result, const Right<Failure, FiftyThirtyTwentyTargets>(valid));
    final captured = verify(
      () => repo.updateProfile(captureAny()),
    ).captured.single as UserEntity;
    expect(captured.fiftyThirtyTwentyTargets, valid);
  });

  test('propagates failure if getProfile fails', () async {
    when(() => repo.getProfile(any())).thenAnswer(
      (_) async => const Left<Failure, UserEntity>(ServerFailure()),
    );

    final result = await useCase(
      userId: 'user-1',
      targets: FiftyThirtyTwentyTargets.classic,
    );

    expect(result, isA<Left<Failure, FiftyThirtyTwentyTargets>>());
    verifyNever(() => repo.updateProfile(any()));
  });
}
