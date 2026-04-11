class AppRoutes {
  const AppRoutes._();

  static const startup = '/startup';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const chat = '/chat';
  static const reports = '/reports';
  static const profile = '/profile';
  static const addTransaction = '/transaction/add';
  static const transactionDetail = '/transaction/:id';
  static const accounts = '/accounts';
  static const addAccount = '/account/add';
  static const accountDetail = '/account/:id';
  static const categories = '/categories';

  static String transactionById(String id) => '/transaction/$id';
  static String accountById(String id) => '/account/$id';
}
