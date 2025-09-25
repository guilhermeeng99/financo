import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_model.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_screen.dart';

class CategoriesModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<CategoriesBloc>(CategoriesBloc.new)
      ..addSingleton<CategoriesModelExcel>(CategoriesModelExcel.new)
      ..addSingleton<CategoriesModel>(CategoriesModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const CategoriesScreen());
  }
}
