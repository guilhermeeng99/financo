// ignore_for_file: avoid_field_initializers_in_const_classes, subtype_of_disallowed_type

AppRoutes get ro => AppRoutes.instance;

class AppRoutes {
  const AppRoutes._();

  static const AppRoutes instance = AppRoutes._();

  final AppRoutesLoading loading = const AppRoutesLoading();
  final AppRoutesMainFlow mainFlow = const AppRoutesMainFlow();
}

class AppRoutesLoading {
  const AppRoutesLoading();

  final String route = '/loading/';
}

class AppRoutesMainFlow {
  const AppRoutesMainFlow();

  final String route = '/main_flow/';
  final AppRoutesMainFlowAccounts accounts = const AppRoutesMainFlowAccounts();
  final AppRoutesMainFlowCategories categories =
      const AppRoutesMainFlowCategories();
  final AppRoutesMainFlowHome home = const AppRoutesMainFlowHome();
  final AppRoutesMainFlowReleases releases = const AppRoutesMainFlowReleases();
}

class AppRoutesMainFlowAccounts {
  const AppRoutesMainFlowAccounts();

  final String route = '/main_flow/accounts/';
  final AppRoutesMainFlowAccountsCreateAndEditAccount createAndEditAccount =
      const AppRoutesMainFlowAccountsCreateAndEditAccount();
}

class AppRoutesMainFlowAccountsCreateAndEditAccount {
  const AppRoutesMainFlowAccountsCreateAndEditAccount();

  final String route = '/main_flow/accounts/create_and_edit_account/';
}

class AppRoutesMainFlowCategories {
  const AppRoutesMainFlowCategories();

  final String route = '/main_flow/categories/';
  final AppRoutesMainFlowCategoriesCreateAndEditCategory createAndEditCategory =
      const AppRoutesMainFlowCategoriesCreateAndEditCategory();
  final AppRoutesMainFlowCategoriesImportCategories importCategories =
      const AppRoutesMainFlowCategoriesImportCategories();
}

class AppRoutesMainFlowCategoriesCreateAndEditCategory {
  const AppRoutesMainFlowCategoriesCreateAndEditCategory();

  final String route = '/main_flow/categories/create_and_edit_category/';
}

class AppRoutesMainFlowCategoriesImportCategories {
  const AppRoutesMainFlowCategoriesImportCategories();

  final String route = '/main_flow/categories/import_categories/';
}

class AppRoutesMainFlowHome {
  const AppRoutesMainFlowHome();

  final String route = '/main_flow/home/';
}

class AppRoutesMainFlowReleases {
  const AppRoutesMainFlowReleases();

  final String route = '/main_flow/releases/';
  final AppRoutesMainFlowReleasesCreateAndEditTransaction
  createAndEditTransaction =
      const AppRoutesMainFlowReleasesCreateAndEditTransaction();
}

class AppRoutesMainFlowReleasesCreateAndEditTransaction {
  const AppRoutesMainFlowReleasesCreateAndEditTransaction();

  final String route = '/main_flow/releases/create_and_edit_transaction/';
}
