import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';

import 'blocs/accounts_bloc.dart';
import 'blocs/balance_calculation_bloc.dart';
import 'blocs/transaction_summary_bloc.dart';
import 'releases_bloc.dart';
import 'releases_model.dart';
import 'releases_screen.dart';

class ReleasesModule extends Module {
  @override
  List<Module> get imports => [TransactionsModule(), CalendarModule()];

  @override
  void binds(Injector i) {
    i
      // Register specialized blocs first (dependencies)
      ..addSingleton<AccountsBloc>(AccountsBloc.new)
      ..addSingleton<BalanceCalculationBloc>(BalanceCalculationBloc.new)
      ..addSingleton<TransactionSummaryBloc>(TransactionSummaryBloc.new)
      // Register main bloc (coordinator)
      ..addSingleton<ReleasesBloc>(ReleasesBloc.new)
      ..addSingleton<ReleasesModel>(ReleasesModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ReleasesScreen());
  }
}
