import '../../../database/database_manager.dart';
import 'account_crud_operations.dart';
import 'account_query_operations.dart';
import 'i_account_repository.dart';

class AccountRepositoryImpl extends IAccountRepository
    with AccountQueryOperations, AccountCrudOperations {
  AccountRepositoryImpl(this._database);

  final DatabaseManager _database;

  @override
  DatabaseManager get database => _database;
}
