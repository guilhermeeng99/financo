import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/create_and_edit_category_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/create_and_edit_category_model.dart';

class CreateAndEditCategoryModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<CreateAndEditCategoryModel>(CreateAndEditCategoryModel.new)
      ..addSingleton<CreateAndEditCategoryBloc>(CreateAndEditCategoryBloc.new);
  }
}
