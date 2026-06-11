class AppRoutes {
  const AppRoutes._();

  static const startup = '/startup';
  static const onboarding = '/onboarding';
  static const accessRestricted = '/access-restricted';
  static const masterPanel = '/master-panel';
  static const dashboard = '/';
  static const chat = '/chat';
  static const profile = '/profile';
  static const addTransaction = '/transaction/add';
  static const importTransactions = '/transactions/import';
  static const accounts = '/accounts';
  static const addAccount = '/accounts/add';
  static const importAccounts = '/accounts/import';
  static const accountDetail = '/account/:id';
  static const categories = '/categories';
  static const addCategory = '/category/add';
  static const editCategory = '/category/edit';
  static const importCategories = '/categories/import';
  static const legacyBills = '/bills';
  static const payablesReceivables = '/payables-receivables';
  static const paidAndReceived = '/paid-and-received';
  static const payables = '/payables';
  static const receivables = '/receivables';
  static const paidAccounts = '/paid-accounts';
  static const receivedAccounts = '/received-accounts';
  static const planning = '/planning';
  // Budgets keeps its standalone routes so deep-links and existing
  // navigation pushes continue to work. The shell tab points at
  // [planning] which hosts both budgets and the 50/30/20 detail view as
  // sub-tabs (see docs/specs/fifty_thirty_twenty.md).
  static const budgets = '/budgets';
  static const addBudget = '/budget/add';
  static const editBudget = '/budget/edit';
  static const fiftyThirtyTwenty = '/fifty-thirty-twenty';
  static const investments = '/investments';
  static const assetClass = '/investments/class/edit';
  static const assetClassDetail = '/investments/class/:id';

  static String assetClassDetailById(String id) => '/investments/class/$id';

  static String accountById(String id) => '/account/$id';
}
