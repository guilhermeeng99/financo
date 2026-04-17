import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late GetAccountsUseCase useCase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = GetAccountsUseCase(mockRepository);
  });

  const userId = 'user-1';

  group('GetAccountsUseCase', () {
    test('should return accounts from repository', () async {
      final accounts = AccountFactory.list();
      when(
        () => mockRepository.getAccounts(userId: userId),
      ).thenAnswer((_) async => Right(accounts));

      final result = await useCase(userId: userId);

      expect(
        result,
        Right<Failure, List<AccountEntity>>(accounts),
      );
      verify(() => mockRepository.getAccounts(userId: userId)).called(1);
    });

    test('should pass forceRefresh to repository', () async {
      when(
        () => mockRepository.getAccounts(
          userId: userId,
          forceRefresh: true,
        ),
      ).thenAnswer((_) async => const Right([]));

      await useCase(userId: userId, forceRefresh: true);

      verify(
        () => mockRepository.getAccounts(userId: userId, forceRefresh: true),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.getAccounts(userId: userId),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(userId: userId);

      expect(result, isA<Left<Failure, List<AccountEntity>>>());
    });
  });
}
