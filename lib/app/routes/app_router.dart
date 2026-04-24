import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_mobile_nav.dart';
import 'package:financo/app/widgets/financo_sidebar.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/account_statement_cubit.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/pages/account_statement_page.dart';
import 'package:financo/features/accounts/presentation/pages/accounts_page.dart';
import 'package:financo/features/accounts/presentation/pages/add_account_page.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/auth/presentation/pages/onboarding_page.dart';
import 'package:financo/features/auth/presentation/pages/sign_in_page.dart';
import 'package:financo/features/auth/presentation/pages/sign_up_page.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/pages/add_category_page.dart';
import 'package:financo/features/categories/presentation/pages/categories_page.dart';
import 'package:financo/features/chat/presentation/pages/chat_page.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:financo/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:financo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:financo/features/profile/presentation/pages/profile_page.dart';
import 'package:financo/features/startup/presentation/pages/startup_page.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.startup,
  redirect: (context, state) {
    final authState = authBloc.state;
    final isOnStartup = state.matchedLocation == AppRoutes.startup;
    final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;
    final isOnAuth =
        state.matchedLocation == AppRoutes.signIn ||
        state.matchedLocation == AppRoutes.signUp;

    // Startup is always accessible.
    if (isOnStartup) return null;

    // While auth is still resolving, redirect to startup to wait.
    if (authState is AuthInitial || authState is AuthLoading) {
      return AppRoutes.startup;
    }

    // Unauthenticated users can stay on auth/onboarding pages.
    if (authState is Unauthenticated) {
      if (isOnAuth || isOnOnboarding) return null;
      return AppRoutes.signIn;
    }

    // Authenticated users on auth/onboarding pages go through startup
    // so the data sync happens before entering the app.
    if (authState is Authenticated && (isOnAuth || isOnOnboarding)) {
      return AppRoutes.startup;
    }

    return null;
  },
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
  routes: [
    GoRoute(
      path: AppRoutes.startup,
      builder: (context, state) => const StartupPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final authState = context.read<AuthBloc>().state;
        final userId = authState is Authenticated ? authState.user.id : '';
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => DashboardBloc(
                getDashboardSummary: GetIt.I<GetDashboardSummaryUseCase>(),
                getTransactions: GetIt.I<GetTransactionsUseCase>(),
                userId: userId,
              ),
            ),
            BlocProvider(
              create: (_) => TransactionsBloc(
                getTransactions: GetIt.I<GetTransactionsUseCase>(),
                deleteTransaction: GetIt.I<DeleteTransactionUseCase>(),
                importTransactionsCsv: GetIt.I<ImportTransactionsCsvUseCase>(),
                userId: userId,
              ),
            ),
            BlocProvider(
              create: (_) {
                final cubit = AccountsCubit(
                  getAccounts: GetIt.I<GetAccountsUseCase>(),
                  userId: userId,
                );
                unawaited(cubit.loadAccounts());
                return cubit;
              },
            ),
            BlocProvider(
              create: (_) {
                final cubit = CategoriesCubit(
                  getCategories: GetIt.I<GetCategoriesUseCase>(),
                  importCategoriesCsv: GetIt.I<ImportCategoriesCsvUseCase>(),
                  userId: userId,
                );
                unawaited(cubit.loadCategories());
                return cubit;
              },
            ),
            BlocProvider(
              create: (_) => ProfileCubit(
                getProfile: GetIt.I<GetProfileUseCase>(),
                userId: userId,
              ),
            ),
          ],
          child: _ShellWithSidebar(child: child),
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (context, state) => const ChatPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.accountDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => AccountStatementCubit(
                getTransactions: GetIt.I<GetTransactionsUseCase>(),
                getTransaction: GetIt.I<GetTransactionUseCase>(),
                accountId: id,
              ),
              child: AccountStatementPage(accountId: id),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.addTransaction,
          builder: (context, state) {
            final existing = state.extra as TransactionEntity?;
            return AddTransactionPage(existingTransaction: existing);
          },
        ),
        GoRoute(
          path: AppRoutes.accounts,
          builder: (context, state) => const AccountsPage(),
        ),
        GoRoute(
          path: AppRoutes.categories,
          builder: (context, state) => const CategoriesPage(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.addAccount,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final existing = state.extra as AccountEntity?;
        return AddAccountPage(existingAccount: existing);
      },
    ),
    GoRoute(
      path: AppRoutes.addCategory,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddCategoryPage(),
    ),
    GoRoute(
      path: AppRoutes.editCategory,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra! as CategoryEntity;
        return AddCategoryPage(existingCategory: extra);
      },
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    (_subscription as dynamic).cancel();
    super.dispose();
  }
}

class _ShellWithSidebar extends StatelessWidget {
  const _ShellWithSidebar({required this.child});

  final Widget child;

  static const double _mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;

    if (isMobile) {
      return Scaffold(
        appBar: const FinancoMobileAppBar(),
        body: child,
        bottomNavigationBar: const FinancoBottomBar(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const FinancoSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
