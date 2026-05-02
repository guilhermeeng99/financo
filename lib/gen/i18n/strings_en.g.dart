///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsGeneralEn general = TranslationsGeneralEn._(_root);
	late final TranslationsValidatorsEn validators = TranslationsValidatorsEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn._(_root);
	late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	late final TranslationsDashboardEn dashboard = TranslationsDashboardEn._(_root);
	late final TranslationsTransactionsEn transactions = TranslationsTransactionsEn._(_root);
	late final TranslationsAccountsEn accounts = TranslationsAccountsEn._(_root);
	late final TranslationsCategoriesEn categories = TranslationsCategoriesEn._(_root);
	late final TranslationsChatEn chat = TranslationsChatEn._(_root);
	late final TranslationsReportsEn reports = TranslationsReportsEn._(_root);
	late final TranslationsBillsEn bills = TranslationsBillsEn._(_root);
	late final TranslationsBudgetsEn budgets = TranslationsBudgetsEn._(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
	late final TranslationsStartupEn startup = TranslationsStartupEn._(_root);
}

// Path: general
class TranslationsGeneralEn {
	TranslationsGeneralEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'An error occurred'
	String get error => 'An error occurred';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'or'
	String get or => 'or';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Default'
	String get defaultLabel => 'Default';
}

// Path: validators
class TranslationsValidatorsEn {
	TranslationsValidatorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This field is required.'
	String get required => 'This field is required.';

	/// en: 'Email is required.'
	String get emailRequired => 'Email is required.';

	/// en: 'Enter a valid email.'
	String get emailInvalid => 'Enter a valid email.';

	/// en: 'Password is required.'
	String get passwordRequired => 'Password is required.';

	/// en: 'Password must be at least 6 characters.'
	String get passwordMinLength => 'Password must be at least 6 characters.';

	/// en: 'Amount is required.'
	String get amountRequired => 'Amount is required.';

	/// en: 'Enter a valid amount.'
	String get amountInvalid => 'Enter a valid amount.';

	/// en: 'Date cannot be in the future.'
	String get dateInFuture => 'Date cannot be in the future.';

	/// en: 'Select an account'
	String get selectAccount => 'Select an account';

	/// en: 'Select a category'
	String get selectCategory => 'Select a category';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign In'
	String get signIn => 'Sign In';

	/// en: 'Sign Up'
	String get signUp => 'Sign Up';

	/// en: 'Sign Out'
	String get signOut => 'Sign Out';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'your@email.com'
	String get emailHint => 'your@email.com';

	/// en: 'Password'
	String get password => 'Password';

	/// en: '••••••••'
	String get passwordHint => '••••••••';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Your full name'
	String get nameHint => 'Your full name';

	/// en: 'Forgot password?'
	String get forgotPassword => 'Forgot password?';

	/// en: 'Don't have an account? Sign Up'
	String get noAccount => 'Don\'t have an account? Sign Up';

	/// en: 'Already have an account? Sign In'
	String get hasAccount => 'Already have an account? Sign In';

	/// en: 'Welcome back'
	String get welcomeBack => 'Welcome back';

	/// en: 'Sign in to your account'
	String get signInSubtitle => 'Sign in to your account';

	/// en: 'Create account'
	String get createAccount => 'Create account';

	/// en: 'Start managing your finances today'
	String get signUpSubtitle => 'Start managing your finances today';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Take control of your personal finances with smart tracking and AI assistance.'
	String get tagline => 'Take control of your personal finances\nwith smart tracking and AI assistance.';

	/// en: 'Track Your Finances'
	String get step1Title => 'Track Your Finances';

	/// en: 'Log income and expenses effortlessly. Keep a clear view of where your money goes.'
	String get step1Body => 'Log income and expenses effortlessly. Keep a clear view of where your money goes.';

	/// en: 'AI-Powered Entry'
	String get step2Title => 'AI-Powered Entry';

	/// en: 'Just type naturally — our AI chat extracts transaction data for you automatically.'
	String get step2Body => 'Just type naturally — our AI chat extracts transaction data for you automatically.';

	/// en: 'Insightful Reports'
	String get step3Title => 'Insightful Reports';

	/// en: 'Beautiful charts and summaries help you understand your spending habits.'
	String get step3Body => 'Beautiful charts and summaries help you understand your spending habits.';

	/// en: 'Get Started'
	String get getStarted => 'Get Started';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Skip'
	String get skip => 'Skip';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dashboard'
	String get dashboard => 'Dashboard';

	/// en: 'Transactions'
	String get transactions => 'Transactions';

	/// en: 'Chat'
	String get chat => 'Chat';

	/// en: 'Reports'
	String get reports => 'Reports';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Bills'
	String get bills => 'Bills';

	/// en: 'Orçamento'
	String get budgets => 'Orçamento';
}

// Path: dashboard
class TranslationsDashboardEn {
	TranslationsDashboardEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dashboard'
	String get title => 'Dashboard';

	/// en: 'Total Balance'
	String get totalBalance => 'Total Balance';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Result'
	String get netResult => 'Result';

	/// en: 'Recent Transactions'
	String get recentTransactions => 'Recent Transactions';

	/// en: 'See all'
	String get seeAll => 'See all';

	/// en: 'This month'
	String get thisMonth => 'This month';

	/// en: 'No transactions yet'
	String get noTransactionsYet => 'No transactions yet';

	/// en: 'Account Balances'
	String get accountBalances => 'Account Balances';

	/// en: 'Month Result'
	String get monthResult => 'Month Result';

	/// en: 'Expenses by Category'
	String get expensesByCategory => 'Expenses by Category';

	/// en: 'Income by Category'
	String get incomeByCategory => 'Income by Category';

	/// en: 'No accounts registered yet'
	String get noAccountsYet => 'No accounts registered yet';

	/// en: 'Credit Card Balance'
	String get creditCardBalance => 'Credit Card Balance';

	/// en: 'No credit cards registered yet'
	String get noCreditCardsYet => 'No credit cards registered yet';

	/// en: 'No expenses this month'
	String get noExpensesYet => 'No expenses this month';

	/// en: 'No income this month'
	String get noIncomeYet => 'No income this month';

	/// en: 'Total Expenses'
	String get totalExpenses => 'Total Expenses';

	/// en: 'Total Income'
	String get totalIncome => 'Total Income';

	/// en: 'Transaction list'
	String get transactionList => 'Transaction list';

	/// en: 'Subcategories'
	String get subcategories => 'Subcategories';

	/// en: 'No subcategories'
	String get noSubcategories => 'No subcategories';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Close'
	String get close => 'Close';
}

// Path: transactions
class TranslationsTransactionsEn {
	TranslationsTransactionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transactions'
	String get title => 'Transactions';

	/// en: 'No transactions. Add your first transaction to get started.'
	String get empty => 'No transactions. Add your first transaction to get started.';

	/// en: 'New Transaction'
	String get addTransaction => 'New Transaction';

	/// en: 'Edit Transaction'
	String get editTransaction => 'Edit Transaction';

	/// en: 'Confirm payment'
	String get confirmPaymentTitle => 'Confirm payment';

	/// en: 'Confirm receipt'
	String get confirmReceiptTitle => 'Confirm receipt';

	/// en: 'Transaction Details'
	String get transactionDetails => 'Transaction Details';

	/// en: 'Transaction'
	String get transaction => 'Transaction';

	/// en: 'Transaction not found'
	String get transactionNotFound => 'Transaction not found';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expense'
	String get expense => 'Expense';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Amount'
	String get amountLabel => 'Amount';

	/// en: '0.00'
	String get amountHint => '0.00';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'e.g. Grocery shopping'
	String get descriptionHint => 'e.g. Grocery shopping';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Notes'
	String get notes => 'Notes';

	/// en: 'Notes (optional)'
	String get notesOptional => 'Notes (optional)';

	/// en: 'Additional details...'
	String get notesHint => 'Additional details...';

	/// en: 'Transfer'
	String get transfer => 'Transfer';

	/// en: 'Source account'
	String get sourceAccount => 'Source account';

	/// en: 'Destination account'
	String get destinationAccount => 'Destination account';

	/// en: 'Transfer created'
	String get transferCreated => 'Transfer created';

	/// en: 'Delete Transaction'
	String get deleteTransaction => 'Delete Transaction';

	/// en: 'Are you sure you want to delete this transaction?'
	String get deleteConfirm => 'Are you sure you want to delete this transaction?';

	/// en: 'Transaction updated'
	String get transactionUpdated => 'Transaction updated';

	/// en: 'Transaction created'
	String get transactionCreated => 'Transaction created';

	/// en: 'Transaction saved!'
	String get saved => 'Transaction saved!';

	/// en: 'Transaction deleted.'
	String get deleted => 'Transaction deleted.';

	/// en: 'Import transactions'
	String get importCsv => 'Import transactions';

	/// en: 'Import transactions from CSV'
	String get importCsvIntroTitle => 'Import transactions from CSV';

	/// en: 'Your file must follow the expected format (columns Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência — where Tipo is Despesa/Receita/Transferência/Pagamento). Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência — where Tipo is Despesa/Receita/Transferência/Pagamento). Download the example to see how it works.';

	/// en: 'Download example'
	String get importCsvDownloadExample => 'Download example';

	/// en: 'Select file'
	String get importCsvSelectFile => 'Select file';

	/// en: 'Example saved.'
	String get importCsvExampleDownloaded => 'Example saved.';

	/// en: 'Couldn't save the example file.'
	String get importCsvExampleFailed => 'Couldn\'t save the example file.';

	/// en: 'Couldn't import the CSV'
	String get importCsvErrorTitle => 'Couldn\'t import the CSV';

	/// en: 'Importing transactions...'
	String get importInProgressTitle => 'Importing transactions...';

	/// en: '$processed of $total'
	String importProgressCounter({required Object processed, required Object total}) => '${processed} of ${total}';

	/// en: 'Fill in: $fields'
	String importMissingFields({required Object fields}) => 'Fill in: ${fields}';

	/// en: 'Review import: $count transactions will be created.'
	String importReview({required Object count}) => 'Review import: ${count} transactions will be created.';

	/// en: 'Missing categories:'
	String get importMissingCategories => 'Missing categories:';

	/// en: 'Missing accounts:'
	String get importMissingAccounts => 'Missing accounts:';

	/// en: '$count rows were skipped (invalid format).'
	String importSkippedRows({required Object count}) => '${count} rows were skipped (invalid format).';

	/// en: 'Imported $imported transactions. Skipped $skipped rows.'
	String importSuccess({required Object imported, required Object skipped}) => 'Imported ${imported} transactions. Skipped ${skipped} rows.';

	/// en: 'Cannot import: some categories or accounts were not found.'
	String get importBlocked => 'Cannot import: some categories or accounts were not found.';

	/// en: '$count transfers'
	String importTransfers({required Object count}) => '${count} transfers';

	/// en: '$count expenses'
	String importExpenses({required Object count}) => '${count} expenses';

	/// en: '$count incomes'
	String importIncomes({required Object count}) => '${count} incomes';

	/// en: 'Review import'
	String get importPageTitle => 'Review import';

	/// en: 'Tap a row to edit · trash to remove'
	String get importPageSubtitle => 'Tap a row to edit · trash to remove';

	/// en: 'Expense ($count)'
	String importTabExpense({required Object count}) => 'Expense (${count})';

	/// en: 'Income ($count)'
	String importTabIncome({required Object count}) => 'Income (${count})';

	/// en: 'Transfer ($count)'
	String importTabTransfer({required Object count}) => 'Transfer (${count})';

	/// en: 'Nothing to import in this tab.'
	String get importEmptyTab => 'Nothing to import in this tab.';

	/// en: 'Edit transaction'
	String get importEditTitle => 'Edit transaction';

	/// en: 'Nothing left to import.'
	String get importNothingLeft => 'Nothing left to import.';

	/// en: 'Import $count transactions'
	String importSubmit({required Object count}) => 'Import ${count} transactions';

	/// en: 'Resolve missing references before importing:'
	String get importMissingAfterEditPrefix => 'Resolve missing references before importing:';

	/// en: '$count rows skipped'
	String importSkippedRowsPill({required Object count}) => '${count} rows skipped';
}

// Path: accounts
class TranslationsAccountsEn {
	TranslationsAccountsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Accounts'
	String get title => 'Accounts';

	/// en: 'New Account'
	String get addAccount => 'New Account';

	/// en: 'Edit Account'
	String get editAccount => 'Edit Account';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Account not found'
	String get accountNotFound => 'Account not found';

	/// en: 'Checking Account'
	String get checking => 'Checking Account';

	/// en: 'Credit Card'
	String get creditCard => 'Credit Card';

	/// en: 'Checking'
	String get checkingShort => 'Checking';

	/// en: 'Account Nickname'
	String get name => 'Account Nickname';

	/// en: 'e.g. Nubank Gui'
	String get nameHint => 'e.g. Nubank Gui';

	/// en: 'Bank'
	String get bank => 'Bank';

	/// en: 'e.g. Nubank'
	String get bankHint => 'e.g. Nubank';

	/// en: 'Others'
	String get bankOthers => 'Others';

	/// en: 'Linked Checking Account'
	String get linkedAccount => 'Linked Checking Account';

	/// en: 'Balance'
	String get balance => 'Balance';

	/// en: 'Current Balance'
	String get currentBalance => 'Current Balance';

	/// en: 'Initial Balance (R\$)'
	String get balanceLabel => 'Initial Balance (R\$)';

	/// en: '0.00'
	String get balanceHint => '0.00';

	/// en: 'Credit Limit'
	String get creditLimit => 'Credit Limit';

	/// en: 'Credit Limit (R\$)'
	String get creditLimitLabel => 'Credit Limit (R\$)';

	/// en: '0.00'
	String get creditLimitHint => '0.00';

	/// en: 'Closing Day'
	String get closingDay => 'Closing Day';

	/// en: 'Due Day'
	String get dueDay => 'Due Day';

	/// en: 'Available Credit'
	String get availableCredit => 'Available Credit';

	/// en: 'Current bill'
	String get currentBill => 'Current bill';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'No accounts. Add your first bank account or credit card.'
	String get empty => 'No accounts. Add your first bank account or credit card.';

	/// en: 'Add your bank accounts and credit cards.'
	String get emptySubtitle => 'Add your bank accounts and credit cards.';

	/// en: 'Account updated'
	String get accountUpdated => 'Account updated';

	/// en: 'Account created'
	String get accountCreated => 'Account created';

	/// en: 'Account saved!'
	String get saved => 'Account saved!';

	/// en: 'Account deleted.'
	String get deleted => 'Account deleted.';

	/// en: 'Are you sure you want to delete this account?'
	String get deleteConfirm => 'Are you sure you want to delete this account?';

	/// en: 'Monthly Summary'
	String get statement => 'Monthly Summary';

	/// en: 'Income'
	String get monthIncome => 'Income';

	/// en: 'Expenses'
	String get monthExpenses => 'Expenses';

	/// en: 'Result'
	String get monthResult => 'Result';

	/// en: 'No transactions in this period'
	String get noTransactionsInPeriod => 'No transactions in this period';

	/// en: 'Type'
	String get formSectionType => 'Type';

	/// en: 'Details'
	String get formSectionDetails => 'Details';

	/// en: 'Credit card'
	String get formSectionCreditCard => 'Credit card';

	/// en: 'Closing day'
	String get pickClosingDay => 'Closing day';

	/// en: 'Due day'
	String get pickDueDay => 'Due day';

	/// en: 'Linked checking account'
	String get pickLinkedAccount => 'Linked checking account';

	/// en: 'Pick a bank'
	String get pickBank => 'Pick a bank';

	/// en: 'Search bank'
	String get bankSearchHint => 'Search bank';

	/// en: 'No banks match your search.'
	String get bankSearchNoResults => 'No banks match your search.';

	/// en: 'Create a checking account first.'
	String get noLinkedCandidates => 'Create a checking account first.';

	/// en: 'Add your first account'
	String get addFirst => 'Add your first account';

	/// en: 'No accounts yet'
	String get emptyTitle => 'No accounts yet';

	/// en: 'Import accounts'
	String get importCsv => 'Import accounts';

	/// en: 'Import accounts from CSV'
	String get importCsvIntroTitle => 'Import accounts from CSV';

	/// en: 'Your file must follow the expected format (columns Nome, Saldo inicial, Tipo, Banco, Limite, Próximo Vencimento, Fechamento — where Tipo is Conta Corrente or Cartão de Crédito). Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Nome, Saldo inicial, Tipo, Banco, Limite, Próximo Vencimento, Fechamento — where Tipo is Conta Corrente or Cartão de Crédito). Download the example to see how it works.';

	/// en: 'Download example'
	String get importCsvDownloadExample => 'Download example';

	/// en: 'Select file'
	String get importCsvSelectFile => 'Select file';

	/// en: 'Example saved.'
	String get importCsvExampleDownloaded => 'Example saved.';

	/// en: 'Couldn't save the example file.'
	String get importCsvExampleFailed => 'Couldn\'t save the example file.';

	/// en: 'Couldn't import the CSV'
	String get importCsvErrorTitle => 'Couldn\'t import the CSV';

	/// en: 'Review import'
	String get importPageTitle => 'Review import';

	/// en: 'Tap a row to edit · trash to remove'
	String get importPageSubtitle => 'Tap a row to edit · trash to remove';

	/// en: 'Checking ($count)'
	String importTabChecking({required Object count}) => 'Checking (${count})';

	/// en: 'Credit card ($count)'
	String importTabCreditCard({required Object count}) => 'Credit card (${count})';

	/// en: 'Nothing to import in this tab.'
	String get importEmptyTab => 'Nothing to import in this tab.';

	/// en: 'Will be skipped (already exists)'
	String get importDuplicatesHeader => 'Will be skipped (already exists)';

	/// en: 'Edit account'
	String get importEditTitle => 'Edit account';

	/// en: 'Nothing left to import.'
	String get importNothingLeft => 'Nothing left to import.';

	/// en: 'Import $count accounts'
	String importSubmit({required Object count}) => 'Import ${count} accounts';

	/// en: 'Pick a linked checking account for:'
	String get importMissingLinkPrefix => 'Pick a linked checking account for:';

	/// en: 'Imported $imported accounts. Skipped $duplicates duplicates.'
	String importSuccessDetailed({required Object imported, required Object duplicates}) => 'Imported ${imported} accounts. Skipped ${duplicates} duplicates.';

	/// en: 'Importing accounts...'
	String get importInProgressTitle => 'Importing accounts...';

	/// en: '$processed of $total'
	String importProgressCounter({required Object processed, required Object total}) => '${processed} of ${total}';

	/// en: 'Fill in: $fields'
	String importMissingFields({required Object fields}) => 'Fill in: ${fields}';
}

// Path: categories
class TranslationsCategoriesEn {
	TranslationsCategoriesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Categories'
	String get title => 'Categories';

	/// en: 'Add Category'
	String get addCategory => 'Add Category';

	/// en: 'Edit Category'
	String get editCategory => 'Edit Category';

	/// en: 'Category name'
	String get name => 'Category name';

	/// en: 'e.g. Groceries'
	String get nameHint => 'e.g. Groceries';

	/// en: 'Income'
	String get incomeType => 'Income';

	/// en: 'Expense'
	String get expenseType => 'Expense';

	/// en: 'Both'
	String get bothType => 'Both';

	/// en: 'No categories. Categories will appear here.'
	String get empty => 'No categories. Categories will appear here.';

	/// en: 'Category saved!'
	String get saved => 'Category saved!';

	/// en: 'Category deleted.'
	String get deleted => 'Category deleted.';

	/// en: 'Are you sure you want to delete this category?'
	String get deleteConfirm => 'Are you sure you want to delete this category?';

	/// en: 'Select a category to reassign transactions to:'
	String get reassignPrompt => 'Select a category to reassign transactions to:';

	/// en: 'Category updated'
	String get categoryUpdated => 'Category updated';

	/// en: 'Category created'
	String get categoryCreated => 'Category created';

	/// en: 'Default categories cannot be deleted.'
	String get cannotDeleteDefault => 'Default categories cannot be deleted.';

	/// en: 'Create another category before deleting this one.'
	String get cannotDeleteLast => 'Create another category before deleting this one.';

	/// en: 'Select icon'
	String get selectIcon => 'Select icon';

	/// en: 'Select color'
	String get selectColor => 'Select color';

	/// en: 'Choose icon'
	String get chooseIcon => 'Choose icon';

	/// en: 'Search (e.g. car, carro)'
	String get iconSearchHint => 'Search (e.g. car, carro)';

	/// en: 'No icons match your search.'
	String get iconSearchNoResults => 'No icons match your search.';

	/// en: 'Parent category'
	String get parentCategory => 'Parent category';

	/// en: 'No parent'
	String get noParent => 'No parent';

	/// en: 'Subcategory'
	String get subcategoryLabel => 'Subcategory';

	/// en: 'Import categories'
	String get importCsv => 'Import categories';

	/// en: 'Import categories from CSV'
	String get importCsvIntroTitle => 'Import categories from CSV';

	/// en: 'Your file must follow the expected format (columns Categoria, Subcategoria, Tipo — where Tipo is Receita/Despesa or Income/Expense). Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Categoria, Subcategoria, Tipo — where Tipo is Receita/Despesa or Income/Expense). Download the example to see how it works.';

	/// en: 'Download example'
	String get importCsvDownloadExample => 'Download example';

	/// en: 'Select file'
	String get importCsvSelectFile => 'Select file';

	/// en: 'Example saved.'
	String get importCsvExampleDownloaded => 'Example saved.';

	/// en: 'Couldn't save the example file.'
	String get importCsvExampleFailed => 'Couldn\'t save the example file.';

	/// en: 'Couldn't import the CSV'
	String get importCsvErrorTitle => 'Couldn\'t import the CSV';

	/// en: 'Imported $count categories.'
	String importSuccess({required Object count}) => 'Imported ${count} categories.';

	/// en: 'Review import: $arg new items will be created.'
	String importReview({required Object arg}) => 'Review import: ${arg} new items will be created.';

	/// en: '$arg duplicate items will be skipped.'
	String importDuplicates({required Object arg}) => '${arg} duplicate items will be skipped.';

	/// en: 'Imported $imported items. Skipped $duplicates duplicates.'
	String importSuccessDetailed({required Object imported, required Object duplicates}) => 'Imported ${imported} items. Skipped ${duplicates} duplicates.';

	/// en: 'Review import'
	String get importPageTitle => 'Review import';

	/// en: 'Tap an item to edit · swipe trash to remove'
	String get importPageSubtitle => 'Tap an item to edit · swipe trash to remove';

	/// en: 'Expense ($count)'
	String importTabExpense({required Object count}) => 'Expense (${count})';

	/// en: 'Income ($count)'
	String importTabIncome({required Object count}) => 'Income (${count})';

	/// en: 'Nothing to import in this tab.'
	String get importEmptyTab => 'Nothing to import in this tab.';

	/// en: 'Will be skipped (already exists)'
	String get importDuplicatesHeader => 'Will be skipped (already exists)';

	/// en: 'Edit category'
	String get importEditTitle => 'Edit category';

	/// en: 'Remove $name and its $count subcategories?'
	String importDeleteRoot({required Object name, required Object count}) => 'Remove ${name} and its ${count} subcategories?';

	/// en: 'Remove'
	String get importDeleteRootConfirm => 'Remove';

	/// en: 'Nothing left to import.'
	String get importNothingLeft => 'Nothing left to import.';

	/// en: 'Import $count items'
	String importSubmit({required Object count}) => 'Import ${count} items';

	/// en: 'Importing categories...'
	String get importInProgressTitle => 'Importing categories...';

	/// en: '$processed of $total'
	String importProgressCounter({required Object processed, required Object total}) => '${processed} of ${total}';

	/// en: 'Type'
	String get formSectionType => 'Type';

	/// en: 'Details'
	String get formSectionDetails => 'Details';

	/// en: 'Appearance'
	String get formSectionAppearance => 'Appearance';

	/// en: 'Parent category'
	String get pickParent => 'Parent category';

	/// en: 'Search categories'
	String get searchHint => 'Search categories';

	/// en: 'No categories match your search.'
	String get searchNoResults => 'No categories match your search.';

	/// en: 'None'
	String get noParentChosen => 'None';

	/// en: 'Add your first category'
	String get addFirst => 'Add your first category';

	/// en: 'No categories yet'
	String get emptyTitle => 'No categories yet';
}

// Path: chat
class TranslationsChatEn {
	TranslationsChatEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'AI Assistant'
	String get title => 'AI Assistant';

	/// en: 'Type a message...'
	String get placeholder => 'Type a message...';

	/// en: 'Hi! I'm your financial assistant.'
	String get welcomeTitle => 'Hi! I\'m your financial assistant.';

	/// en: 'Tell me about your transactions and I'll help you record them.'
	String get welcomeBody => 'Tell me about your transactions and I\'ll help you record them.';

	/// en: 'I detected the following transaction. Does this look correct?'
	String get confirmPrompt => 'I detected the following transaction. Does this look correct?';

	/// en: 'Transaction saved!'
	String get confirmed => 'Transaction saved!';

	/// en: 'Transaction cancelled.'
	String get cancelled => 'Transaction cancelled.';

	/// en: 'Sorry, I couldn't understand that. Could you try again?'
	String get error => 'Sorry, I couldn\'t understand that. Could you try again?';

	/// en: 'Financo AI'
	String get aiName => 'Financo AI';

	/// en: 'Online'
	String get online => 'Online';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: 'via WhatsApp'
	String get viaWhatsapp => 'via WhatsApp';

	/// en: 'Try asking'
	String get tryAsking => 'Try asking';

	/// en: 'I spent R$ 30 at the bakery'
	String get suggestion1 => 'I spent R\$ 30 at the bakery';

	/// en: 'How much do I have on my Nubank account?'
	String get suggestion2 => 'How much do I have on my Nubank account?';

	/// en: 'Show my overdue bills'
	String get suggestion3 => 'Show my overdue bills';

	/// en: 'Create a category called Leisure'
	String get suggestion4 => 'Create a category called Leisure';

	late final TranslationsChatActionEn action = TranslationsChatActionEn._(_root);
	late final TranslationsChatAudioEn audio = TranslationsChatAudioEn._(_root);
	late final TranslationsChatImageEn image = TranslationsChatImageEn._(_root);
}

// Path: reports
class TranslationsReportsEn {
	TranslationsReportsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reports'
	String get title => 'Reports';

	/// en: 'Income vs Expenses'
	String get incomeVsExpenses => 'Income vs Expenses';

	/// en: 'Expenses by Category'
	String get expensesByCategory => 'Expenses by Category';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Net'
	String get net => 'Net';

	/// en: 'Current month'
	String get currentMonth => 'Current month';

	/// en: 'Last month'
	String get lastMonth => 'Last month';

	/// en: 'Custom range'
	String get customRange => 'Custom range';

	/// en: 'Category Breakdown'
	String get categoryBreakdown => 'Category Breakdown';

	/// en: 'Monthly Comparison'
	String get monthlyComparison => 'Monthly Comparison';

	/// en: 'Balance Evolution'
	String get balanceEvolution => 'Balance Evolution';

	/// en: 'Not enough data to generate reports.'
	String get noData => 'Not enough data to generate reports.';
}

// Path: bills
class TranslationsBillsEn {
	TranslationsBillsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bills'
	String get title => 'Bills';

	/// en: 'No bills. Add a bill to get reminders before it's due.'
	String get empty => 'No bills. Add a bill to get reminders before it\'s due.';

	/// en: 'New Bill'
	String get addBill => 'New Bill';

	/// en: 'Edit Bill'
	String get editBill => 'Edit Bill';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'e.g. Electricity'
	String get descriptionHint => 'e.g. Electricity';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Amount'
	String get amountLabel => 'Amount';

	/// en: 'Due date'
	String get dueDate => 'Due date';

	/// en: 'Recurrence'
	String get recurrence => 'Recurrence';

	/// en: 'One-time'
	String get oneShot => 'One-time';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'To pay'
	String get typePayable => 'To pay';

	/// en: 'To receive'
	String get typeReceivable => 'To receive';

	/// en: 'All'
	String get filterAll => 'All';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Pick a category'
	String get categoryRequired => 'Pick a category';

	/// en: 'Notes (optional)'
	String get notes => 'Notes (optional)';

	/// en: 'Additional details...'
	String get notesHint => 'Additional details...';

	/// en: 'Mark as paid'
	String get markAsPaid => 'Mark as paid';

	/// en: 'Mark as received'
	String get markAsReceived => 'Mark as received';

	/// en: 'Paid'
	String get paid => 'Paid';

	/// en: 'Received'
	String get received => 'Received';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Overdue'
	String get overdue => 'Overdue';

	/// en: 'Due today'
	String get dueToday => 'Due today';

	/// en: 'Upcoming'
	String get upcoming => 'Upcoming';

	/// en: 'Overdue'
	String get overdueGroup => 'Overdue';

	/// en: 'Today'
	String get todayGroup => 'Today';

	/// en: 'Upcoming'
	String get upcomingGroup => 'Upcoming';

	/// en: 'Settled'
	String get paidGroup => 'Settled';

	/// en: 'Are you sure you want to delete this bill?'
	String get deleteConfirm => 'Are you sure you want to delete this bill?';

	/// en: 'Bill created'
	String get billCreated => 'Bill created';

	/// en: 'Bill updated'
	String get billUpdated => 'Bill updated';

	/// en: 'Bill deleted'
	String get billDeleted => 'Bill deleted';

	/// en: 'Bill paid — transaction created'
	String get billPaid => 'Bill paid — transaction created';

	/// en: 'Payment received — transaction created'
	String get billReceived => 'Payment received — transaction created';

	/// en: 'Next month's bill scheduled'
	String get nextOccurrenceCreated => 'Next month\'s bill scheduled';

	/// en: 'This bill is already settled'
	String get alreadyPaid => 'This bill is already settled';

	/// en: 'Settled bills can't be edited'
	String get cannotEditPaid => 'Settled bills can\'t be edited';

	/// en: 'Pay bill'
	String get payDialogTitle => 'Pay bill';

	/// en: 'Register received payment'
	String get receiveDialogTitle => 'Register received payment';

	/// en: 'Account'
	String get selectAccount => 'Account';

	/// en: 'Category'
	String get selectCategory => 'Category';

	/// en: '$days days overdue'
	String daysOverdue({required Object days}) => '${days} days overdue';

	/// en: 'in $days days'
	String dueInDays({required Object days}) => 'in ${days} days';

	/// en: 'tomorrow'
	String get dueTomorrow => 'tomorrow';

	/// en: 'Create at least one expense category first.'
	String get noExpenseCategory => 'Create at least one expense category first.';

	/// en: 'Create at least one income category first.'
	String get noIncomeCategory => 'Create at least one income category first.';

	/// en: 'This month'
	String get summaryTitle => 'This month';

	/// en: 'Nothing due — you're all caught up'
	String get summaryAllCaughtUp => 'Nothing due — you\'re all caught up';

	/// en: '$count overdue'
	String overdueChip({required Object count}) => '${count} overdue';

	/// en: '$count pending'
	String pendingCount({required Object count}) => '${count} pending';

	/// en: 'No bills yet'
	String get emptyTitle => 'No bills yet';

	/// en: 'Add your first bill'
	String get addFirst => 'Add your first bill';

	/// en: 'Details'
	String get formDetails => 'Details';

	/// en: 'Classification'
	String get formClassification => 'Classification';

	/// en: 'Choose a category'
	String get pickCategory => 'Choose a category';

	late final TranslationsBillsNotificationEn notification = TranslationsBillsNotificationEn._(_root);
	late final TranslationsBillsMatchEn match = TranslationsBillsMatchEn._(_root);

	/// en: 'Pague a ocorrência atual primeiro'
	String get virtualBlocked => 'Pague a ocorrência atual primeiro';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Aplicar a quais ocorrências?'
	String get editScopeTitle => 'Aplicar a quais ocorrências?';

	/// en: 'Esta é uma cobrança recorrente. Você pode aplicar a alteração apenas a esta ocorrência ou também às futuras (não afeta as anteriores).'
	String get editScopeDescription => 'Esta é uma cobrança recorrente. Você pode aplicar a alteração apenas a esta ocorrência ou também às futuras (não afeta as anteriores).';

	/// en: 'Apenas esta'
	String get editScopeOnlyThis => 'Apenas esta';

	/// en: 'Esta e as subsequentes'
	String get editScopeAlsoSubsequents => 'Esta e as subsequentes';
}

// Path: budgets
class TranslationsBudgetsEn {
	TranslationsBudgetsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Orçamento'
	String get title => 'Orçamento';

	/// en: 'Novo orçamento'
	String get addBudget => 'Novo orçamento';

	/// en: 'Editar orçamento'
	String get editBudget => 'Editar orçamento';

	/// en: 'Categoria'
	String get category => 'Categoria';

	/// en: 'Escolha uma categoria'
	String get categoryHint => 'Escolha uma categoria';

	/// en: 'Selecione uma categoria'
	String get categoryRequired => 'Selecione uma categoria';

	/// en: 'Valor mensal'
	String get amount => 'Valor mensal';

	/// en: '0,00'
	String get amountHint => '0,00';

	/// en: 'Resumo do mês'
	String get summaryTitle => 'Resumo do mês';

	/// en: 'Total orçado'
	String get summaryCap => 'Total orçado';

	/// en: 'Gasto'
	String get summarySpent => 'Gasto';

	/// en: 'Disponível'
	String get summaryRemaining => 'Disponível';

	/// en: '$spent de $cap'
	String spentOf({required Object spent, required Object cap}) => '${spent} de ${cap}';

	/// en: '$value% usado'
	String percentageUsed({required Object value}) => '${value}% usado';

	/// en: 'Restam $value'
	String remainingOf({required Object value}) => 'Restam ${value}';

	/// en: 'Estourou em $value'
	String overBy({required Object value}) => 'Estourou em ${value}';

	/// en: 'Tranquilo'
	String get statusSafe => 'Tranquilo';

	/// en: 'Atenção'
	String get statusWarning => 'Atenção';

	/// en: 'Estourou'
	String get statusExceeded => 'Estourou';

	/// en: 'Tem certeza que deseja excluir este orçamento?'
	String get deleteConfirm => 'Tem certeza que deseja excluir este orçamento?';

	/// en: 'Orçamento criado'
	String get budgetCreated => 'Orçamento criado';

	/// en: 'Orçamento atualizado'
	String get budgetUpdated => 'Orçamento atualizado';

	/// en: 'Orçamento excluído'
	String get budgetDeleted => 'Orçamento excluído';

	/// en: 'Já existe um orçamento para essa categoria.'
	String get duplicateCategory => 'Já existe um orçamento para essa categoria.';

	/// en: 'Crie ao menos uma categoria de despesa antes.'
	String get noExpenseCategory => 'Crie ao menos uma categoria de despesa antes.';

	/// en: 'Todas as categorias já têm orçamento.'
	String get allCategoriesBudgeted => 'Todas as categorias já têm orçamento.';

	/// en: 'Tome controle dos seus gastos'
	String get emptyTitle => 'Tome controle dos seus gastos';

	/// en: 'Defina um teto mensal por categoria de despesa. O Finanço acompanha quanto você gastou, quanto ainda resta, e mostra de cara quando você está prestes a estourar.'
	String get emptyBody => 'Defina um teto mensal por categoria de despesa. O Finanço acompanha quanto você gastou, quanto ainda resta, e mostra de cara quando você está prestes a estourar.';

	/// en: 'Ex: R$ 1.500 em Alimentação, R$ 400 em Lazer, R$ 200 em Transporte.'
	String get emptyExample => 'Ex: R\$ 1.500 em Alimentação, R\$ 400 em Lazer, R\$ 200 em Transporte.';

	/// en: 'Criar primeiro orçamento'
	String get emptyAction => 'Criar primeiro orçamento';

	/// en: 'Detalhes'
	String get formDetails => 'Detalhes';

	/// en: 'Categoria'
	String get formCategorySection => 'Categoria';
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Edit Profile'
	String get editProfile => 'Edit Profile';

	/// en: 'Accounts'
	String get accounts => 'Accounts';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Bills'
	String get bills => 'Bills';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Light'
	String get themeLight => 'Light';

	/// en: 'Dark'
	String get themeDark => 'Dark';

	/// en: 'System'
	String get themeSystem => 'System';

	/// en: 'Are you sure you want to sign out?'
	String get signOutConfirm => 'Are you sure you want to sign out?';

	/// en: 'Clear all my data'
	String get clearData => 'Clear all my data';

	/// en: 'Delete transactions, chat, categories and accounts'
	String get clearDataDescription => 'Delete transactions, chat, categories and accounts';

	/// en: 'This will permanently delete all data from your account. Continue?'
	String get clearDataConfirm => 'This will permanently delete all data from your account. Continue?';

	/// en: 'Your account data was cleared.'
	String get clearDataSuccess => 'Your account data was cleared.';

	/// en: 'Download Android app'
	String get downloadApk => 'Download Android app';

	/// en: 'Install the mobile version on your Android device'
	String get downloadApkDescription => 'Install the mobile version on your Android device';

	/// en: 'Your data'
	String get sectionYourData => 'Your data';

	/// en: 'Preferences'
	String get sectionPreferences => 'Preferences';

	/// en: 'Get the app'
	String get sectionGetTheApp => 'Get the app';

	/// en: 'Account'
	String get sectionAccount => 'Account';

	/// en: 'Danger zone'
	String get sectionDangerZone => 'Danger zone';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Version'
	String get version => 'Version';
}

// Path: startup
class TranslationsStartupEn {
	TranslationsStartupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your finances, in flow.'
	String get tagline => 'Your finances, in flow.';

	/// en: 'Checking your account'
	String get stepCheckingAuth => 'Checking your account';

	/// en: 'Syncing your data'
	String get stepSyncingData => 'Syncing your data';

	/// en: 'Almost there'
	String get stepReady => 'Almost there';

	/// en: 'Something went wrong'
	String get errorTitle => 'Something went wrong';

	/// en: 'Try again'
	String get errorRetry => 'Try again';
}

// Path: chat.action
class TranslationsChatActionEn {
	TranslationsChatActionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm expense'
	String get transactionExpense => 'Confirm expense';

	/// en: 'Confirm income'
	String get transactionIncome => 'Confirm income';

	/// en: 'Confirm transfer'
	String get transfer => 'Confirm transfer';

	/// en: 'From'
	String get fieldFromAccount => 'From';

	/// en: 'To'
	String get fieldToAccount => 'To';

	/// en: 'Create account'
	String get accountCreate => 'Create account';

	/// en: 'Delete account'
	String get accountDelete => 'Delete account';

	/// en: 'Create category'
	String get categoryCreate => 'Create category';

	/// en: 'Delete category'
	String get categoryDelete => 'Delete category';

	/// en: 'Schedule bill'
	String get billCreate => 'Schedule bill';

	/// en: 'Update bill'
	String get billUpdate => 'Update bill';

	/// en: 'Mark bill as paid'
	String get billMarkPaid => 'Mark bill as paid';

	/// en: 'Delete bill'
	String get billDelete => 'Delete bill';

	/// en: 'Create budget'
	String get budgetCreate => 'Create budget';

	/// en: 'Update budget'
	String get budgetUpdate => 'Update budget';

	/// en: 'Delete budget'
	String get budgetDelete => 'Delete budget';

	/// en: 'Amount'
	String get fieldAmount => 'Amount';

	/// en: 'Description'
	String get fieldDescription => 'Description';

	/// en: 'Category'
	String get fieldCategory => 'Category';

	/// en: 'Account'
	String get fieldAccount => 'Account';

	/// en: 'Date'
	String get fieldDate => 'Date';

	/// en: 'Type'
	String get fieldType => 'Type';

	/// en: 'Bank'
	String get fieldBank => 'Bank';

	/// en: 'Credit limit'
	String get fieldCreditLimit => 'Credit limit';

	/// en: 'Closing day'
	String get fieldClosingDay => 'Closing day';

	/// en: 'Due day'
	String get fieldDueDay => 'Due day';

	/// en: 'Due date'
	String get fieldDueDate => 'Due date';

	/// en: 'Recurrence'
	String get fieldRecurrence => 'Recurrence';

	/// en: 'Name'
	String get fieldName => 'Name';

	/// en: 'Linked account'
	String get fieldLinkedAccount => 'Linked account';

	/// en: 'Initial balance'
	String get fieldBalance => 'Initial balance';

	/// en: 'Notes'
	String get fieldNotes => 'Notes';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirmed'
	String get statusConfirmed => 'Confirmed';

	/// en: 'Cancelled'
	String get statusCancelled => 'Cancelled';
}

// Path: chat.audio
class TranslationsChatAudioEn {
	TranslationsChatAudioEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Record voice message'
	String get start => 'Record voice message';

	/// en: 'Stop recording'
	String get stop => 'Stop recording';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Recording'
	String get recording => 'Recording';

	/// en: 'Transcribing...'
	String get transcribing => 'Transcribing...';

	/// en: 'Review transcript and send'
	String get reviewHint => 'Review transcript and send';

	/// en: 'Microphone permission required to record voice.'
	String get permissionDenied => 'Microphone permission required to record voice.';

	/// en: 'Failed to record audio'
	String get recordError => 'Failed to record audio';
}

// Path: chat.image
class TranslationsChatImageEn {
	TranslationsChatImageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Attach image'
	String get attach => 'Attach image';

	/// en: 'Take photo'
	String get takePhoto => 'Take photo';

	/// en: 'Choose from gallery'
	String get fromGallery => 'Choose from gallery';

	/// en: 'Remove image'
	String get remove => 'Remove image';

	/// en: 'Could not pick image'
	String get pickError => 'Could not pick image';
}

// Path: bills.notification
class TranslationsBillsNotificationEn {
	TranslationsBillsNotificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You have $count bill(s) to pay'
	String title({required Object count}) => 'You have ${count} bill(s) to pay';

	/// en: '$description ($amount) is due today'
	String bodyDueToday({required Object description, required Object amount}) => '${description} (${amount}) is due today';

	/// en: '$description ($amount) is overdue'
	String bodyOverdue({required Object description, required Object amount}) => '${description} (${amount}) is overdue';
}

// Path: bills.match
class TranslationsBillsMatchEn {
	TranslationsBillsMatchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$count possible payment(s) detected'
	String bannerTitle({required Object count}) => '${count} possible payment(s) detected';

	/// en: 'Tap to confirm if any existing transaction settles a pending bill'
	String get bannerSubtitle => 'Tap to confirm if any existing transaction settles a pending bill';

	/// en: 'Confirm payments'
	String get sheetTitle => 'Confirm payments';

	/// en: 'We found transactions that could be paying your pending bills. Confirm one by one.'
	String get sheetIntro => 'We found transactions that could be paying your pending bills. Confirm one by one.';

	/// en: 'Was this transaction this bill?'
	String get candidateQuestion => 'Was this transaction this bill?';

	/// en: 'Yes'
	String get yesItWas => 'Yes';

	/// en: 'No'
	String get notThisOne => 'No';

	/// en: 'Bill marked as settled'
	String get matchAccepted => 'Bill marked as settled';

	/// en: 'Got it — we'll stop suggesting this one'
	String get matchRejected => 'Got it — we\'ll stop suggesting this one';

	/// en: 'Bill'
	String get billLabel => 'Bill';

	/// en: 'Transaction'
	String get transactionLabel => 'Transaction';

	/// en: 'Description'
	String get fieldDescription => 'Description';

	/// en: 'Category'
	String get fieldCategory => 'Category';

	/// en: 'Amount'
	String get fieldAmount => 'Amount';

	/// en: 'Date'
	String get fieldDate => 'Date';

	/// en: '—'
	String get fieldEmpty => '—';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'general.loading' => 'Loading...',
			'general.error' => 'An error occurred',
			'general.retry' => 'Try again',
			'general.cancel' => 'Cancel',
			'general.confirm' => 'Confirm',
			'general.save' => 'Save',
			'general.delete' => 'Delete',
			'general.edit' => 'Edit',
			'general.add' => 'Add',
			'general.search' => 'Search',
			'general.noResults' => 'No results found',
			'general.success' => 'Success',
			'general.or' => 'or',
			'general.ok' => 'OK',
			'general.update' => 'Update',
			'general.create' => 'Create',
			'general.yes' => 'Yes',
			'general.no' => 'No',
			'general.all' => 'All',
			'general.defaultLabel' => 'Default',
			'validators.required' => 'This field is required.',
			'validators.emailRequired' => 'Email is required.',
			'validators.emailInvalid' => 'Enter a valid email.',
			'validators.passwordRequired' => 'Password is required.',
			'validators.passwordMinLength' => 'Password must be at least 6 characters.',
			'validators.amountRequired' => 'Amount is required.',
			'validators.amountInvalid' => 'Enter a valid amount.',
			'validators.dateInFuture' => 'Date cannot be in the future.',
			'validators.selectAccount' => 'Select an account',
			'validators.selectCategory' => 'Select a category',
			'auth.signIn' => 'Sign In',
			'auth.signUp' => 'Sign Up',
			'auth.signOut' => 'Sign Out',
			'auth.email' => 'Email',
			'auth.emailHint' => 'your@email.com',
			'auth.password' => 'Password',
			'auth.passwordHint' => '••••••••',
			'auth.name' => 'Name',
			'auth.nameHint' => 'Your full name',
			'auth.forgotPassword' => 'Forgot password?',
			'auth.noAccount' => 'Don\'t have an account? Sign Up',
			'auth.hasAccount' => 'Already have an account? Sign In',
			'auth.welcomeBack' => 'Welcome back',
			'auth.signInSubtitle' => 'Sign in to your account',
			'auth.createAccount' => 'Create account',
			'auth.signUpSubtitle' => 'Start managing your finances today',
			'auth.continueWithGoogle' => 'Continue with Google',
			'onboarding.tagline' => 'Take control of your personal finances\nwith smart tracking and AI assistance.',
			'onboarding.step1Title' => 'Track Your Finances',
			'onboarding.step1Body' => 'Log income and expenses effortlessly. Keep a clear view of where your money goes.',
			'onboarding.step2Title' => 'AI-Powered Entry',
			'onboarding.step2Body' => 'Just type naturally — our AI chat extracts transaction data for you automatically.',
			'onboarding.step3Title' => 'Insightful Reports',
			'onboarding.step3Body' => 'Beautiful charts and summaries help you understand your spending habits.',
			'onboarding.getStarted' => 'Get Started',
			'onboarding.next' => 'Next',
			'onboarding.skip' => 'Skip',
			'nav.dashboard' => 'Dashboard',
			'nav.transactions' => 'Transactions',
			'nav.chat' => 'Chat',
			'nav.reports' => 'Reports',
			'nav.profile' => 'Profile',
			'nav.bills' => 'Bills',
			'nav.budgets' => 'Orçamento',
			'dashboard.title' => 'Dashboard',
			'dashboard.totalBalance' => 'Total Balance',
			'dashboard.income' => 'Income',
			'dashboard.expenses' => 'Expenses',
			'dashboard.netResult' => 'Result',
			'dashboard.recentTransactions' => 'Recent Transactions',
			'dashboard.seeAll' => 'See all',
			'dashboard.thisMonth' => 'This month',
			'dashboard.noTransactionsYet' => 'No transactions yet',
			'dashboard.accountBalances' => 'Account Balances',
			'dashboard.monthResult' => 'Month Result',
			'dashboard.expensesByCategory' => 'Expenses by Category',
			'dashboard.incomeByCategory' => 'Income by Category',
			'dashboard.noAccountsYet' => 'No accounts registered yet',
			'dashboard.creditCardBalance' => 'Credit Card Balance',
			'dashboard.noCreditCardsYet' => 'No credit cards registered yet',
			'dashboard.noExpensesYet' => 'No expenses this month',
			'dashboard.noIncomeYet' => 'No income this month',
			'dashboard.totalExpenses' => 'Total Expenses',
			'dashboard.totalIncome' => 'Total Income',
			'dashboard.transactionList' => 'Transaction list',
			'dashboard.subcategories' => 'Subcategories',
			'dashboard.noSubcategories' => 'No subcategories',
			'dashboard.total' => 'Total',
			'dashboard.close' => 'Close',
			'transactions.title' => 'Transactions',
			'transactions.empty' => 'No transactions. Add your first transaction to get started.',
			'transactions.addTransaction' => 'New Transaction',
			'transactions.editTransaction' => 'Edit Transaction',
			'transactions.confirmPaymentTitle' => 'Confirm payment',
			'transactions.confirmReceiptTitle' => 'Confirm receipt',
			'transactions.transactionDetails' => 'Transaction Details',
			'transactions.transaction' => 'Transaction',
			'transactions.transactionNotFound' => 'Transaction not found',
			'transactions.type' => 'Type',
			'transactions.income' => 'Income',
			'transactions.expense' => 'Expense',
			'transactions.amount' => 'Amount',
			'transactions.amountLabel' => 'Amount',
			'transactions.amountHint' => '0.00',
			'transactions.description' => 'Description',
			'transactions.descriptionHint' => 'e.g. Grocery shopping',
			'transactions.date' => 'Date',
			'transactions.category' => 'Category',
			'transactions.account' => 'Account',
			'transactions.notes' => 'Notes',
			'transactions.notesOptional' => 'Notes (optional)',
			'transactions.notesHint' => 'Additional details...',
			'transactions.transfer' => 'Transfer',
			'transactions.sourceAccount' => 'Source account',
			'transactions.destinationAccount' => 'Destination account',
			'transactions.transferCreated' => 'Transfer created',
			'transactions.deleteTransaction' => 'Delete Transaction',
			'transactions.deleteConfirm' => 'Are you sure you want to delete this transaction?',
			'transactions.transactionUpdated' => 'Transaction updated',
			'transactions.transactionCreated' => 'Transaction created',
			'transactions.saved' => 'Transaction saved!',
			'transactions.deleted' => 'Transaction deleted.',
			'transactions.importCsv' => 'Import transactions',
			'transactions.importCsvIntroTitle' => 'Import transactions from CSV',
			'transactions.importCsvIntroBody' => 'Your file must follow the expected format (columns Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência — where Tipo is Despesa/Receita/Transferência/Pagamento). Download the example to see how it works.',
			'transactions.importCsvDownloadExample' => 'Download example',
			'transactions.importCsvSelectFile' => 'Select file',
			'transactions.importCsvExampleDownloaded' => 'Example saved.',
			'transactions.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'transactions.importCsvErrorTitle' => 'Couldn\'t import the CSV',
			'transactions.importInProgressTitle' => 'Importing transactions...',
			'transactions.importProgressCounter' => ({required Object processed, required Object total}) => '${processed} of ${total}',
			'transactions.importMissingFields' => ({required Object fields}) => 'Fill in: ${fields}',
			'transactions.importReview' => ({required Object count}) => 'Review import: ${count} transactions will be created.',
			'transactions.importMissingCategories' => 'Missing categories:',
			'transactions.importMissingAccounts' => 'Missing accounts:',
			'transactions.importSkippedRows' => ({required Object count}) => '${count} rows were skipped (invalid format).',
			'transactions.importSuccess' => ({required Object imported, required Object skipped}) => 'Imported ${imported} transactions. Skipped ${skipped} rows.',
			'transactions.importBlocked' => 'Cannot import: some categories or accounts were not found.',
			'transactions.importTransfers' => ({required Object count}) => '${count} transfers',
			'transactions.importExpenses' => ({required Object count}) => '${count} expenses',
			'transactions.importIncomes' => ({required Object count}) => '${count} incomes',
			'transactions.importPageTitle' => 'Review import',
			'transactions.importPageSubtitle' => 'Tap a row to edit · trash to remove',
			'transactions.importTabExpense' => ({required Object count}) => 'Expense (${count})',
			'transactions.importTabIncome' => ({required Object count}) => 'Income (${count})',
			'transactions.importTabTransfer' => ({required Object count}) => 'Transfer (${count})',
			'transactions.importEmptyTab' => 'Nothing to import in this tab.',
			'transactions.importEditTitle' => 'Edit transaction',
			'transactions.importNothingLeft' => 'Nothing left to import.',
			'transactions.importSubmit' => ({required Object count}) => 'Import ${count} transactions',
			'transactions.importMissingAfterEditPrefix' => 'Resolve missing references before importing:',
			'transactions.importSkippedRowsPill' => ({required Object count}) => '${count} rows skipped',
			'accounts.title' => 'Accounts',
			'accounts.addAccount' => 'New Account',
			'accounts.editAccount' => 'Edit Account',
			'accounts.account' => 'Account',
			'accounts.accountNotFound' => 'Account not found',
			'accounts.checking' => 'Checking Account',
			'accounts.creditCard' => 'Credit Card',
			'accounts.checkingShort' => 'Checking',
			'accounts.name' => 'Account Nickname',
			'accounts.nameHint' => 'e.g. Nubank Gui',
			'accounts.bank' => 'Bank',
			'accounts.bankHint' => 'e.g. Nubank',
			'accounts.bankOthers' => 'Others',
			'accounts.linkedAccount' => 'Linked Checking Account',
			'accounts.balance' => 'Balance',
			'accounts.currentBalance' => 'Current Balance',
			'accounts.balanceLabel' => 'Initial Balance (R\$)',
			'accounts.balanceHint' => '0.00',
			'accounts.creditLimit' => 'Credit Limit',
			'accounts.creditLimitLabel' => 'Credit Limit (R\$)',
			'accounts.creditLimitHint' => '0.00',
			'accounts.closingDay' => 'Closing Day',
			'accounts.dueDay' => 'Due Day',
			'accounts.availableCredit' => 'Available Credit',
			'accounts.currentBill' => 'Current bill',
			'accounts.type' => 'Type',
			'accounts.empty' => 'No accounts. Add your first bank account or credit card.',
			'accounts.emptySubtitle' => 'Add your bank accounts and credit cards.',
			'accounts.accountUpdated' => 'Account updated',
			'accounts.accountCreated' => 'Account created',
			'accounts.saved' => 'Account saved!',
			'accounts.deleted' => 'Account deleted.',
			'accounts.deleteConfirm' => 'Are you sure you want to delete this account?',
			'accounts.statement' => 'Monthly Summary',
			'accounts.monthIncome' => 'Income',
			'accounts.monthExpenses' => 'Expenses',
			'accounts.monthResult' => 'Result',
			'accounts.noTransactionsInPeriod' => 'No transactions in this period',
			'accounts.formSectionType' => 'Type',
			'accounts.formSectionDetails' => 'Details',
			'accounts.formSectionCreditCard' => 'Credit card',
			'accounts.pickClosingDay' => 'Closing day',
			'accounts.pickDueDay' => 'Due day',
			'accounts.pickLinkedAccount' => 'Linked checking account',
			'accounts.pickBank' => 'Pick a bank',
			'accounts.bankSearchHint' => 'Search bank',
			'accounts.bankSearchNoResults' => 'No banks match your search.',
			'accounts.noLinkedCandidates' => 'Create a checking account first.',
			'accounts.addFirst' => 'Add your first account',
			'accounts.emptyTitle' => 'No accounts yet',
			'accounts.importCsv' => 'Import accounts',
			'accounts.importCsvIntroTitle' => 'Import accounts from CSV',
			'accounts.importCsvIntroBody' => 'Your file must follow the expected format (columns Nome, Saldo inicial, Tipo, Banco, Limite, Próximo Vencimento, Fechamento — where Tipo is Conta Corrente or Cartão de Crédito). Download the example to see how it works.',
			'accounts.importCsvDownloadExample' => 'Download example',
			'accounts.importCsvSelectFile' => 'Select file',
			'accounts.importCsvExampleDownloaded' => 'Example saved.',
			'accounts.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'accounts.importCsvErrorTitle' => 'Couldn\'t import the CSV',
			'accounts.importPageTitle' => 'Review import',
			'accounts.importPageSubtitle' => 'Tap a row to edit · trash to remove',
			'accounts.importTabChecking' => ({required Object count}) => 'Checking (${count})',
			'accounts.importTabCreditCard' => ({required Object count}) => 'Credit card (${count})',
			'accounts.importEmptyTab' => 'Nothing to import in this tab.',
			'accounts.importDuplicatesHeader' => 'Will be skipped (already exists)',
			'accounts.importEditTitle' => 'Edit account',
			'accounts.importNothingLeft' => 'Nothing left to import.',
			'accounts.importSubmit' => ({required Object count}) => 'Import ${count} accounts',
			'accounts.importMissingLinkPrefix' => 'Pick a linked checking account for:',
			'accounts.importSuccessDetailed' => ({required Object imported, required Object duplicates}) => 'Imported ${imported} accounts. Skipped ${duplicates} duplicates.',
			'accounts.importInProgressTitle' => 'Importing accounts...',
			'accounts.importProgressCounter' => ({required Object processed, required Object total}) => '${processed} of ${total}',
			'accounts.importMissingFields' => ({required Object fields}) => 'Fill in: ${fields}',
			'categories.title' => 'Categories',
			'categories.addCategory' => 'Add Category',
			'categories.editCategory' => 'Edit Category',
			'categories.name' => 'Category name',
			'categories.nameHint' => 'e.g. Groceries',
			'categories.incomeType' => 'Income',
			'categories.expenseType' => 'Expense',
			'categories.bothType' => 'Both',
			'categories.empty' => 'No categories. Categories will appear here.',
			'categories.saved' => 'Category saved!',
			'categories.deleted' => 'Category deleted.',
			'categories.deleteConfirm' => 'Are you sure you want to delete this category?',
			'categories.reassignPrompt' => 'Select a category to reassign transactions to:',
			'categories.categoryUpdated' => 'Category updated',
			'categories.categoryCreated' => 'Category created',
			'categories.cannotDeleteDefault' => 'Default categories cannot be deleted.',
			'categories.cannotDeleteLast' => 'Create another category before deleting this one.',
			'categories.selectIcon' => 'Select icon',
			'categories.selectColor' => 'Select color',
			'categories.chooseIcon' => 'Choose icon',
			'categories.iconSearchHint' => 'Search (e.g. car, carro)',
			'categories.iconSearchNoResults' => 'No icons match your search.',
			'categories.parentCategory' => 'Parent category',
			'categories.noParent' => 'No parent',
			'categories.subcategoryLabel' => 'Subcategory',
			'categories.importCsv' => 'Import categories',
			'categories.importCsvIntroTitle' => 'Import categories from CSV',
			'categories.importCsvIntroBody' => 'Your file must follow the expected format (columns Categoria, Subcategoria, Tipo — where Tipo is Receita/Despesa or Income/Expense). Download the example to see how it works.',
			'categories.importCsvDownloadExample' => 'Download example',
			'categories.importCsvSelectFile' => 'Select file',
			'categories.importCsvExampleDownloaded' => 'Example saved.',
			'categories.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'categories.importCsvErrorTitle' => 'Couldn\'t import the CSV',
			'categories.importSuccess' => ({required Object count}) => 'Imported ${count} categories.',
			'categories.importReview' => ({required Object arg}) => 'Review import: ${arg} new items will be created.',
			'categories.importDuplicates' => ({required Object arg}) => '${arg} duplicate items will be skipped.',
			'categories.importSuccessDetailed' => ({required Object imported, required Object duplicates}) => 'Imported ${imported} items. Skipped ${duplicates} duplicates.',
			'categories.importPageTitle' => 'Review import',
			'categories.importPageSubtitle' => 'Tap an item to edit · swipe trash to remove',
			'categories.importTabExpense' => ({required Object count}) => 'Expense (${count})',
			'categories.importTabIncome' => ({required Object count}) => 'Income (${count})',
			'categories.importEmptyTab' => 'Nothing to import in this tab.',
			'categories.importDuplicatesHeader' => 'Will be skipped (already exists)',
			'categories.importEditTitle' => 'Edit category',
			'categories.importDeleteRoot' => ({required Object name, required Object count}) => 'Remove ${name} and its ${count} subcategories?',
			'categories.importDeleteRootConfirm' => 'Remove',
			'categories.importNothingLeft' => 'Nothing left to import.',
			'categories.importSubmit' => ({required Object count}) => 'Import ${count} items',
			'categories.importInProgressTitle' => 'Importing categories...',
			'categories.importProgressCounter' => ({required Object processed, required Object total}) => '${processed} of ${total}',
			'categories.formSectionType' => 'Type',
			'categories.formSectionDetails' => 'Details',
			'categories.formSectionAppearance' => 'Appearance',
			'categories.pickParent' => 'Parent category',
			'categories.searchHint' => 'Search categories',
			'categories.searchNoResults' => 'No categories match your search.',
			'categories.noParentChosen' => 'None',
			'categories.addFirst' => 'Add your first category',
			'categories.emptyTitle' => 'No categories yet',
			'chat.title' => 'AI Assistant',
			'chat.placeholder' => 'Type a message...',
			'chat.welcomeTitle' => 'Hi! I\'m your financial assistant.',
			'chat.welcomeBody' => 'Tell me about your transactions and I\'ll help you record them.',
			'chat.confirmPrompt' => 'I detected the following transaction. Does this look correct?',
			'chat.confirmed' => 'Transaction saved!',
			'chat.cancelled' => 'Transaction cancelled.',
			'chat.error' => 'Sorry, I couldn\'t understand that. Could you try again?',
			'chat.aiName' => 'Financo AI',
			'chat.online' => 'Online',
			'chat.today' => 'Today',
			'chat.yesterday' => 'Yesterday',
			'chat.viaWhatsapp' => 'via WhatsApp',
			'chat.tryAsking' => 'Try asking',
			'chat.suggestion1' => 'I spent R\$ 30 at the bakery',
			'chat.suggestion2' => 'How much do I have on my Nubank account?',
			'chat.suggestion3' => 'Show my overdue bills',
			'chat.suggestion4' => 'Create a category called Leisure',
			'chat.action.transactionExpense' => 'Confirm expense',
			'chat.action.transactionIncome' => 'Confirm income',
			'chat.action.transfer' => 'Confirm transfer',
			'chat.action.fieldFromAccount' => 'From',
			'chat.action.fieldToAccount' => 'To',
			'chat.action.accountCreate' => 'Create account',
			'chat.action.accountDelete' => 'Delete account',
			'chat.action.categoryCreate' => 'Create category',
			'chat.action.categoryDelete' => 'Delete category',
			'chat.action.billCreate' => 'Schedule bill',
			'chat.action.billUpdate' => 'Update bill',
			'chat.action.billMarkPaid' => 'Mark bill as paid',
			'chat.action.billDelete' => 'Delete bill',
			'chat.action.budgetCreate' => 'Create budget',
			'chat.action.budgetUpdate' => 'Update budget',
			'chat.action.budgetDelete' => 'Delete budget',
			'chat.action.fieldAmount' => 'Amount',
			'chat.action.fieldDescription' => 'Description',
			'chat.action.fieldCategory' => 'Category',
			'chat.action.fieldAccount' => 'Account',
			'chat.action.fieldDate' => 'Date',
			'chat.action.fieldType' => 'Type',
			'chat.action.fieldBank' => 'Bank',
			'chat.action.fieldCreditLimit' => 'Credit limit',
			'chat.action.fieldClosingDay' => 'Closing day',
			'chat.action.fieldDueDay' => 'Due day',
			'chat.action.fieldDueDate' => 'Due date',
			'chat.action.fieldRecurrence' => 'Recurrence',
			'chat.action.fieldName' => 'Name',
			'chat.action.fieldLinkedAccount' => 'Linked account',
			'chat.action.fieldBalance' => 'Initial balance',
			'chat.action.fieldNotes' => 'Notes',
			'chat.action.confirm' => 'Confirm',
			'chat.action.cancel' => 'Cancel',
			'chat.action.statusConfirmed' => 'Confirmed',
			'chat.action.statusCancelled' => 'Cancelled',
			'chat.audio.start' => 'Record voice message',
			'chat.audio.stop' => 'Stop recording',
			'chat.audio.cancel' => 'Cancel',
			'chat.audio.recording' => 'Recording',
			'chat.audio.transcribing' => 'Transcribing...',
			'chat.audio.reviewHint' => 'Review transcript and send',
			'chat.audio.permissionDenied' => 'Microphone permission required to record voice.',
			'chat.audio.recordError' => 'Failed to record audio',
			'chat.image.attach' => 'Attach image',
			'chat.image.takePhoto' => 'Take photo',
			'chat.image.fromGallery' => 'Choose from gallery',
			'chat.image.remove' => 'Remove image',
			'chat.image.pickError' => 'Could not pick image',
			'reports.title' => 'Reports',
			'reports.incomeVsExpenses' => 'Income vs Expenses',
			'reports.expensesByCategory' => 'Expenses by Category',
			'reports.income' => 'Income',
			'reports.expenses' => 'Expenses',
			'reports.net' => 'Net',
			'reports.currentMonth' => 'Current month',
			'reports.lastMonth' => 'Last month',
			'reports.customRange' => 'Custom range',
			'reports.categoryBreakdown' => 'Category Breakdown',
			'reports.monthlyComparison' => 'Monthly Comparison',
			'reports.balanceEvolution' => 'Balance Evolution',
			'reports.noData' => 'Not enough data to generate reports.',
			'bills.title' => 'Bills',
			'bills.empty' => 'No bills. Add a bill to get reminders before it\'s due.',
			'bills.addBill' => 'New Bill',
			'bills.editBill' => 'Edit Bill',
			'bills.description' => 'Description',
			'bills.descriptionHint' => 'e.g. Electricity',
			'bills.amount' => 'Amount',
			'bills.amountLabel' => 'Amount',
			'bills.dueDate' => 'Due date',
			'bills.recurrence' => 'Recurrence',
			'bills.oneShot' => 'One-time',
			'bills.monthly' => 'Monthly',
			'bills.type' => 'Type',
			'bills.typePayable' => 'To pay',
			'bills.typeReceivable' => 'To receive',
			'bills.filterAll' => 'All',
			'bills.category' => 'Category',
			'bills.categoryRequired' => 'Pick a category',
			'bills.notes' => 'Notes (optional)',
			'bills.notesHint' => 'Additional details...',
			'bills.markAsPaid' => 'Mark as paid',
			'bills.markAsReceived' => 'Mark as received',
			'bills.paid' => 'Paid',
			'bills.received' => 'Received',
			'bills.pending' => 'Pending',
			'bills.overdue' => 'Overdue',
			'bills.dueToday' => 'Due today',
			'bills.upcoming' => 'Upcoming',
			'bills.overdueGroup' => 'Overdue',
			'bills.todayGroup' => 'Today',
			'bills.upcomingGroup' => 'Upcoming',
			'bills.paidGroup' => 'Settled',
			'bills.deleteConfirm' => 'Are you sure you want to delete this bill?',
			'bills.billCreated' => 'Bill created',
			'bills.billUpdated' => 'Bill updated',
			'bills.billDeleted' => 'Bill deleted',
			'bills.billPaid' => 'Bill paid — transaction created',
			'bills.billReceived' => 'Payment received — transaction created',
			'bills.nextOccurrenceCreated' => 'Next month\'s bill scheduled',
			'bills.alreadyPaid' => 'This bill is already settled',
			'bills.cannotEditPaid' => 'Settled bills can\'t be edited',
			'bills.payDialogTitle' => 'Pay bill',
			'bills.receiveDialogTitle' => 'Register received payment',
			'bills.selectAccount' => 'Account',
			'bills.selectCategory' => 'Category',
			'bills.daysOverdue' => ({required Object days}) => '${days} days overdue',
			'bills.dueInDays' => ({required Object days}) => 'in ${days} days',
			'bills.dueTomorrow' => 'tomorrow',
			'bills.noExpenseCategory' => 'Create at least one expense category first.',
			'bills.noIncomeCategory' => 'Create at least one income category first.',
			'bills.summaryTitle' => 'This month',
			'bills.summaryAllCaughtUp' => 'Nothing due — you\'re all caught up',
			'bills.overdueChip' => ({required Object count}) => '${count} overdue',
			'bills.pendingCount' => ({required Object count}) => '${count} pending',
			'bills.emptyTitle' => 'No bills yet',
			'bills.addFirst' => 'Add your first bill',
			'bills.formDetails' => 'Details',
			'bills.formClassification' => 'Classification',
			'bills.pickCategory' => 'Choose a category',
			'bills.notification.title' => ({required Object count}) => 'You have ${count} bill(s) to pay',
			'bills.notification.bodyDueToday' => ({required Object description, required Object amount}) => '${description} (${amount}) is due today',
			'bills.notification.bodyOverdue' => ({required Object description, required Object amount}) => '${description} (${amount}) is overdue',
			'bills.match.bannerTitle' => ({required Object count}) => '${count} possible payment(s) detected',
			'bills.match.bannerSubtitle' => 'Tap to confirm if any existing transaction settles a pending bill',
			'bills.match.sheetTitle' => 'Confirm payments',
			'bills.match.sheetIntro' => 'We found transactions that could be paying your pending bills. Confirm one by one.',
			'bills.match.candidateQuestion' => 'Was this transaction this bill?',
			'bills.match.yesItWas' => 'Yes',
			'bills.match.notThisOne' => 'No',
			'bills.match.matchAccepted' => 'Bill marked as settled',
			'bills.match.matchRejected' => 'Got it — we\'ll stop suggesting this one',
			'bills.match.billLabel' => 'Bill',
			'bills.match.transactionLabel' => 'Transaction',
			'bills.match.fieldDescription' => 'Description',
			'bills.match.fieldCategory' => 'Category',
			'bills.match.fieldAmount' => 'Amount',
			'bills.match.fieldDate' => 'Date',
			'bills.match.fieldEmpty' => '—',
			'bills.virtualBlocked' => 'Pague a ocorrência atual primeiro',
			'bills.preview' => 'Preview',
			'bills.editScopeTitle' => 'Aplicar a quais ocorrências?',
			'bills.editScopeDescription' => 'Esta é uma cobrança recorrente. Você pode aplicar a alteração apenas a esta ocorrência ou também às futuras (não afeta as anteriores).',
			'bills.editScopeOnlyThis' => 'Apenas esta',
			'bills.editScopeAlsoSubsequents' => 'Esta e as subsequentes',
			'budgets.title' => 'Orçamento',
			'budgets.addBudget' => 'Novo orçamento',
			'budgets.editBudget' => 'Editar orçamento',
			'budgets.category' => 'Categoria',
			'budgets.categoryHint' => 'Escolha uma categoria',
			'budgets.categoryRequired' => 'Selecione uma categoria',
			'budgets.amount' => 'Valor mensal',
			'budgets.amountHint' => '0,00',
			'budgets.summaryTitle' => 'Resumo do mês',
			'budgets.summaryCap' => 'Total orçado',
			'budgets.summarySpent' => 'Gasto',
			'budgets.summaryRemaining' => 'Disponível',
			'budgets.spentOf' => ({required Object spent, required Object cap}) => '${spent} de ${cap}',
			'budgets.percentageUsed' => ({required Object value}) => '${value}% usado',
			'budgets.remainingOf' => ({required Object value}) => 'Restam ${value}',
			'budgets.overBy' => ({required Object value}) => 'Estourou em ${value}',
			'budgets.statusSafe' => 'Tranquilo',
			'budgets.statusWarning' => 'Atenção',
			'budgets.statusExceeded' => 'Estourou',
			'budgets.deleteConfirm' => 'Tem certeza que deseja excluir este orçamento?',
			'budgets.budgetCreated' => 'Orçamento criado',
			'budgets.budgetUpdated' => 'Orçamento atualizado',
			'budgets.budgetDeleted' => 'Orçamento excluído',
			'budgets.duplicateCategory' => 'Já existe um orçamento para essa categoria.',
			'budgets.noExpenseCategory' => 'Crie ao menos uma categoria de despesa antes.',
			'budgets.allCategoriesBudgeted' => 'Todas as categorias já têm orçamento.',
			'budgets.emptyTitle' => 'Tome controle dos seus gastos',
			'budgets.emptyBody' => 'Defina um teto mensal por categoria de despesa. O Finanço acompanha quanto você gastou, quanto ainda resta, e mostra de cara quando você está prestes a estourar.',
			'budgets.emptyExample' => 'Ex: R\$ 1.500 em Alimentação, R\$ 400 em Lazer, R\$ 200 em Transporte.',
			'budgets.emptyAction' => 'Criar primeiro orçamento',
			'budgets.formDetails' => 'Detalhes',
			'budgets.formCategorySection' => 'Categoria',
			'profile.title' => 'Profile',
			'profile.editProfile' => 'Edit Profile',
			'profile.accounts' => 'Accounts',
			'profile.categories' => 'Categories',
			'profile.bills' => 'Bills',
			'profile.theme' => 'Theme',
			'profile.themeLight' => 'Light',
			'profile.themeDark' => 'Dark',
			'profile.themeSystem' => 'System',
			'profile.signOutConfirm' => 'Are you sure you want to sign out?',
			'profile.clearData' => 'Clear all my data',
			'profile.clearDataDescription' => 'Delete transactions, chat, categories and accounts',
			'profile.clearDataConfirm' => 'This will permanently delete all data from your account. Continue?',
			'profile.clearDataSuccess' => 'Your account data was cleared.',
			'profile.downloadApk' => 'Download Android app',
			'profile.downloadApkDescription' => 'Install the mobile version on your Android device',
			'profile.sectionYourData' => 'Your data',
			'profile.sectionPreferences' => 'Preferences',
			'profile.sectionGetTheApp' => 'Get the app',
			'profile.sectionAccount' => 'Account',
			'profile.sectionDangerZone' => 'Danger zone',
			'profile.appearance' => 'Appearance',
			'profile.version' => 'Version',
			'startup.tagline' => 'Your finances, in flow.',
			'startup.stepCheckingAuth' => 'Checking your account',
			'startup.stepSyncingData' => 'Syncing your data',
			'startup.stepReady' => 'Almost there',
			'startup.errorTitle' => 'Something went wrong',
			'startup.errorRetry' => 'Try again',
			_ => null,
		};
	}
}
