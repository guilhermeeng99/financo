import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/sync/sync_service.dart';
// Accounts
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
// Auth
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:financo/features/auth/domain/repositories/auth_repository.dart';
import 'package:financo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
// Categories
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/data/repositories/category_repository_impl.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
// Chat
import 'package:financo/features/chat/data/datasources/chat_datasources.dart';
import 'package:financo/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
// Dashboard
import 'package:financo/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:financo/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
// Profile
import 'package:financo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';
import 'package:financo/features/profile/domain/usecases/get_profile_usecase.dart';
// Startup
import 'package:financo/features/startup/presentation/cubit/startup_cubit.dart';
// Transactions
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/toggle_reconciled_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  if (kIsWeb) {
    await GoogleSignIn.instance.initialize(clientId: _googleWebClientId);
  } else {
    await GoogleSignIn.instance.initialize();
  }

  sl
    // ─── External ────────────────────────────────────────────
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(
      () => GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
      ),
    )
    ..registerLazySingleton(() => prefs)
    ..registerLazySingleton(() => GoogleSignIn.instance)
    // ─── Local Database ─────────────────────────────────────
    ..registerLazySingleton(AppDatabase.new)
    ..registerLazySingleton(() => UsersDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => AccountsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => TransactionsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => CategoriesDao(sl<AppDatabase>()))
    // ─── Sync Service ───────────────────────────────────────
    ..registerLazySingleton(
      () => SyncService(
        accountRemote: sl(),
        transactionRemote: sl(),
        categoryRemote: sl(),
        accountsDao: sl(),
        transactionsDao: sl(),
        categoriesDao: sl(),
        usersDao: sl(),
        database: sl(),
      ),
    )
    // ─── Datasources ────────────────────────────────────────
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
    ..registerLazySingleton<GeminiDataSource>(
      () => GeminiDataSourceImpl(model: sl()),
    )
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(firestore: sl()),
    )
    // ─── Repositories ───────────────────────────────────────
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        usersDao: sl(),
        syncService: sl(),
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
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        geminiDataSource: sl(),
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
        firestore: sl(),
        usersDao: sl(),
      ),
    )
    // ─── Use Cases ──────────────────────────────────────────
    ..registerLazySingleton(() => SignInUseCase(sl()))
    ..registerLazySingleton(
      () => SignInWithGoogleUseCase(sl()),
    )
    ..registerLazySingleton(() => SignUpUseCase(sl()))
    ..registerLazySingleton(() => SignOutUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    ..registerLazySingleton(
      () => GetTransactionsUseCase(sl()),
    )
    ..registerLazySingleton(
      () => CreateTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => UpdateTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => DeleteTransactionUseCase(sl()),
    )
    ..registerLazySingleton(
      () => ToggleReconciledUseCase(sl()),
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
    ..registerLazySingleton(() => SendMessageUseCase(sl()))
    ..registerLazySingleton(
      () => GetChatHistoryUseCase(sl()),
    )
    ..registerLazySingleton(
      () => SaveChatMessageUseCase(sl()),
    )
    ..registerLazySingleton(
      () => GetDashboardSummaryUseCase(sl()),
    )
    ..registerLazySingleton(() => GetProfileUseCase(sl()))
    // ─── Blocs / Cubits (global singletons) ─────────────────
    ..registerLazySingleton(
      () => AuthBloc(
        signInUseCase: sl(),
        signInWithGoogleUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUser: sl(),
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
    ..registerLazySingleton(DateFilterCubit.new);
}
