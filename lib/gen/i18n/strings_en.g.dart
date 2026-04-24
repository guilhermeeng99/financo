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
	late final TranslationsAppEn app = TranslationsAppEn._(_root);
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
	late final TranslationsProfileEn profile = TranslationsProfileEn._(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Financo'
	String get name => 'Financo';
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

	/// en: 'Net Result'
	String get netResult => 'Net Result';

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

	/// en: 'Amount (R\$)'
	String get amountLabel => 'Amount (R\$)';

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

	/// en: 'Your file must follow the expected format (columns Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência). Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência). Download the example to see how it works.';

	/// en: 'Download example'
	String get importCsvDownloadExample => 'Download example';

	/// en: 'Select file'
	String get importCsvSelectFile => 'Select file';

	/// en: 'Example saved.'
	String get importCsvExampleDownloaded => 'Example saved.';

	/// en: 'Couldn't save the example file.'
	String get importCsvExampleFailed => 'Couldn\'t save the example file.';

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

	/// en: 'Your file must follow the expected format (columns Category, Subcategory, Type — where Type is Income or Expense). Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Category, Subcategory, Type — where Type is Income or Expense). Download the example to see how it works.';

	/// en: 'Download example'
	String get importCsvDownloadExample => 'Download example';

	/// en: 'Select file'
	String get importCsvSelectFile => 'Select file';

	/// en: 'Example saved.'
	String get importCsvExampleDownloaded => 'Example saved.';

	/// en: 'Couldn't save the example file.'
	String get importCsvExampleFailed => 'Couldn\'t save the example file.';

	/// en: 'Imported $count categories.'
	String importSuccess({required Object count}) => 'Imported ${count} categories.';

	/// en: 'Review import: $arg new items will be created.'
	String importReview({required Object arg}) => 'Review import: ${arg} new items will be created.';

	/// en: '$arg duplicate items will be skipped.'
	String importDuplicates({required Object arg}) => '${arg} duplicate items will be skipped.';

	/// en: 'Imported $imported items. Skipped $duplicates duplicates.'
	String importSuccessDetailed({required Object imported, required Object duplicates}) => 'Imported ${imported} items. Skipped ${duplicates} duplicates.';
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

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Financo',
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
			'dashboard.title' => 'Dashboard',
			'dashboard.totalBalance' => 'Total Balance',
			'dashboard.income' => 'Income',
			'dashboard.expenses' => 'Expenses',
			'dashboard.netResult' => 'Net Result',
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
			'transactions.transactionDetails' => 'Transaction Details',
			'transactions.transaction' => 'Transaction',
			'transactions.transactionNotFound' => 'Transaction not found',
			'transactions.type' => 'Type',
			'transactions.income' => 'Income',
			'transactions.expense' => 'Expense',
			'transactions.amount' => 'Amount',
			'transactions.amountLabel' => 'Amount (R\$)',
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
			'transactions.importCsvIntroBody' => 'Your file must follow the expected format (columns Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência). Download the example to see how it works.',
			'transactions.importCsvDownloadExample' => 'Download example',
			'transactions.importCsvSelectFile' => 'Select file',
			'transactions.importCsvExampleDownloaded' => 'Example saved.',
			'transactions.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'transactions.importReview' => ({required Object count}) => 'Review import: ${count} transactions will be created.',
			'transactions.importMissingCategories' => 'Missing categories:',
			'transactions.importMissingAccounts' => 'Missing accounts:',
			'transactions.importSkippedRows' => ({required Object count}) => '${count} rows were skipped (invalid format).',
			'transactions.importSuccess' => ({required Object imported, required Object skipped}) => 'Imported ${imported} transactions. Skipped ${skipped} rows.',
			'transactions.importBlocked' => 'Cannot import: some categories or accounts were not found.',
			'transactions.importTransfers' => ({required Object count}) => '${count} transfers',
			'transactions.importExpenses' => ({required Object count}) => '${count} expenses',
			'transactions.importIncomes' => ({required Object count}) => '${count} incomes',
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
			'categories.parentCategory' => 'Parent category',
			'categories.noParent' => 'No parent',
			'categories.subcategoryLabel' => 'Subcategory',
			'categories.importCsv' => 'Import categories',
			'categories.importCsvIntroTitle' => 'Import categories from CSV',
			'categories.importCsvIntroBody' => 'Your file must follow the expected format (columns Category, Subcategory, Type — where Type is Income or Expense). Download the example to see how it works.',
			'categories.importCsvDownloadExample' => 'Download example',
			'categories.importCsvSelectFile' => 'Select file',
			'categories.importCsvExampleDownloaded' => 'Example saved.',
			'categories.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'categories.importSuccess' => ({required Object count}) => 'Imported ${count} categories.',
			'categories.importReview' => ({required Object arg}) => 'Review import: ${arg} new items will be created.',
			'categories.importDuplicates' => ({required Object arg}) => '${arg} duplicate items will be skipped.',
			'categories.importSuccessDetailed' => ({required Object imported, required Object duplicates}) => 'Imported ${imported} items. Skipped ${duplicates} duplicates.',
			'chat.title' => 'AI Assistant',
			'chat.placeholder' => 'Type a message...',
			'chat.welcomeTitle' => 'Hi! I\'m your financial assistant.',
			'chat.welcomeBody' => 'Tell me about your transactions and I\'ll help you record them.',
			'chat.confirmPrompt' => 'I detected the following transaction. Does this look correct?',
			'chat.confirmed' => 'Transaction saved!',
			'chat.cancelled' => 'Transaction cancelled.',
			'chat.error' => 'Sorry, I couldn\'t understand that. Could you try again?',
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
			'profile.title' => 'Profile',
			'profile.editProfile' => 'Edit Profile',
			'profile.accounts' => 'Accounts',
			'profile.categories' => 'Categories',
			'profile.theme' => 'Theme',
			'profile.themeLight' => 'Light',
			'profile.themeDark' => 'Dark',
			'profile.themeSystem' => 'System',
			'profile.signOutConfirm' => 'Are you sure you want to sign out?',
			'profile.clearData' => 'Clear all my data',
			'profile.clearDataDescription' => 'Delete transactions, chat, categories and accounts',
			'profile.clearDataConfirm' => 'This will permanently delete all data from your account. Continue?',
			'profile.clearDataSuccess' => 'Your account data was cleared.',
			_ => null,
		};
	}
}
