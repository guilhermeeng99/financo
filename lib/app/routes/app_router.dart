import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_mobile_nav.dart';
import 'package:financo/app/widgets/financo_sidebar.dart';
import 'package:financo/app/widgets/sub_page_scope.dart';
import 'package:financo/features/access_control/domain/usecases/add_allowed_email_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/list_allowed_emails_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/remove_allowed_email_usecase.dart';
import 'package:financo/features/access_control/presentation/pages/access_restricted_page.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/account_statement_cubit.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/pages/account_statement_page.dart';
import 'package:financo/features/accounts/presentation/pages/accounts_page.dart';
import 'package:financo/features/accounts/presentation/pages/add_account_page.dart';
import 'package:financo/features/accounts/presentation/pages/import_accounts_page.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/auth/presentation/pages/onboarding_page.dart';
import 'package:financo/features/auth/presentation/pages/sign_in_page.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/link_bill_to_transaction_usecase.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/reject_bill_match_usecase.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/bills/presentation/pages/add_bill_page.dart';
import 'package:financo/features/bills/presentation/pages/bills_page.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_overview_usecase.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:financo/features/budgets/presentation/pages/add_budget_page.dart';
import 'package:financo/features/budgets/presentation/pages/budgets_page.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/pages/add_category_page.dart';
import 'package:financo/features/categories/presentation/pages/categories_page.dart';
import 'package:financo/features/categories/presentation/pages/import_categories_page.dart';
import 'package:financo/features/chat/presentation/pages/chat_page.dart';
import 'package:financo/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/cubit/dashboard_account_selection_cubit.dart';
import 'package:financo/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:financo/features/master_panel/domain/usecases/delete_user_as_admin_usecase.dart';
import 'package:financo/features/master_panel/domain/usecases/list_all_users_usecase.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_cubit.dart';
import 'package:financo/features/master_panel/presentation/pages/master_panel_page.dart';
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
import 'package:financo/features/transactions/presentation/pages/import_transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.startup,
  redirect: (context, state) {
    final authState = authBloc.state;
    final isOnStartup = state.matchedLocation == AppRoutes.startup;
    final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;
    final isOnAuth = state.matchedLocation == AppRoutes.signIn;
    final isOnAccessRestricted =
        state.matchedLocation == AppRoutes.accessRestricted;

    // Startup is always accessible.
    if (isOnStartup) return null;

    // While auth is still resolving, redirect to startup to wait.
    if (authState is AuthInitial || authState is AuthLoading) {
      return AppRoutes.startup;
    }

    // AccessDenied keeps the user on the restricted page until they
    // tap "back" (which dispatches sign-out).
    if (authState is AccessDenied) {
      return isOnAccessRestricted ? null : AppRoutes.accessRestricted;
    }

    // Unauthenticated users can stay on auth/onboarding pages.
    if (authState is Unauthenticated) {
      if (isOnAuth || isOnOnboarding) return null;
      return AppRoutes.signIn;
    }

    // Authenticated users on auth/onboarding pages go through startup
    // so the data sync happens before entering the app. Same applies
    // for the access-restricted page (e.g. user came back from sign-out
    // and was re-authenticated successfully).
    if (authState is Authenticated &&
        (isOnAuth || isOnOnboarding || isOnAccessRestricted)) {
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
      path: AppRoutes.accessRestricted,
      builder: (context, state) => const AccessRestrictedPage(),
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
              create: (_) => DashboardAccountSelectionCubit(
                prefs: GetIt.I<SharedPreferences>(),
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
                  getTransactions: GetIt.I<GetTransactionsUseCase>(),
                  importAccountsCsv: GetIt.I<ImportAccountsCsvUseCase>(),
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
            BlocProvider(
              // Eagerly load bills so the nav badge (overdue + due-today
              // count) is correct from any tab — not only after the user
              // opens the Bills page. Cache-only read; the page itself
              // can still force a refresh.
              create: (_) => BillsBloc(
                getBills: GetIt.I<GetBillsUseCase>(),
                deleteBill: GetIt.I<DeleteBillUseCase>(),
                payBill: GetIt.I<PayBillUseCase>(),
                getTransactions: GetIt.I<GetTransactionsUseCase>(),
                linkBillToTransaction:
                    GetIt.I<LinkBillToTransactionUseCase>(),
                rejectBillMatch: GetIt.I<RejectBillMatchUseCase>(),
                userId: userId,
              )..add(const BillsLoadRequested()),
            ),
            BlocProvider(
              create: (_) => BudgetsCubit(
                getOverview: GetIt.I<GetBudgetsOverviewUseCase>(),
                deleteBudget: GetIt.I<DeleteBudgetUseCase>(),
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
          path: AppRoutes.masterPanel,
          builder: (context, state) => SubPageScope(
            child: BlocProvider(
              create: (_) => MasterPanelCubit(
                listAllUsers: GetIt.I<ListAllUsersUseCase>(),
                listAllowedEmails: GetIt.I<ListAllowedEmailsUseCase>(),
                addAllowedEmail: GetIt.I<AddAllowedEmailUseCase>(),
                removeAllowedEmail: GetIt.I<RemoveAllowedEmailUseCase>(),
                deleteUserAsAdmin: GetIt.I<DeleteUserAsAdminUseCase>(),
              ),
              child: const MasterPanelPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.accountDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return SubPageScope(
              child: BlocProvider(
                create: (_) => AccountStatementCubit(
                  getTransactions: GetIt.I<GetTransactionsUseCase>(),
                  getTransaction: GetIt.I<GetTransactionUseCase>(),
                  accountId: id,
                ),
                child: AccountStatementPage(accountId: id),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.addTransaction,
          builder: (context, state) {
            // `extra` is polymorphic on this route:
            //   - `TransactionEntity` → editing an existing tx
            //   - `BillEntity`        → creating a tx to settle a bill
            //   - null                → blank create flow
            final extra = state.extra;
            final existing =
                extra is TransactionEntity ? extra : null;
            final prefillFromBill = extra is BillEntity ? extra : null;
            // Optional `?accountId=` — used by the account-statement FAB
            // so a new transaction opens with the current account already
            // selected. Edit mode (non-null `existing`) ignores it.
            final prefillAccountId = state.uri.queryParameters['accountId'];
            return SubPageScope(
              child: AddTransactionPage(
                existingTransaction: existing,
                prefillAccountId: prefillAccountId,
                prefillFromBill: prefillFromBill,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.importTransactions,
          builder: (context, state) {
            final preview = state.extra! as TransactionImportPreview;
            return SubPageScope(
              child: ImportTransactionsPage(preview: preview),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.accounts,
          builder: (context, state) =>
              const SubPageScope(child: AccountsPage()),
        ),
        GoRoute(
          path: AppRoutes.importAccounts,
          builder: (context, state) {
            final preview = state.extra! as AccountImportPreview;
            return SubPageScope(
              child: ImportAccountsPage(preview: preview),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.categories,
          builder: (context, state) =>
              const SubPageScope(child: CategoriesPage()),
        ),
        GoRoute(
          path: AppRoutes.importCategories,
          builder: (context, state) {
            final preview = state.extra! as CategoryImportPreview;
            return SubPageScope(
              child: ImportCategoriesPage(preview: preview),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.bills,
          builder: (context, state) => const BillsPage(),
        ),
        GoRoute(
          path: AppRoutes.addBill,
          builder: (context, state) {
            final existing = state.extra as BillEntity?;
            return SubPageScope(
              child: AddBillPage(existingBill: existing),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.editBill,
          builder: (context, state) {
            final existing = state.extra as BillEntity?;
            return SubPageScope(
              child: AddBillPage(existingBill: existing),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.budgets,
          builder: (context, state) => const BudgetsPage(),
        ),
        GoRoute(
          path: AppRoutes.addBudget,
          builder: (context, state) {
            final existing = state.extra as BudgetEntity?;
            return SubPageScope(
              child: AddBudgetPage(existingBudget: existing),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.editBudget,
          builder: (context, state) {
            final existing = state.extra as BudgetEntity?;
            return SubPageScope(
              child: AddBudgetPage(existingBudget: existing),
            );
          },
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

/// Mobile shell. Bottom bar and month filter visibility are driven by
/// [SubPageScope]: any sub-page (accounts, categories, account detail,
/// add bill, etc.) wraps itself in `SubPageScope`, which increments a
/// global depth counter. While depth > 0, the bar is hidden.
///
/// We use this explicit signal because go_router's `state.matchedLocation`
/// and `Navigator.canPop()` are both unreliable for sibling pushes inside
/// a ShellRoute — the shell-level match doesn't refresh and the navigator
/// stack appears flat after the push transition settles.
class _ShellWithSidebar extends StatefulWidget {
  const _ShellWithSidebar({required this.child});

  final Widget child;

  static const double _mobileBreakpoint = 600;

  @override
  State<_ShellWithSidebar> createState() => _ShellWithSidebarState();
}

class _ShellWithSidebarState extends State<_ShellWithSidebar> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (router != _router) {
      _router?.routerDelegate.removeListener(_onRouteChange);
      _router = router;
      _router!.routerDelegate.addListener(_onRouteChange);
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    if (mounted) setState(() {});
  }

  /// Shell-level matched location — used only to gate the dashboard
  /// month filter, which lives on a tab route reached via `context.go`
  /// (and is therefore reliably reflected here).
  String _shellLocation() {
    final config = _router?.routerDelegate.currentConfiguration;
    if (config == null) return '';
    return config.uri.path;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < _ShellWithSidebar._mobileBreakpoint;

    if (isMobile) {
      return ValueListenableBuilder<int>(
        valueListenable: subPageDepthListenable,
        builder: (context, depth, _) {
          final isOnSubPage = depth > 0;
          final showMonthFilter =
              !isOnSubPage && _shellLocation() == AppRoutes.dashboard;
          final showBottomBar = !isOnSubPage;

          return Scaffold(
            // Lets scrollable content flow behind the floating bottom bar
            // so it visually "lifts" off the page instead of clipping the
            // body.
            extendBody: true,
            appBar: showMonthFilter ? const FinancoMobileAppBar() : null,
            body: widget.child,
            bottomNavigationBar:
                showBottomBar ? const FinancoBottomBar() : null,
          );
        },
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const FinancoSidebar(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
