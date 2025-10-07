// ignore_for_file: avoid_field_initializers_in_const_classes

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
  final AppRoutesMainFlowAccountStatement accountStatement =
      const AppRoutesMainFlowAccountStatement();
  final AppRoutesMainFlowCreateAndEditTransaction createAndEditTransaction =
      const AppRoutesMainFlowCreateAndEditTransaction();
  final AppRoutesMainFlowCreditCard creditCard =
      const AppRoutesMainFlowCreditCard();
  final AppRoutesMainFlowFinancialMovement financialMovement =
      const AppRoutesMainFlowFinancialMovement();
  final AppRoutesMainFlowHome home = const AppRoutesMainFlowHome();
  final AppRoutesMainFlowProfile profile = const AppRoutesMainFlowProfile();
  final AppRoutesMainFlowRegister register = const AppRoutesMainFlowRegister();
}

class AppRoutesMainFlowAccountStatement {
  const AppRoutesMainFlowAccountStatement();

  final String route = '/main_flow/account_statement/';
}

class AppRoutesMainFlowCreateAndEditTransaction {
  const AppRoutesMainFlowCreateAndEditTransaction();

  final String route = '/main_flow/create_and_edit_transaction/';
  final AppRoutesMainFlowCreateAndEditTransactionImportTransactions
  importTransactions =
      const AppRoutesMainFlowCreateAndEditTransactionImportTransactions();
}

class AppRoutesMainFlowCreateAndEditTransactionImportTransactions {
  const AppRoutesMainFlowCreateAndEditTransactionImportTransactions();

  final String route =
      '/main_flow/create_and_edit_transaction/import_transactions/';
}

class AppRoutesMainFlowCreditCard {
  const AppRoutesMainFlowCreditCard();

  final String route = '/main_flow/credit_card/';
}

class AppRoutesMainFlowFinancialMovement {
  const AppRoutesMainFlowFinancialMovement();

  final AppRoutesMainFlowFinancialMovementPastAndFutureReleases
  pastAndFutureReleases =
      const AppRoutesMainFlowFinancialMovementPastAndFutureReleases();
  final AppRoutesMainFlowFinancialMovementReleases releases =
      const AppRoutesMainFlowFinancialMovementReleases();
}

class AppRoutesMainFlowFinancialMovementPastAndFutureReleases {
  const AppRoutesMainFlowFinancialMovementPastAndFutureReleases();

  final String route =
      '/main_flow/financial_movement/past_and_future_releases/';
}

class AppRoutesMainFlowFinancialMovementReleases {
  const AppRoutesMainFlowFinancialMovementReleases();

  final String route = '/main_flow/financial_movement/releases/';
}

class AppRoutesMainFlowHome {
  const AppRoutesMainFlowHome();

  final String route = '/main_flow/home/';
}

class AppRoutesMainFlowProfile {
  const AppRoutesMainFlowProfile();

  final String route = '/main_flow/profile/';
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
}

class AppRoutesMainFlowRegisterCategoriesCreateAndEditCategory {
  const AppRoutesMainFlowRegisterCategoriesCreateAndEditCategory();

  final String route =
      '/main_flow/register/categories/create_and_edit_category/';
  final AppRoutesMainFlowRegisterCategoriesCreateAndEditCategoryImportCategories
  importCategories =
      const AppRoutesMainFlowRegisterCategoriesCreateAndEditCategoryImportCategories();
}

class AppRoutesMainFlowRegisterCategoriesCreateAndEditCategoryImportCategories {
  const AppRoutesMainFlowRegisterCategoriesCreateAndEditCategoryImportCategories();

  final String route =
      '/main_flow/register/categories/create_and_edit_category/import_categories/';
}
