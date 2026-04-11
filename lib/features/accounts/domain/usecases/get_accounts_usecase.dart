import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';

class GetAccountsUseCase {
  const GetAccountsUseCase(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, List<AccountEntity>>> call({
    required String userId,
    bool forceRefresh = false,
  }) => _repository.getAccounts(userId: userId, forceRefresh: forceRefresh);
}
