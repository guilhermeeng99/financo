import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_module.dart';
import 'package:financo/screens/main_flow/screens/profile/profile_bloc.dart';
import 'package:financo/screens/main_flow/screens/profile/profile_model.dart';
import 'package:financo/screens/main_flow/screens/profile/profile_screen.dart';

class ProfileModule extends Module {
  @override
  List<Module> get imports => [
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i
      ..addSingleton<ProfileBloc>(ProfileBloc.new)
      ..addSingleton<ProfileModel>(ProfileModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ProfileScreen());
  }
}
