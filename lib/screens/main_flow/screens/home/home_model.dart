import 'package:app_core/app_core.dart';
import 'package:financo/app/app_routes.dart';

HomeModel get homeModel => Modular.get<HomeModel>();

class HomeModel {
  void onTapGoToAccountStatement(int accountId) {
    Modular.to.navigate(
      ro.mainFlow.accountStatement.route,
      arguments: {'accountId': accountId},
    );
  }
}
