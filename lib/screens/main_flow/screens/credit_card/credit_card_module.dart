import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_module.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_module.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_bloc.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_screen.dart';

class CreditCardModule extends Module {
  @override
  List<Module> get imports => [
    CoreTransactionsModule(),
    CoreCalendarModule(),
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i.addSingleton<CreditCardBloc>(CreditCardBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const CreditCardScreen());
  }
}
