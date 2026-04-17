import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late DeleteAccountUseCase useCase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = DeleteAccountUseCase(mockRepository);
  });

  group('DeleteAccountUseCase', () {
    const accountId = 'acc-1';

    test('should delegate to repository.deleteAccount', () async {
      when(
        () => mockRepository.deleteAccount(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(accountId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.deleteAccount(accountId)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.deleteAccount(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Delete failed')),
      );

      final result = await useCase(accountId);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
