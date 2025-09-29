import '../../../../core/either.dart';
import '../../../../core/failures.dart';
import '../../repository/i_account_repository.dart';

mixin AccountDeletionOperations {
  IAccountRepository get accountRepository;

  Future<Either<Failure, bool>> deleteAccount(int id) async {
    try {
      return await accountRepository.deleteAccount(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting account: $e'),
      );
    }
  }
}
