class AppRoutes {
  const AppRoutes._();

  static const startup = '/startup';
  static const onboarding = '/onboarding';
  static const accessRestricted = '/access-restricted';
  static const masterPanel = '/master-panel';
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const chat = '/chat';
  static const reports = '/reports';
  static const profile = '/profile';
  static const addTransaction = '/transaction/add';
  static const importTransactions = '/transactions/import';
  static const transactionDetail = '/transaction/:id';
  static const accounts = '/accounts';
  static const addAccount = '/accounts/add';
  static const importAccounts = '/accounts/import';
  static const accountDetail = '/account/:id';
  static const categories = '/categories';
  static const addCategory = '/category/add';
  static const editCategory = '/category/edit';
  static const importCategories = '/categories/import';
  static const bills = '/bills';
  static const addBill = '/bill/add';
  static const editBill = '/bill/edit';
  static const planning = '/planning';
  // Budgets keeps its standalone routes so deep-links and existing
  // navigation pushes continue to work. The shell tab points at
  // [planning] which hosts both budgets and the 50/30/20 detail view as
  // sub-tabs (see specs/fifty_thirty_twenty.md).
  static const budgets = '/budgets';
  static const addBudget = '/budget/add';
  static const editBudget = '/budget/edit';
  static const fiftyThirtyTwenty = '/fifty-thirty-twenty';

  static String transactionById(String id) => '/transaction/$id';
  static String accountById(String id) => '/account/$id';
}
