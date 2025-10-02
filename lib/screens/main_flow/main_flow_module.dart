import 'package:app_core/app_core.dart';
import 'package:financo/app/app_routes.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';
import 'package:financo/screens/main_flow/main_flow_item.dart';
import 'package:financo/screens/main_flow/main_flow_model.dart';
import 'package:financo/screens/main_flow/main_flow_screen.dart';
import 'package:financo/screens/main_flow/screens/account_statement/account_statement_module.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_module.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_module.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_module.dart';
import 'package:financo/screens/main_flow/screens/home/home_module.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_module.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_module.dart';

class MainFlowModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<MainFlowTopBarModel>(MainFlowTopBarModel.new)
      ..addSingleton<MainFlowTopBarController>(MainFlowTopBarController.new)
      ..addSingleton<MainFlowSideBarController>(MainFlowSideBarController.new)
      ..addSingleton<MainFlowBloc>(MainFlowBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const MainFlowScreen(),
      duration: Duration.zero,
      transition: TransitionType.fadeIn,
      children: [
        ModuleRoute(
          _getRelativeRoute(ro.mainFlow.home.route),
          module: HomeModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          _getRelativeRoute(ro.mainFlow.register.categories.route),
          module: CategoriesModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          _getRelativeRoute(ro.mainFlow.register.accounts.route),
          module: AccountsModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          _getRelativeRoute(ro.mainFlow.financialMovement.releases.route),
          module: ReleasesModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          _getRelativeRoute(
            ro.mainFlow.financialMovement.pastAndFutureReleases.route,
          ),
          module: PastAndFutureReleasesModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          _getRelativeRoute(
            ro.mainFlow.accountStatement.route,
          ),
          module: AccountStatementModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          _getRelativeRoute(
            ro.mainFlow.creditCard.route,
          ),
          module: CreditCardModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
      ],
    );
  }

  String _getRelativeRoute(String fullRoute) {
    return fullRoute.replaceFirst(ro.mainFlow.route, '');
  }
}
