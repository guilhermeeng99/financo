import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CreateAccountUseCase useCase;
  late MockAccountRepository mockRepository;

  setUpAll(registerAccountFallbackValues);

  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = CreateAccountUseCase(mockRepository);
  });

  group('CreateAccountUseCase', () {
    test('should delegate to repository.createAccount', () async {
      final account = AccountFactory.checking();
      when(
        () => mockRepository.createAccount(any()),
      ).thenAnswer((_) async => Right(account));

      final result = await useCase(account);

      expect(result, Right<Failure, AccountEntity>(account));
      verify(() => mockRepository.createAccount(account)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.createAccount(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Create failed')),
      );

      final result = await useCase(AccountFactory.checking());

      expect(result, isA<Left<Failure, AccountEntity>>());
    });
  });
}
