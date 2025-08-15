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
  final AppRoutesMainFlowHome home = const AppRoutesMainFlowHome();
}

class AppRoutesMainFlowHome {
  const AppRoutesMainFlowHome();

  final String route = '/main_flow/home/';
}
