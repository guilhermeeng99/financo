import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';

class CreateAccountUseCase {
  const CreateAccountUseCase(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, AccountEntity>> call(AccountEntity account) =>
      _repository.createAccount(account);
}
