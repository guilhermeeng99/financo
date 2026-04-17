import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late UpdateAccountUseCase useCase;
  late MockAccountRepository mockRepository;

  setUpAll(registerAccountFallbackValues);

  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = UpdateAccountUseCase(mockRepository);
  });

  group('UpdateAccountUseCase', () {
    test('should delegate to repository.updateAccount', () async {
      final account = AccountFactory.checking(name: 'Updated');
      when(
        () => mockRepository.updateAccount(any()),
      ).thenAnswer((_) async => Right(account));

      final result = await useCase(account);

      expect(result, Right<Failure, AccountEntity>(account));
      verify(() => mockRepository.updateAccount(account)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.updateAccount(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Update failed')),
      );

      final result = await useCase(AccountFactory.checking());

      expect(result, isA<Left<Failure, AccountEntity>>());
    });
  });
}
