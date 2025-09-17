import 'package:app_core/app_core.dart';

import 'import_categories_model.dart';

class ImportCategoriesModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ImportCategoriesModel>(ImportCategoriesModel.new);
  }
}
