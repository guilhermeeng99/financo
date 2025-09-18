import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';

import 'past_and_future_releases_bloc.dart';
import 'past_and_future_releases_screen.dart';
import 'past_and_future_releases_types.dart';

class PastAndFutureReleasesModule extends Module {
  @override
  List<Module> get imports => [
    CoreTransactionsModule(),
    CoreCalendarModule(),
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i.addSingleton<PastAndFutureReleasesBloc>(PastAndFutureReleasesBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) {
        final args = Modular.args;
        final typeParam = args.queryParams['type'];
        final screenType = PastAndFutureReleasesScreenType.fromString(
          typeParam,
        );
        return PastAndFutureReleasesScreen(type: screenType);
      },
    );
  }
}
