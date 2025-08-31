import '../../../database/database_manager.dart';
import 'i_transaction_repository.dart';
import 'transaction_balance_operations.dart';
import 'transaction_crud_operations.dart';
import 'transaction_query_operations.dart';

/// Implementation of TransactionRepository using composition pattern with mixins
class TransactionRepositoryImpl
    with
        TransactionCrudOperations,
        TransactionBalanceOperations,
        TransactionQueryOperations
    implements ITransactionRepository {
  TransactionRepositoryImpl(this._database);

  final DatabaseManager _database;

  @override
  DatabaseManager get database => _database;
}
