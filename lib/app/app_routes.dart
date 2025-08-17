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
}

class AppRoutesMainFlowAccounts {
  const AppRoutesMainFlowAccounts();

  final String route = '/main_flow/accounts/';
  final AppRoutesMainFlowAccountsCreateAndEditAccount createAndEditAccount =
      const AppRoutesMainFlowAccountsCreateAndEditAccount();
  final AppRoutesMainFlowAccountsNewAccounts newAccounts =
      const AppRoutesMainFlowAccountsNewAccounts();
}

class AppRoutesMainFlowAccountsCreateAndEditAccount {
  const AppRoutesMainFlowAccountsCreateAndEditAccount();

  final String route = '/main_flow/accounts/create_and_edit_account/';
}

class AppRoutesMainFlowAccountsNewAccounts {
  const AppRoutesMainFlowAccountsNewAccounts();

  final String route = '/main_flow/accounts/new_accounts/';
}

class AppRoutesMainFlowCategories {
  const AppRoutesMainFlowCategories();

  final String route = '/main_flow/categories/';
}

class AppRoutesMainFlowHome {
  const AppRoutesMainFlowHome();

  final String route = '/main_flow/home/';
}
