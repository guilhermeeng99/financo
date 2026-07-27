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
  // Surviving allocation-class management (form reached from the V2
  // allocation page); the rest of the legacy /investments module was removed.
  static const assetClass = '/investments/class/edit';

  // V2 investing module.
  static const investingOverview = '/investing/overview';
  static const investingAllocation = '/investing/allocation';
  static const allocationClassDetail = '/investing/allocation/class/:id';
  static const institutions = '/investing/institutions';
  static const addInstitution = '/investing/institution/add';
  static const editInstitution = '/investing/institution/edit';
  static const assets = '/investing/assets';
  static const addAsset = '/investing/asset/add';
  static const editAsset = '/investing/asset/edit';
  static const investingTransactions = '/investing/transactions';
  static const addInvestingTransaction = '/investing/transaction/add';
  static const editInvestingTransaction = '/investing/transaction/edit';
  static const importInvestingAssets = '/investing/assets/import';
  static const importInvestingTransactions = '/investing/transactions/import';

  /// One-time guided account/investing migration (F8.5/F9.6).
  static const migration = '/migration';

  static String accountById(String id) => '/account/$id';

  static String allocationClassById(String id) =>
      '/investing/allocation/class/$id';
}
