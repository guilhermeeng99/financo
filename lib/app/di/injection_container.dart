import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:financo/app/i18n/app_locale_cubit.dart';
import 'package:financo/app/theme/dark_palette_cubit.dart';
import 'package:financo/app/theme/light_palette_cubit.dart';
import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/core/app_info/app_info_service.dart';
import 'package:financo/core/app_info/app_info_service_impl.dart';
import 'package:financo/core/app_info/app_version.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:financo/core/database/daos/asset_holdings_dao.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/notifications/notification_service.dart';
import 'package:financo/core/sync/sync_service.dart';
// Access Control
import 'package:financo/features/access_control/data/datasources/access_control_remote_datasource.dart';
import 'package:financo/features/access_control/data/repositories/access_control_repository_impl.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';
import 'package:financo/features/access_control/domain/usecases/add_allowed_email_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/is_email_allowed_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/list_allowed_emails_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/remove_allowed_email_usecase.dart';
// Accounts
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_with_dependents_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
// Auth
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:financo/features/auth/domain/repositories/auth_repository.dart';
import 'package:financo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
// Budgets
import 'package:financo/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:financo/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_overview_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/import_budgets_csv_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
// Categories
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/data/repositories/category_repository_impl.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_with_reassignment_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
// Chat
import 'package:financo/features/chat/data/datasources/chat_datasources.dart';
import 'package:financo/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:financo/features/chat/data/services/chat_audio_recorder_impl.dart';
import 'package:financo/features/chat/domain/action_handlers/account_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/budget_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/category_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transaction_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transfer_chat_action_handler.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';
import 'package:financo/features/chat/domain/services/chat_audio_recorder.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
// Dashboard
import 'package:financo/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:financo/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_history_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_targets_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/update_fifty_thirty_twenty_targets_usecase.dart';
// Investments
import 'package:financo/features/investments/data/datasources/asset_class_remote_datasource.dart';
import 'package:financo/features/investments/data/datasources/asset_holding_remote_datasource.dart';
import 'package:financo/features/investments/data/repositories/asset_class_repository_impl.dart';
import 'package:financo/features/investments/data/repositories/asset_holding_repository_impl.dart';
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
// Master Panel
import 'package:financo/features/master_panel/data/datasources/master_users_remote_datasource.dart';
import 'package:financo/features/master_panel/data/repositories/master_users_repository_impl.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';
import 'package:financo/features/master_panel/domain/usecases/delete_user_as_admin_usecase.dart';
import 'package:financo/features/master_panel/domain/usecases/list_all_users_usecase.dart';
// Profile
import 'package:financo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:financo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';
import 'package:financo/features/profile/domain/usecases/clear_account_data_usecase.dart';
import 'package:financo/features/profile/domain/usecases/get_profile_usecase.dart';
// Startup
import 'package:financo/features/startup/presentation/cubit/startup_cubit.dart';
// Transactions
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/data/repositories/transaction_repository_impl.dart';
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
import 'package:financo/features/transactions/domain/usecases/settle_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_sequence_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Read package metadata once at startup so the rest of the app can
  // depend on a synchronous AppVersion singleton (used by the profile
  // footer to show the user which build they're on).
  final appInfo = AppInfoServiceImpl();
  final appVersion = await appInfo.getAppVersion();

  // Only initialize GoogleSignIn on mobile.
  // On web, Firebase Auth's signInWithPopup handles Google auth directly.
  // Calling GoogleSignIn.initialize() on web conflicts with Firebase's
  // internal Google Identity Services initialisation (GSI).
  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize();
  }

  sl
    // ─── External ────────────────────────────────────────────
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseFunctions.instance)
    ..registerLazySingleton(() => prefs)
    ..registerLazySingleton(() => GoogleSignIn.instance)
    // ─── App Info ───────────────────────────────────────────
    ..registerLazySingleton<AppInfoService>(() => appInfo)
    ..registerSingleton<AppVersion>(appVersion)
    // ─── Local Database ─────────────────────────────────────
    ..registerLazySingleton(AppDatabase.new)
    ..registerLazySingleton(() => UsersDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => AccountsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => TransactionsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => CategoriesDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => BudgetsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => AssetClassesDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => AssetHoldingsDao(sl<AppDatabase>()))
    // ─── Sync Service ───────────────────────────────────────
    ..registerLazySingleton(
      () => SyncService(
        accountRemote: sl(),
        transactionRemote: sl(),
        categoryRemote: sl(),
        budgetRemote: sl(),
        accountsDao: sl(),
        transactionsDao: sl(),
        categoriesDao: sl(),
        budgetsDao: sl(),
        usersDao: sl(),
        database: sl(),
      ),
    )
    // ─── Datasources ────────────────────────────────────────
    ..registerLazySingleton<AccessControlRemoteDataSource>(
      () => AccessControlRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<MasterUsersRemoteDataSource>(
      () => MasterUsersRemoteDataSourceImpl(
        firestore: sl(),
        functions: sl(),
      ),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: sl(),
        firestore: sl(),
        googleSignIn: sl(),
      ),
    )
    ..registerLazySingleton<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<BudgetRemoteDataSource>(
      () => BudgetRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<ChatBackendDataSource>(
      () => ChatBackendDataSourceImpl(functions: sl()),
    )
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<AssetClassRemoteDataSource>(
      () => AssetClassRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<AssetHoldingRemoteDataSource>(
      () => AssetHoldingRemoteDataSourceImpl(firestore: sl()),
    )
    // ─── Repositories ───────────────────────────────────────
    ..registerLazySingleton<AccessControlRepository>(
      () => AccessControlRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton<MasterUsersRepository>(
      () => MasterUsersRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        usersDao: sl(),
        syncService: sl(),
        accessControlRepository: sl(),
      ),
    )
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: sl(),
        transactionsDao: sl(),
      ),
    )
    ..registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: sl(),
        accountsDao: sl(),
      ),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        remoteDataSource: sl(),
        categoriesDao: sl(),
      ),
    )
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(
        remoteDataSource: sl(),
        budgetsDao: sl(),
      ),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        chatBackendDataSource: sl(),
        chatRemoteDataSource: sl(),
      ),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        transactionRepository: sl(),
        accountRepository: sl(),
        categoryRepository: sl(),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: sl(),
        usersDao: sl(),
        database: sl(),
      ),
    )
    ..registerLazySingleton<AssetClassRepository>(
      () => AssetClassRepositoryImpl(
        remoteDataSource: sl(),
        assetClassesDao: sl(),
      ),
    )
    ..registerLazySingleton<AssetHoldingRepository>(
      () => AssetHoldingRepositoryImpl(
        remoteDataSource: sl(),
        assetHoldingsDao: sl(),
        // The cascade-by-account flow does not pass userId; resolve
        // lazily through the AuthBloc state so the singleton works
        // whether or not a session is active.
        resolveUserId: () {
          final state = sl<AuthBloc>().state;
          return state is Authenticated ? state.user.id : '';
        },
      ),
    )
    // ─── Use Cases ──────────────────────────────────────────
    ..registerLazySingleton(() => IsEmailAllowedUseCase(sl()))
    ..registerLazySingleton(() => ListAllowedEmailsUseCase(sl()))
    ..registerLazySingleton(() => AddAllowedEmailUseCase(sl()))
    ..registerLazySingleton(() => RemoveAllowedEmailUseCase(sl()))
    ..registerLazySingleton(() => ListAllUsersUseCase(sl()))
    ..registerLazySingleton(() => DeleteUserAsAdminUseCase(sl()))
    ..registerLazySingleton(
      () => SignInWithGoogleUseCase(sl()),
    )
    ..registerLazySingleton(() => SignOutUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    ..registerLazySingleton(
      () => GetTransactionsUseCase(sl()),
    )
    ..registerLazySingleton(
      () => GetTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => CreateTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => CreateTransactionsUseCase(sl()),
    )
    ..registerLazySingleton(
      () => UpdateTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => UpdateTransactionSequenceUseCase(sl()),
    )
    ..registerLazySingleton(
      () => SettleTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteTransactionSequenceUseCase(sl()),
    )
    ..registerLazySingleton(
      () => EnsureFixedRecurrencesUseCase(sl()),
    )
    ..registerLazySingleton(
      () => CreateTransferUseCase(sl()),
    )
    ..registerLazySingleton(
      () => ImportTransactionsCsvUseCase(sl(), sl(), sl()),
    )
    ..registerLazySingleton(() => GetAccountsUseCase(sl()))
    ..registerLazySingleton(
      () => CreateAccountUseCase(sl()),
    )
    ..registerLazySingleton(
      () => UpdateAccountUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteAccountUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteAccountWithDependentsUseCase(
        transactionRepository: sl(),
        accountRepository: sl(),
        assetHoldingRepository: sl(),
      ),
    )
    ..registerLazySingleton(
      () => ImportAccountsCsvUseCase(sl()),
    )
    ..registerLazySingleton(
      () => GetCategoriesUseCase(sl()),
    )
    ..registerLazySingleton(
      () => CreateCategoryUseCase(sl()),
    )
    ..registerLazySingleton(
      () => UpdateCategoryUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteCategoryUseCase(sl()),
    )
    ..registerLazySingleton(
      () => ImportCategoriesCsvUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteCategoryWithReassignmentUseCase(
        transactionRepository: sl(),
        getBudgets: sl(),
        deleteBudget: sl(),
        deleteCategory: sl(),
      ),
    )
    ..registerLazySingleton(() => GetBudgetsUseCase(sl()))
    ..registerLazySingleton(() => CreateBudgetUseCase(sl()))
    ..registerLazySingleton(() => UpdateBudgetUseCase(sl()))
    ..registerLazySingleton(() => DeleteBudgetUseCase(sl()))
    ..registerLazySingleton(() => ImportBudgetsCsvUseCase(sl(), sl()))
    ..registerLazySingleton(
      () => GetBudgetsOverviewUseCase(
        budgetRepository: sl(),
        categoryRepository: sl(),
        transactionRepository: sl(),
      ),
    )
    ..registerLazySingleton(() => SendMessageUseCase(sl()))
    ..registerLazySingleton(
      () => GetChatHistoryUseCase(sl()),
    )
    ..registerLazySingleton(
      () => SaveChatMessageUseCase(sl()),
    )
    ..registerLazySingleton(
      () => TranscribeAudioUseCase(sl()),
    )
    // ─── Chat Action Handlers ───────────────────────────────
    ..registerLazySingleton(
      () => AccountChatActionHandler(
        createAccount: sl(),
        getAccounts: sl(),
        deleteAccount: sl(),
      ),
    )
    ..registerLazySingleton(
      () => CategoryChatActionHandler(
        createCategory: sl(),
        getCategories: sl(),
        deleteCategory: sl(),
      ),
    )
    ..registerLazySingleton(
      () => TransactionChatActionHandler(
        getAccounts: sl(),
        getCategories: sl(),
        createTransaction: sl(),
      ),
    )
    ..registerLazySingleton(
      () => TransferChatActionHandler(
        getAccounts: sl(),
        createTransfer: sl(),
      ),
    )
    ..registerLazySingleton(
      () => BudgetChatActionHandler(
        getCategories: sl(),
        getBudgets: sl(),
        createBudget: sl(),
        updateBudget: sl(),
        deleteBudget: sl(),
      ),
    )
    // ─── Chat Services ──────────────────────────────────────
    // Factory: each ChatInput mount gets its own recorder and disposes it
    // when unmounted — a singleton would be unusable after the first visit.
    ..registerFactory<ChatAudioRecorder>(ChatAudioRecorderImpl.new)
    ..registerLazySingleton(
      () => GetDashboardSummaryUseCase(sl()),
    )
    ..registerLazySingleton(
      () => GetFiftyThirtyTwentyTargetsUseCase(sl()),
    )
    ..registerLazySingleton(
      () => UpdateFiftyThirtyTwentyTargetsUseCase(sl()),
    )
    ..registerLazySingleton(
      () => GetFiftyThirtyTwentyHistoryUseCase(
        transactionRepository: sl(),
        accountRepository: sl(),
        categoryRepository: sl(),
      ),
    )
    ..registerLazySingleton(() => GetProfileUseCase(sl()))
    ..registerLazySingleton(
      () => ClearAccountDataUseCase(repository: sl()),
    )
    ..registerLazySingleton(() => GetAssetClassesUseCase(sl()))
    ..registerLazySingleton(() => CreateAssetClassUseCase(sl()))
    ..registerLazySingleton(() => UpdateAssetClassUseCase(sl()))
    ..registerLazySingleton(
      () => DeleteAssetClassUseCase(
        assetClassRepository: sl(),
        assetHoldingRepository: sl(),
      ),
    )
    ..registerLazySingleton(() => GetAssetHoldingsUseCase(sl()))
    ..registerLazySingleton(
      () => CreateAssetHoldingUseCase(
        holdingRepository: sl(),
        accountRepository: sl(),
        assetClassRepository: sl(),
        transactionRepository: sl(),
      ),
    )
    ..registerLazySingleton(
      () => UpdateAssetHoldingUseCase(
        holdingRepository: sl(),
        accountRepository: sl(),
        assetClassRepository: sl(),
        transactionRepository: sl(),
      ),
    )
    ..registerLazySingleton(() => DeleteAssetHoldingUseCase(sl()))
    ..registerLazySingleton(
      () => GetInvestmentOverviewUseCase(
        accountRepository: sl(),
        assetClassRepository: sl(),
        assetHoldingRepository: sl(),
        transactionRepository: sl(),
      ),
    )
    // ─── Blocs / Cubits (global singletons) ─────────────────
    ..registerLazySingleton(
      () => AuthBloc(
        signInWithGoogleUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUser: sl(),
        notificationService: kIsWeb ? null : sl<NotificationService>(),
      )..add(const AuthCheckRequested()),
    )
    ..registerLazySingleton(
      () => StartupCubit(
        authBloc: sl(),
        syncService: sl(),
      ),
    )
    ..registerLazySingleton(
      () => ThemeCubit(prefs: sl()),
    )
    ..registerLazySingleton(
      () => LightPaletteCubit(prefs: sl()),
    )
    ..registerLazySingleton(
      () => DarkPaletteCubit(prefs: sl()),
    )
    ..registerLazySingleton(
      () => AppLocaleCubit(prefs: sl()),
    )
    ..registerLazySingleton(DateFilterCubit.new)
    ..registerLazySingleton(NotificationService.new);
}
