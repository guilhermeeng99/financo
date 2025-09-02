import '../../transaction/repository/i_transaction_repository.dart';
import '../repository/i_account_repository.dart';
import 'account_balance_usecase_operations.dart';
import 'account_crud_usecase_operations.dart';
import 'account_query_usecase_operations.dart';
import 'i_account_usecase.dart';

class AccountUsecaseImpl extends IAccountUsecase
    with
        AccountCrudUsecaseOperations,
        AccountQueryUsecaseOperations,
        AccountBalanceUsecaseOperations {
  AccountUsecaseImpl(this._accountRepository, this._transactionRepository);

  final IAccountRepository _accountRepository;
  final ITransactionRepository _transactionRepository;

  @override
  IAccountRepository get accountRepository => _accountRepository;

  @override
  ITransactionRepository get transactionRepository => _transactionRepository;
}
