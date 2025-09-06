import 'package:app_database/app_database.dart' hide ITransactionUsecase;

import 'i_transaction_usecase.dart';

class TransactionUsecaseImpl
    with
        TransactionCrudUsecaseOperations,
        TransactionQueryUsecaseOperations,
        TransactionBalanceUsecaseOperations
    implements ITransactionUsecase {
  TransactionUsecaseImpl(this._repository);

  final ITransactionRepository _repository;

  @override
  ITransactionRepository get transactionRepository => _repository;
}
