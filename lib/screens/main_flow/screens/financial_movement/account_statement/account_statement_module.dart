import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';

import 'account_statement_bloc.dart';
import 'account_statement_screen.dart';

class AccountStatementModule extends Module {
  @override
  List<Module> get imports => [
    CoreTransactionsModule(),
    CoreCalendarModule(),
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i.addSingleton<AccountStatementBloc>(AccountStatementBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const AccountStatementScreen());
  }
}
