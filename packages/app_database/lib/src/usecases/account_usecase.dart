import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

class AccountUsecase {
  AccountUsecase(this._accountRepository);

  final IAccountRepository _accountRepository;

  Future<Either<Failure, AccountData>> createAccount({
    required String name,
    required AccountType accountType,
    double initialBalance = 0.0,
    String currency = 'BRL',
  }) async {
    try {
      final accountName = AccountName.create(name);
      final accountCurrency = Currency.create(currency);
      final balance = Balance.create(initialBalance);

      final accountCompanion = AccountsCompanion(
        name: Value(accountName.value),
        accountType: Value(accountType),
        balance: Value(balance.value),
        currency: Value(accountCurrency.value),
        isActive: const Value(true),
      );

      return await _accountRepository.createAccount(accountCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(DatabaseFailure('Erro inesperado ao criar conta: $e'));
    }
  }

  Future<Either<Failure, List<AccountData>>> getAllAccounts() async {
    return _accountRepository.getAllAccounts();
  }
}
