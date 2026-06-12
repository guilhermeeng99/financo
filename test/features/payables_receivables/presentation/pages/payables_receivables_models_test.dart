import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/payables_receivables/presentation/pages/payables_receivables_page.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/settle_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

// The snapshot/summary/grouping models are library-private (`part of` the
// page), so the filtering, sorting and grouping rules are exercised through
// the public PayablesReceivablesPage widget — the library entry point.
void main() {
  late MockAuthBloc authBloc;
  late MockAccountsCubit accountsCubit;
  late MockCategoriesCubit categoriesCubit;
  late MockTransactionsBloc transactionsBloc;
  late MockDashboardBloc dashboardBloc;
  late DateFilterCubit dateFilterCubit;
  late MockGetTransactionsUseCase getTransactions;
  late MockSettleTransactionUseCase settleTransaction;
  late MockDeleteTransactionUseCase deleteTransaction;

  // Grouping (overdue/today/upcoming) compares against the real clock, so
  // fixtures are derived from `now` to stay repeatable on any run date.
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final previousMonth = DateTime(now.year, now.month - 1);
  final nextMonth = DateTime(now.year, now.month + 1);
  final dueToday = DateTime(now.year, now.month, now.day, 12);

  setUpAll(() async {
    // The month pill renders DateFormat.yMMMM — in the app the
    // flutter_localizations delegates load the date symbols, in tests we
    // must load them ourselves or the page build throws.
    await initializeDateFormatting();
    registerTransactionFallbackValues();
    registerFallbackValue(TransactionsLoadRequested());
    registerFallbackValue(const DashboardRefreshRequested());
  });

  setUp(() {
    authBloc = MockAuthBloc();
    accountsCubit = MockAccountsCubit();
    categoriesCubit = MockCategoriesCubit();
    transactionsBloc = MockTransactionsBloc();
    dashboardBloc = MockDashboardBloc();
    dateFilterCubit = DateFilterCubit();
    getTransactions = MockGetTransactionsUseCase();
    settleTransaction = MockSettleTransactionUseCase();
    deleteTransaction = MockDeleteTransactionUseCase();

    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: Authenticated(UserFactory.entity()),
    );
    whenListen(
      accountsCubit,
      const Stream<AccountsState>.empty(),
      initialState: AccountsLoaded([AccountFactory.checking(id: 'acc-1')]),
    );
    whenListen(
      categoriesCubit,
      const Stream<CategoriesState>.empty(),
      initialState: const CategoriesLoaded([]),
    );
    whenListen(
      transactionsBloc,
      const Stream<TransactionsState>.empty(),
      initialState: const TransactionsInitial(),
    );
    whenListen(
      dashboardBloc,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardInitial(),
    );
    when(
      () => accountsCubit.loadAccounts(
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});

    GetIt.I
      ..registerSingleton<GetTransactionsUseCase>(getTransactions)
      ..registerSingleton<SettleTransactionUseCase>(settleTransaction)
      ..registerSingleton<DeleteTransactionUseCase>(deleteTransaction);
  });

  tearDown(() async {
    await dateFilterCubit.close();
    await GetIt.I.reset();
  });

  void stubTransactions(List<TransactionEntity> transactions) {
    when(
      () => getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        dueStartDate: any(named: 'dueStartDate'),
        dueEndDate: any(named: 'dueEndDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        settlementStatus: any(named: 'settlementStatus'),
        recurrence: any(named: 'recurrence'),
        recurrenceGroupId: any(named: 'recurrenceGroupId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(transactions));
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    required DateTime month,
    PayablesReceivablesView initialView = PayablesReceivablesView.payables,
  }) async {
    // Mobile width so the single-column ledger layout renders.
    tester.view.physicalSize = const Size(480, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    dateFilterCubit.setMonth(month.year, month.month);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<DateFilterCubit>.value(value: dateFilterCubit),
          BlocProvider<AccountsCubit>.value(value: accountsCubit),
          BlocProvider<CategoriesCubit>.value(value: categoriesCubit),
          BlocProvider<TransactionsBloc>.value(value: transactionsBloc),
          BlocProvider<DashboardBloc>.value(value: dashboardBloc),
        ],
        child: MaterialApp(
          home: PayablesReceivablesPage(initialView: initialView),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double topOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  // find.byIcon expects Material IconData; FontAwesome glyphs are wrapped
  // in FaIconData, so match on the underlying data instead.
  Finder settleButton() => find.byWidgetPredicate(
    (widget) =>
        widget is FaIcon && widget.icon == FontAwesomeIcons.check.data,
  );

  // FinancoSectionHeader upper-cases its title before rendering.
  Finder groupHeader(String title) => find.text(title.toUpperCase());

  TransactionEntity pendingPayable({
    required String id,
    required String description,
    required DateTime dueDate,
    double amount = 150,
    String accountId = 'acc-1',
  }) => TransactionFactory.expense(
    id: id,
    description: description,
    amount: amount,
    accountId: accountId,
    settlementStatus: TransactionSettlementStatus.pending,
    date: dueDate,
    dueDate: dueDate,
  );

  group('payables view filtering', () {
    testWidgets(
      'shows only pending payables due inside the filter month',
      (tester) async {
        final transfer = TransactionFactory.transfer(
          date: dueToday,
          description: 'Transfer between accounts',
        );
        stubTransactions([
          pendingPayable(
            id: 'tx-due',
            description: 'Rent',
            dueDate: dueToday,
          ),
          pendingPayable(
            id: 'tx-other-month',
            description: 'Far future bill',
            dueDate: DateTime(nextMonth.year, nextMonth.month, 15),
          ),
          TransactionFactory.income(
            id: 'tx-receivable',
            description: 'Client invoice',
            settlementStatus: TransactionSettlementStatus.pending,
            date: dueToday,
            dueDate: dueToday,
          ),
          TransactionFactory.expense(
            id: 'tx-paid',
            description: 'Already settled',
            date: dueToday,
          ),
          transfer.expense,
          transfer.income,
        ]);

        await pumpPage(tester, month: currentMonth);

        expect(find.text('Rent'), findsOneWidget);
        expect(find.text('Far future bill'), findsNothing);
        expect(find.text('Client invoice'), findsNothing);
        expect(find.text('Already settled'), findsNothing);
        expect(find.text('Transfer between accounts'), findsNothing);
      },
    );

    testWidgets(
      'hides transactions whose account is not in the visible account list',
      (tester) async {
        stubTransactions([
          pendingPayable(id: 'tx-1', description: 'Mine', dueDate: dueToday),
          pendingPayable(
            id: 'tx-2',
            description: 'Ghost account bill',
            dueDate: dueToday,
            accountId: 'acc-deleted',
          ),
        ]);

        await pumpPage(tester, month: currentMonth);

        expect(find.text('Mine'), findsOneWidget);
        expect(find.text('Ghost account bill'), findsNothing);
      },
    );

    testWidgets('shows the empty state when nothing matches', (tester) async {
      stubTransactions([]);

      await pumpPage(tester, month: currentMonth);

      expect(find.text(t.payablesReceivables.emptyTitle), findsOneWidget);
    });
  });

  group('pending grouping and sorting', () {
    testWidgets(
      'a fully past month lands in the overdue group, '
      'sorted by ascending due date',
      (tester) async {
        stubTransactions([
          pendingPayable(
            id: 'tx-20',
            description: 'Due 20th',
            dueDate: DateTime(previousMonth.year, previousMonth.month, 20),
          ),
          pendingPayable(
            id: 'tx-05',
            description: 'Due 5th',
            dueDate: DateTime(previousMonth.year, previousMonth.month, 5),
          ),
          pendingPayable(
            id: 'tx-10',
            description: 'Due 10th',
            dueDate: DateTime(previousMonth.year, previousMonth.month, 10),
          ),
        ]);

        await pumpPage(tester, month: previousMonth);

        expect(groupHeader(t.payablesReceivables.overdueGroup), findsOneWidget);
        expect(groupHeader(t.payablesReceivables.todayGroup), findsNothing);
        expect(groupHeader(t.payablesReceivables.upcomingGroup), findsNothing);
        expect(
          topOf(tester, 'Due 5th'),
          lessThan(topOf(tester, 'Due 10th')),
        );
        expect(
          topOf(tester, 'Due 10th'),
          lessThan(topOf(tester, 'Due 20th')),
        );
      },
    );

    testWidgets('a payable due today lands in the today group',
        (tester) async {
      stubTransactions([
        pendingPayable(
          id: 'tx-today',
          description: 'Internet bill',
          dueDate: dueToday,
        ),
      ]);

      await pumpPage(tester, month: currentMonth);

      expect(groupHeader(t.payablesReceivables.todayGroup), findsOneWidget);
      expect(groupHeader(t.payablesReceivables.overdueGroup), findsNothing);
      expect(groupHeader(t.payablesReceivables.upcomingGroup), findsNothing);
    });

    testWidgets(
      'a fully future month lands in the upcoming group',
      (tester) async {
        stubTransactions([
          pendingPayable(
            id: 'tx-up',
            description: 'Next month rent',
            dueDate: DateTime(nextMonth.year, nextMonth.month, 15),
          ),
        ]);

        await pumpPage(tester, month: nextMonth);

        expect(
          groupHeader(t.payablesReceivables.upcomingGroup),
          findsOneWidget,
        );
        expect(groupHeader(t.payablesReceivables.overdueGroup), findsNothing);
        expect(groupHeader(t.payablesReceivables.todayGroup), findsNothing);
      },
    );
  });

  group('paid view', () {
    testWidgets(
      'lists settled payables in a single section, newest first by date',
      (tester) async {
        TransactionEntity paid(String id, String description, int day) =>
            TransactionFactory.expense(
              id: id,
              description: description,
              date: DateTime(previousMonth.year, previousMonth.month, day),
            );
        stubTransactions([
          paid('tx-05', 'Paid 5th', 5),
          paid('tx-20', 'Paid 20th', 20),
          paid('tx-10', 'Paid 10th', 10),
        ]);

        await pumpPage(
          tester,
          month: previousMonth,
          initialView: PayablesReceivablesView.paid,
        );

        expect(find.text(t.payablesReceivables.paidPlural), findsWidgets);
        expect(
          topOf(tester, 'Paid 20th'),
          lessThan(topOf(tester, 'Paid 10th')),
        );
        expect(
          topOf(tester, 'Paid 10th'),
          lessThan(topOf(tester, 'Paid 5th')),
        );
      },
    );
  });

  group('summary card', () {
    testWidgets('totals pending payables and receivables for the month',
        (tester) async {
      stubTransactions([
        pendingPayable(
          id: 'tx-1',
          description: 'Bill A',
          dueDate: dueToday,
        ),
        pendingPayable(
          id: 'tx-2',
          description: 'Bill B',
          amount: 250,
          dueDate: dueToday,
        ),
        TransactionFactory.income(
          id: 'tx-3',
          description: 'Invoice',
          amount: 90,
          settlementStatus: TransactionSettlementStatus.pending,
          date: dueToday,
          dueDate: dueToday,
        ),
      ]);

      await pumpPage(tester, month: currentMonth);

      // formatCurrency puts a non-breaking space after the symbol.
      expect(find.text(r'R$' ' 400,00'), findsOneWidget);
      expect(find.text(r'R$' ' 90,00'), findsOneWidget);
    });
  });

  group('view toggle', () {
    testWidgets('switching to receivables swaps the visible list',
        (tester) async {
      stubTransactions([
        pendingPayable(id: 'tx-pay', description: 'Rent', dueDate: dueToday),
        TransactionFactory.income(
          id: 'tx-rec',
          description: 'Client invoice',
          settlementStatus: TransactionSettlementStatus.pending,
          date: dueToday,
          dueDate: dueToday,
        ),
      ]);

      await pumpPage(tester, month: currentMonth);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Client invoice'), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(FinancoPillToggle<PayablesReceivablesView>),
          matching: find.text(t.payablesReceivables.typeReceivable),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Client invoice'), findsOneWidget);
      expect(find.text('Rent'), findsNothing);
    });
  });

  group('settle flow', () {
    testWidgets(
      'tapping settle calls the use case, refetches and pings dependents',
      (tester) async {
        final payable = pendingPayable(
          id: 'tx-settle',
          description: 'Internet bill',
          dueDate: dueToday,
        );
        stubTransactions([payable]);
        when(
          () => settleTransaction(
            any(),
            settledAt: any(named: 'settledAt'),
          ),
        ).thenAnswer(
          (_) async => Right(
            payable.copyWith(
              settlementStatus: TransactionSettlementStatus.paid,
            ),
          ),
        );

        await pumpPage(tester, month: currentMonth);
        clearInteractions(getTransactions);

        await tester.tap(settleButton());
        await tester.pumpAndSettle();

        verify(() => settleTransaction(payable)).called(1);
        expect(
          find.text(t.payablesReceivables.transactionPaid),
          findsOneWidget,
        );
        // Settling money must ripple to every consumer of balances.
        verify(
          () => transactionsBloc.add(
            any(that: isA<TransactionsLoadRequested>()),
          ),
        ).called(1);
        verify(
          () => dashboardBloc.add(
            any(that: isA<DashboardRefreshRequested>()),
          ),
        ).called(1);
        verify(() => accountsCubit.loadAccounts(forceRefresh: true)).called(1);
        verify(
          () => getTransactions(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            dueStartDate: any(named: 'dueStartDate'),
            dueEndDate: any(named: 'dueEndDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
            settlementStatus: any(named: 'settlementStatus'),
            recurrence: any(named: 'recurrence'),
            recurrenceGroupId: any(named: 'recurrenceGroupId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'settling a receivable shows the received confirmation',
      (tester) async {
        final receivable = TransactionFactory.income(
          id: 'tx-rec',
          description: 'Client invoice',
          settlementStatus: TransactionSettlementStatus.pending,
          date: dueToday,
          dueDate: dueToday,
        );
        stubTransactions([receivable]);
        when(
          () => settleTransaction(
            any(),
            settledAt: any(named: 'settledAt'),
          ),
        ).thenAnswer((_) async => Right(receivable));

        await pumpPage(
          tester,
          month: currentMonth,
          initialView: PayablesReceivablesView.receivables,
        );

        await tester.tap(settleButton());
        await tester.pumpAndSettle();

        expect(
          find.text(t.payablesReceivables.transactionReceived),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a settle failure surfaces the localized error and skips refreshes',
      (tester) async {
        stubTransactions([
          pendingPayable(
            id: 'tx-fail',
            description: 'Internet bill',
            dueDate: dueToday,
          ),
        ]);
        when(
          () => settleTransaction(
            any(),
            settledAt: any(named: 'settledAt'),
          ),
        ).thenAnswer((_) async => const Left(ServerFailure()));

        await pumpPage(tester, month: currentMonth);

        await tester.tap(settleButton());
        await tester.pumpAndSettle();

        expect(find.text(t.errors.server), findsOneWidget);
        verifyNever(() => transactionsBloc.add(any()));
        verifyNever(() => dashboardBloc.add(any()));
      },
    );
  });
}
