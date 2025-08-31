import 'package:app_database/app_database.dart' hide ITransactionUsecase;

import 'i_transaction_usecase.dart';

/// Implementation of TransactionUsecase using composition pattern with mixins
class TransactionUsecaseImpl
    with
        TransactionValidationHelpers,
        TransactionCrudUsecaseOperations,
        TransactionQueryUsecaseOperations,
        TransactionBalanceUsecaseOperations
    implements ITransactionUsecase {
  TransactionUsecaseImpl(this._repository);

  final ITransactionRepository _repository;

  @override
  ITransactionRepository get repository => _repository;
}
