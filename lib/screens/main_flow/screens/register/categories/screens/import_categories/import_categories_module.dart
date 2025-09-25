import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/import_categories/import_categories_model.dart';

class ImportCategoriesModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ImportCategoriesModel>(ImportCategoriesModel.new);
  }
}
