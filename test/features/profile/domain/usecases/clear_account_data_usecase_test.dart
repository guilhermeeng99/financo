import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/profile/domain/usecases/clear_account_data_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockProfileRepository mockRepository;
  late ClearAccountDataUseCase useCase;

  const userId = 'user-1';

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = ClearAccountDataUseCase(repository: mockRepository);
  });

  test('delegates to repository.clearAccountData', () async {
    when(() => mockRepository.clearAccountData(userId)).thenAnswer(
      (_) async => const Right<Failure, void>(null),
    );

    final result = await useCase(userId);

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.clearAccountData(userId)).called(1);
  });

  test('forwards failure from repository', () async {
    const failure = ServerFailure('boom');
    when(() => mockRepository.clearAccountData(userId)).thenAnswer(
      (_) async => const Left<Failure, void>(failure),
    );

    final result = await useCase(userId);

    expect(result, const Left<Failure, void>(failure));
  });
}
