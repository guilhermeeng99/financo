import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:mocktail/mocktail.dart';

// ── Repositories ──
class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

// ── Data Sources ──
class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

class MockAccountRemoteDataSource extends Mock
    implements AccountRemoteDataSource {}

class MockTransactionRemoteDataSource extends Mock
    implements TransactionRemoteDataSource {}

// ── DAOs ──
class MockCategoriesDao extends Mock implements CategoriesDao {}

class MockAccountsDao extends Mock implements AccountsDao {}

class MockTransactionsDao extends Mock implements TransactionsDao {}

// ── Use Cases: Categories ──
class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockCreateCategoryUseCase extends Mock implements CreateCategoryUseCase {}

class MockUpdateCategoryUseCase extends Mock implements UpdateCategoryUseCase {}

class MockDeleteCategoryUseCase extends Mock implements DeleteCategoryUseCase {}

// ── Use Cases: Accounts ──
class MockGetAccountsUseCase extends Mock implements GetAccountsUseCase {}

class MockCreateAccountUseCase extends Mock implements CreateAccountUseCase {}

class MockUpdateAccountUseCase extends Mock implements UpdateAccountUseCase {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

// ── Use Cases: Transactions ──
class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

class MockCreateTransactionUseCase extends Mock
    implements CreateTransactionUseCase {}

class MockUpdateTransactionUseCase extends Mock
    implements UpdateTransactionUseCase {}

class MockDeleteTransactionUseCase extends Mock
    implements DeleteTransactionUseCase {}

class MockCreateTransferUseCase extends Mock
    implements CreateTransferUseCase {}
