import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_bloc.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_screen.dart';

class CreditCardModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<CreditCardBloc>(CreditCardBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const CreditCardScreen());
  }
}
