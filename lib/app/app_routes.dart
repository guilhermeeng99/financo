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
  final AppRoutesMainFlowFinancialMovement financialMovement =
      const AppRoutesMainFlowFinancialMovement();
  final AppRoutesMainFlowHome home = const AppRoutesMainFlowHome();
  final AppRoutesMainFlowRegister register = const AppRoutesMainFlowRegister();
}

class AppRoutesMainFlowFinancialMovement {
  const AppRoutesMainFlowFinancialMovement();

  final AppRoutesMainFlowFinancialMovementFilteredReleases filteredReleases =
      const AppRoutesMainFlowFinancialMovementFilteredReleases();
  final AppRoutesMainFlowFinancialMovementReleases releases =
      const AppRoutesMainFlowFinancialMovementReleases();
}

class AppRoutesMainFlowFinancialMovementFilteredReleases {
  const AppRoutesMainFlowFinancialMovementFilteredReleases();

  final String route = '/main_flow/financial_movement/filtered_releases/';
}

class AppRoutesMainFlowFinancialMovementReleases {
  const AppRoutesMainFlowFinancialMovementReleases();

  final String route = '/main_flow/financial_movement/releases/';
  final AppRoutesMainFlowFinancialMovementReleasesCreateAndEditTransaction
  createAndEditTransaction =
      const AppRoutesMainFlowFinancialMovementReleasesCreateAndEditTransaction();
  final AppRoutesMainFlowFinancialMovementReleasesImportTransactions
  importTransactions =
      const AppRoutesMainFlowFinancialMovementReleasesImportTransactions();
}

class AppRoutesMainFlowFinancialMovementReleasesCreateAndEditTransaction {
  const AppRoutesMainFlowFinancialMovementReleasesCreateAndEditTransaction();

  final String route =
      '/main_flow/financial_movement/releases/create_and_edit_transaction/';
}

class AppRoutesMainFlowFinancialMovementReleasesImportTransactions {
  const AppRoutesMainFlowFinancialMovementReleasesImportTransactions();

  final String route =
      '/main_flow/financial_movement/releases/import_transactions/';
}

class AppRoutesMainFlowHome {
  const AppRoutesMainFlowHome();

  final String route = '/main_flow/home/';
}

class AppRoutesMainFlowRegister {
  const AppRoutesMainFlowRegister();

  final AppRoutesMainFlowRegisterAccounts accounts =
      const AppRoutesMainFlowRegisterAccounts();
  final AppRoutesMainFlowRegisterCategories categories =
      const AppRoutesMainFlowRegisterCategories();
}

class AppRoutesMainFlowRegisterAccounts {
  const AppRoutesMainFlowRegisterAccounts();

  final String route = '/main_flow/register/accounts/';
  final AppRoutesMainFlowRegisterAccountsCreateAndEditAccount
  createAndEditAccount =
      const AppRoutesMainFlowRegisterAccountsCreateAndEditAccount();
}

class AppRoutesMainFlowRegisterAccountsCreateAndEditAccount {
  const AppRoutesMainFlowRegisterAccountsCreateAndEditAccount();

  final String route = '/main_flow/register/accounts/create_and_edit_account/';
}

class AppRoutesMainFlowRegisterCategories {
  const AppRoutesMainFlowRegisterCategories();

  final String route = '/main_flow/register/categories/';
  final AppRoutesMainFlowRegisterCategoriesCreateAndEditCategory
  createAndEditCategory =
      const AppRoutesMainFlowRegisterCategoriesCreateAndEditCategory();
  final AppRoutesMainFlowRegisterCategoriesImportCategories importCategories =
      const AppRoutesMainFlowRegisterCategoriesImportCategories();
}

class AppRoutesMainFlowRegisterCategoriesCreateAndEditCategory {
  const AppRoutesMainFlowRegisterCategoriesCreateAndEditCategory();

  final String route =
      '/main_flow/register/categories/create_and_edit_category/';
}

class AppRoutesMainFlowRegisterCategoriesImportCategories {
  const AppRoutesMainFlowRegisterCategoriesImportCategories();

  final String route = '/main_flow/register/categories/import_categories/';
}
