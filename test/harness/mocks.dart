import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:financo/core/database/daos/asset_holdings_dao.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/sync/sync_service.dart';
import 'package:financo/features/access_control/data/datasources/access_control_remote_datasource.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';
import 'package:financo/features/access_control/domain/usecases/add_allowed_email_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/is_email_allowed_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/list_allowed_emails_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/remove_allowed_email_usecase.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financo/features/auth/domain/repositories/auth_repository.dart';
import 'package:financo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:financo/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_overview_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/import_budgets_csv_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/chat/data/datasources/chat_datasources.dart';
import 'package:financo/features/chat/domain/action_handlers/account_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/budget_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/category_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transaction_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transfer_chat_action_handler.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
import 'package:financo/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_targets_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/update_fifty_thirty_twenty_targets_usecase.dart';
import 'package:financo/features/investments/data/datasources/asset_class_remote_datasource.dart';
import 'package:financo/features/investments/data/datasources/asset_holding_remote_datasource.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_class_usecase.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_holding_usecase.dart';
import 'package:financo/features/investments/domain/usecases/delete_asset_class_usecase.dart';
import 'package:financo/features/investments/domain/usecases/delete_asset_holding_usecase.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_holdings_usecase.dart';
import 'package:financo/features/investments/domain/usecases/get_investment_overview_usecase.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_class_usecase.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_holding_usecase.dart';
import 'package:financo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';
import 'package:financo/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_sequence_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/ensure_fixed_recurrences_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_sequence_usecase.dart';
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

class MockImportCategoriesCsvUseCase extends Mock
    implements ImportCategoriesCsvUseCase {}

// ── Use Cases: Accounts ──
class MockGetAccountsUseCase extends Mock implements GetAccountsUseCase {}

class MockCreateAccountUseCase extends Mock implements CreateAccountUseCase {}

class MockUpdateAccountUseCase extends Mock implements UpdateAccountUseCase {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class MockImportAccountsCsvUseCase extends Mock
    implements ImportAccountsCsvUseCase {}

// ── Budgets ──
class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockBudgetRemoteDataSource extends Mock
    implements BudgetRemoteDataSource {}

class MockBudgetsDao extends Mock implements BudgetsDao {}

class MockGetBudgetsUseCase extends Mock implements GetBudgetsUseCase {}

class MockCreateBudgetUseCase extends Mock implements CreateBudgetUseCase {}

class MockUpdateBudgetUseCase extends Mock implements UpdateBudgetUseCase {}

class MockDeleteBudgetUseCase extends Mock implements DeleteBudgetUseCase {}

class MockGetBudgetsOverviewUseCase extends Mock
    implements GetBudgetsOverviewUseCase {}

class MockImportBudgetsCsvUseCase extends Mock
    implements ImportBudgetsCsvUseCase {}

// ── Use Cases: Transactions ──
class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

class MockGetTransactionUseCase extends Mock implements GetTransactionUseCase {}

class MockCreateTransactionUseCase extends Mock
    implements CreateTransactionUseCase {}

class MockCreateTransactionsUseCase extends Mock
    implements CreateTransactionsUseCase {}

class MockUpdateTransactionUseCase extends Mock
    implements UpdateTransactionUseCase {}

class MockUpdateTransactionSequenceUseCase extends Mock
    implements UpdateTransactionSequenceUseCase {}

class MockDeleteTransactionUseCase extends Mock
    implements DeleteTransactionUseCase {}

class MockDeleteTransactionSequenceUseCase extends Mock
    implements DeleteTransactionSequenceUseCase {}

class MockCreateTransferUseCase extends Mock implements CreateTransferUseCase {}

class MockEnsureFixedRecurrencesUseCase extends Mock
    implements EnsureFixedRecurrencesUseCase {}

class MockImportTransactionsCsvUseCase extends Mock
    implements ImportTransactionsCsvUseCase {}

// ── Repositories: Auth ──
class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

// ── Data Sources: Auth ──
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

// ── DAOs: Users ──
class MockUsersDao extends Mock implements UsersDao {}

// ── Services ──
class MockSyncService extends Mock implements SyncService {}

// ── Use Cases: Auth ──
class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

// ── Repositories / Data Sources: Access Control ──
class MockAccessControlRepository extends Mock
    implements AccessControlRepository {}

class MockAccessControlRemoteDataSource extends Mock
    implements AccessControlRemoteDataSource {}

// ── Use Cases: Access Control ──
class MockIsEmailAllowedUseCase extends Mock implements IsEmailAllowedUseCase {}

class MockListAllowedEmailsUseCase extends Mock
    implements ListAllowedEmailsUseCase {}

class MockAddAllowedEmailUseCase extends Mock
    implements AddAllowedEmailUseCase {}

class MockRemoveAllowedEmailUseCase extends Mock
    implements RemoveAllowedEmailUseCase {}

// ── Use Cases: Profile ──
class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

// ── Repositories: Chat ──
class MockChatRepository extends Mock implements ChatRepository {}

// ── Data Sources: Chat ──
class MockChatBackendDataSource extends Mock implements ChatBackendDataSource {}

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

// ── Use Cases: Chat ──
class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

class MockGetChatHistoryUseCase extends Mock implements GetChatHistoryUseCase {}

class MockSaveChatMessageUseCase extends Mock
    implements SaveChatMessageUseCase {}

class MockTranscribeAudioUseCase extends Mock
    implements TranscribeAudioUseCase {}

// ── Chat Action Handlers ──
// Concrete classes (not the abstract `ChatActionHandler`) so blocs can
// receive them by their narrow type — matches the DI registration.
class MockAccountChatActionHandler extends Mock
    implements AccountChatActionHandler {}

class MockCategoryChatActionHandler extends Mock
    implements CategoryChatActionHandler {}

class MockTransactionChatActionHandler extends Mock
    implements TransactionChatActionHandler {}

class MockTransferChatActionHandler extends Mock
    implements TransferChatActionHandler {}

class MockBudgetChatActionHandler extends Mock
    implements BudgetChatActionHandler {}

// ── Data Sources: Profile ──
class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

// ── Local Database ──
class MockAppDatabase extends Mock implements AppDatabase {}

// ── Repositories: Dashboard ──
class MockDashboardRepository extends Mock implements DashboardRepository {}

// ── Use Cases: Dashboard ──
class MockGetDashboardSummaryUseCase extends Mock
    implements GetDashboardSummaryUseCase {}

class MockGetFiftyThirtyTwentyTargetsUseCase extends Mock
    implements GetFiftyThirtyTwentyTargetsUseCase {}

class MockUpdateFiftyThirtyTwentyTargetsUseCase extends Mock
    implements UpdateFiftyThirtyTwentyTargetsUseCase {}

// ── Investments ──
class MockAssetClassRepository extends Mock implements AssetClassRepository {}

class MockAssetHoldingRepository extends Mock
    implements AssetHoldingRepository {}

class MockAssetClassRemoteDataSource extends Mock
    implements AssetClassRemoteDataSource {}

class MockAssetHoldingRemoteDataSource extends Mock
    implements AssetHoldingRemoteDataSource {}

class MockAssetClassesDao extends Mock implements AssetClassesDao {}

class MockAssetHoldingsDao extends Mock implements AssetHoldingsDao {}

class MockGetAssetClassesUseCase extends Mock
    implements GetAssetClassesUseCase {}

class MockCreateAssetClassUseCase extends Mock
    implements CreateAssetClassUseCase {}

class MockUpdateAssetClassUseCase extends Mock
    implements UpdateAssetClassUseCase {}

class MockDeleteAssetClassUseCase extends Mock
    implements DeleteAssetClassUseCase {}

class MockGetAssetHoldingsUseCase extends Mock
    implements GetAssetHoldingsUseCase {}

class MockCreateAssetHoldingUseCase extends Mock
    implements CreateAssetHoldingUseCase {}

class MockUpdateAssetHoldingUseCase extends Mock
    implements UpdateAssetHoldingUseCase {}

class MockDeleteAssetHoldingUseCase extends Mock
    implements DeleteAssetHoldingUseCase {}

class MockGetInvestmentOverviewUseCase extends Mock
    implements GetInvestmentOverviewUseCase {}
