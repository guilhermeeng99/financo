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
	late final TranslationsAccessControlEn accessControl = TranslationsAccessControlEn._(_root);
	late final TranslationsMasterPanelEn masterPanel = TranslationsMasterPanelEn._(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn._(_root);
	late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	late final TranslationsDashboardEn dashboard = TranslationsDashboardEn._(_root);
	late final TranslationsFiftyThirtyTwentyEn fiftyThirtyTwenty = TranslationsFiftyThirtyTwentyEn._(_root);
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

	/// en: 'Sign Out'
	String get signOut => 'Sign Out';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'your@email.com'
	String get emailHint => 'your@email.com';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';

	/// en: 'Access is by invite only.'
	String get accessByInviteOnly => 'Access is by invite only.';
}

// Path: accessControl
class TranslationsAccessControlEn {
	TranslationsAccessControlEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restricted access'
	String get restrictedTitle => 'Restricted access';

	/// en: 'Ask Guilherme to grant access for your email:'
	String get restrictedBody => 'Ask Guilherme to grant access for your email:';

	/// en: 'Back'
	String get restrictedBack => 'Back';
}

// Path: masterPanel
class TranslationsMasterPanelEn {
	TranslationsMasterPanelEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Master panel'
	String get title => 'Master panel';

	/// en: 'Users'
	String get tabUsers => 'Users';

	/// en: 'Allowlist'
	String get tabAllowlist => 'Allowlist';

	/// en: 'No registered users yet.'
	String get usersEmpty => 'No registered users yet.';

	/// en: 'No emails authorized yet.'
	String get allowlistEmpty => 'No emails authorized yet.';

	/// en: 'MASTER'
	String get masterBadge => 'MASTER';

	/// en: 'Authorize email'
	String get addEmailTitle => 'Authorize email';

	/// en: 'Note (optional)'
	String get addEmailNoteLabel => 'Note (optional)';

	/// en: 'e.g. friend's name'
	String get addEmailNoteHint => 'e.g. friend\'s name';

	/// en: 'Email authorized.'
	String get addEmailSuccess => 'Email authorized.';

	/// en: 'Remove access'
	String get removeEmailTitle => 'Remove access';

	/// en: 'This removes access for $email. Their existing data is kept.'
	String removeEmailBody({required Object email}) => 'This removes access for ${email}. Their existing data is kept.';

	/// en: 'Remove'
	String get removeEmailConfirm => 'Remove';

	/// en: 'Email removed from allowlist.'
	String get removeEmailSuccess => 'Email removed from allowlist.';

	/// en: 'Delete user'
	String get deleteUserTitle => 'Delete user';

	/// en: 'This permanently deletes $name and all of their data. Type the email to confirm.'
	String deleteUserBody({required Object name}) => 'This permanently deletes ${name} and all of their data. Type the email to confirm.';

	/// en: 'Type the email'
	String get deleteUserConfirmField => 'Type the email';

	/// en: 'User deleted.'
	String get deleteUserSuccess => 'User deleted.';
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

	/// en: 'Budgets'
	String get budgets => 'Budgets';

	/// en: 'Planning'
	String get planning => 'Planning';
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

	/// en: 'Balances'
	String get accountBalances => 'Balances';

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

	/// en: 'Investments'
	String get investmentBalance => 'Investments';

	/// en: 'No investment accounts registered yet'
	String get noInvestmentsYet => 'No investment accounts registered yet';

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

// Path: fiftyThirtyTwenty
class TranslationsFiftyThirtyTwentyEn {
	TranslationsFiftyThirtyTwentyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '50/30/20'
	String get title => '50/30/20';

	/// en: 'How your month is going'
	String get subtitle => 'How your month is going';

	/// en: 'Needs'
	String get needsLabel => 'Needs';

	/// en: 'Wants'
	String get wantsLabel => 'Wants';

	/// en: 'Savings'
	String get savingsLabel => 'Savings';

	/// en: '$actual% of $target%'
	String ofTarget({required Object actual, required Object target}) => '${actual}% of ${target}%';

	/// en: '100% = $value'
	String baselinePill({required Object value}) => '100% = ${value}';

	/// en: 'Log income for this month to track the 50/30/20 rule.'
	String get noIncomeHeadline => 'Log income for this month to track the 50/30/20 rule.';

	/// en: 'You're on track.'
	String get onTrackHeadline => 'You\'re on track.';

	/// en: 'A few tweaks would help.'
	String get needsAttentionHeadline => 'A few tweaks would help.';

	/// en: 'Classify your categories for an accurate read.'
	String get unclassifiedDominantHeadline => 'Classify your categories for an accurate read.';

	/// en: 'Trim $value off needs to hit the target.'
	String tipNeedsOver({required Object value}) => 'Trim ${value} off needs to hit the target.';

	/// en: 'You went $value over your wants budget this month.'
	String tipWantsOver({required Object value}) => 'You went ${value} over your wants budget this month.';

	/// en: 'Add $value to hit 20% savings.'
	String tipSavingsShortWithAccount({required Object value}) => 'Add ${value} to hit 20% savings.';

	/// en: 'Create an investment account to start logging contributions.'
	String get tipSavingsShortNoAccount => 'Create an investment account to start logging contributions.';

	/// en: '$count category(ies) still need classification.'
	String tipUnclassified({required Object count}) => '${count} category(ies) still need classification.';

	/// en: 'Create account'
	String get ctaCreateInvestment => 'Create account';

	/// en: 'Classify'
	String get ctaClassify => 'Classify';

	/// en: 'Unclassified'
	String get unclassifiedLabel => 'Unclassified';

	/// en: 'Savings here = monthly contributions (transfers checking → investment). Market yield is not tracked.'
	String get principalDisclaimer => 'Savings here = monthly contributions (transfers checking → investment). Market yield is not tracked.';

	/// en: 'Edit targets'
	String get editTargets => 'Edit targets';

	/// en: 'Set the percentage for each bucket. The three must add up to 100%.'
	String get editTargetsHint => 'Set the percentage for each bucket. The three must add up to 100%.';

	/// en: 'Reset to 50/30/20'
	String get resetToClassic => 'Reset to 50/30/20';

	/// en: 'Total: $percent% ✓'
	String sumOk({required Object percent}) => 'Total: ${percent}% ✓';

	/// en: 'Total: $percent% — must be 100%'
	String sumInvalid({required Object percent}) => 'Total: ${percent}% — must be 100%';

	/// en: '$spent / $target'
	String spentOfTarget({required Object spent, required Object target}) => '${spent} / ${target}';

	/// en: 'No expenses in this bucket this month.'
	String get bucketEmpty => 'No expenses in this bucket this month.';

	/// en: 'Last 3 months'
	String get historyTitle => 'Last 3 months';

	/// en: 'No history to show yet.'
	String get historyEmpty => 'No history to show yet.';

	/// en: 'Planning'
	String get navLabel => 'Planning';

	/// en: 'Budgets'
	String get subTabBudgets => 'Budgets';

	/// en: '50/30/20'
	String get subTabFiftyThirtyTwenty => '50/30/20';
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

	/// en: 'Description (optional)'
	String get descriptionOptional => 'Description (optional)';

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

	/// en: 'Save and add another'
	String get saveAndAddAnother => 'Save and add another';

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

	/// en: 'Savings Account'
	String get investment => 'Savings Account';

	/// en: 'Checking'
	String get checkingShort => 'Checking';

	/// en: 'Savings'
	String get investmentShort => 'Savings';

	/// en: 'Dedicated account for contributions. Shows up as 'investment' on transfers and feeds the 50/30/20 card.'
	String get investmentDescription => 'Dedicated account for contributions. Shows up as \'investment\' on transfers and feeds the 50/30/20 card.';

	/// en: 'Balance reflects only your contributions (principal). Market yield is not tracked.'
	String get investmentYieldDisclaimer => 'Balance reflects only your contributions (principal). Market yield is not tracked.';

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

	/// en: 'Subcategories inherit the parent category's icon and color.'
	String get subcategoryAppearanceInherited => 'Subcategories inherit the parent category\'s icon and color.';

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

	/// en: '50/30/20 rule'
	String get formSectionBucket => '50/30/20 rule';

	/// en: 'Which group does this category fit into?'
	String get bucketHint => 'Which group does this category fit into?';

	/// en: 'Count toward 50/30/20'
	String get incomeCountsTitle => 'Count toward 50/30/20';

	/// en: 'When on, income on this category feeds the monthly base (100%). Turn off for one-off receipts (reimbursements, gifts, sold goods) that would otherwise distort the breakdown.'
	String get incomeCountsHint => 'When on, income on this category feeds the monthly base (100%). Turn off for one-off receipts (reimbursements, gifts, sold goods) that would otherwise distort the breakdown.';

	/// en: 'Need'
	String get bucketNeeds => 'Need';

	/// en: 'Want'
	String get bucketWants => 'Want';

	/// en: 'Unclassified'
	String get bucketUnclassified => 'Unclassified';

	/// en: 'Needs cover essentials (rent, groceries, transport). Wants cover discretionary (leisure, dining out). Savings is handled by transfers to investment accounts.'
	String get bucketHelp => 'Needs cover essentials (rent, groceries, transport). Wants cover discretionary (leisure, dining out). Savings is handled by transfers to investment accounts.';

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
	late final TranslationsChatHandlersEn handlers = TranslationsChatHandlersEn._(_root);
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

	/// en: 'Pay the current occurrence first'
	String get virtualBlocked => 'Pay the current occurrence first';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Apply to which occurrences?'
	String get editScopeTitle => 'Apply to which occurrences?';

	/// en: 'This is a recurring bill. You can apply the change to this occurrence only, or also to future ones (past occurrences are never affected).'
	String get editScopeDescription => 'This is a recurring bill. You can apply the change to this occurrence only, or also to future ones (past occurrences are never affected).';

	/// en: 'Only this one'
	String get editScopeOnlyThis => 'Only this one';

	/// en: 'This and the following'
	String get editScopeAlsoSubsequents => 'This and the following';

	/// en: 'Import bills'
	String get importCsv => 'Import bills';

	/// en: 'Import bills from CSV'
	String get importCsvIntroTitle => 'Import bills from CSV';

	/// en: 'Your file must follow the expected format (columns Type, Description, Amount, Due Date, Status, Recurrence, Category, Notes — where Type is Payable/Receivable, Status is Pending/Paid and Recurrence is Monthly/One-time). Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Type, Description, Amount, Due Date, Status, Recurrence, Category, Notes — where Type is Payable/Receivable, Status is Pending/Paid and Recurrence is Monthly/One-time). Download the example to see how it works.';

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

	/// en: 'Imported $imported bills. Skipped $skipped (unknown category).'
	String importCsvSuccess({required Object imported, required Object skipped}) => 'Imported ${imported} bills. Skipped ${skipped} (unknown category).';
}

// Path: budgets
class TranslationsBudgetsEn {
	TranslationsBudgetsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budgets'
	String get title => 'Budgets';

	/// en: 'New budget'
	String get addBudget => 'New budget';

	/// en: 'Edit budget'
	String get editBudget => 'Edit budget';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Pick a category'
	String get categoryHint => 'Pick a category';

	/// en: 'Select a category'
	String get categoryRequired => 'Select a category';

	/// en: 'Monthly cap'
	String get amount => 'Monthly cap';

	/// en: '0.00'
	String get amountHint => '0.00';

	/// en: 'This month'
	String get summaryTitle => 'This month';

	/// en: 'Total budgeted'
	String get summaryCap => 'Total budgeted';

	/// en: 'Spent'
	String get summarySpent => 'Spent';

	/// en: 'Available'
	String get summaryRemaining => 'Available';

	/// en: '$spent of $cap'
	String spentOf({required Object spent, required Object cap}) => '${spent} of ${cap}';

	/// en: '$value% used'
	String percentageUsed({required Object value}) => '${value}% used';

	/// en: '$value remaining'
	String remainingOf({required Object value}) => '${value} remaining';

	/// en: 'Over by $value'
	String overBy({required Object value}) => 'Over by ${value}';

	/// en: 'On track'
	String get statusSafe => 'On track';

	/// en: 'Watch out'
	String get statusWarning => 'Watch out';

	/// en: 'Over budget'
	String get statusExceeded => 'Over budget';

	/// en: 'Are you sure you want to delete this budget?'
	String get deleteConfirm => 'Are you sure you want to delete this budget?';

	/// en: 'Budget created'
	String get budgetCreated => 'Budget created';

	/// en: 'Budget updated'
	String get budgetUpdated => 'Budget updated';

	/// en: 'Budget deleted'
	String get budgetDeleted => 'Budget deleted';

	/// en: 'There's already a budget for this category.'
	String get duplicateCategory => 'There\'s already a budget for this category.';

	/// en: 'Create at least one expense category first.'
	String get noExpenseCategory => 'Create at least one expense category first.';

	/// en: 'All categories already have a budget.'
	String get allCategoriesBudgeted => 'All categories already have a budget.';

	/// en: 'Take control of your spending'
	String get emptyTitle => 'Take control of your spending';

	/// en: 'Set a monthly cap per expense category. Financo tracks how much you've spent, how much is left, and warns you upfront when you're about to go over.'
	String get emptyBody => 'Set a monthly cap per expense category. Financo tracks how much you\'ve spent, how much is left, and warns you upfront when you\'re about to go over.';

	/// en: 'Ex: R$ 1,500 on Food, R$ 400 on Leisure, R$ 200 on Transport.'
	String get emptyExample => 'Ex: R\$ 1,500 on Food, R\$ 400 on Leisure, R\$ 200 on Transport.';

	/// en: 'Create your first budget'
	String get emptyAction => 'Create your first budget';

	/// en: 'Details'
	String get formDetails => 'Details';

	/// en: 'Category'
	String get formCategorySection => 'Category';

	/// en: 'Import budgets'
	String get importCsv => 'Import budgets';

	/// en: 'Import budgets from CSV'
	String get importCsvIntroTitle => 'Import budgets from CSV';

	/// en: 'Your file must follow the expected format (columns Category, Amount). Each row maps to a root expense category by name; categories that don't exist or already have a budget are skipped. Download the example to see how it works.'
	String get importCsvIntroBody => 'Your file must follow the expected format (columns Category, Amount). Each row maps to a root expense category by name; categories that don\'t exist or already have a budget are skipped. Download the example to see how it works.';

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

	/// en: 'Imported $imported budgets. Skipped $skipped (unknown or duplicate category).'
	String importCsvSuccess({required Object imported, required Object skipped}) => 'Imported ${imported} budgets. Skipped ${skipped} (unknown or duplicate category).';
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

	/// en: 'This action is permanent'
	String get clearDataConfirmHeadline => 'This action is permanent';

	/// en: 'All your transactions, accounts, categories, budgets, bills and chat history will be erased. This cannot be undone.'
	String get clearDataConfirmBody => 'All your transactions, accounts, categories, budgets, bills and chat history will be erased. This cannot be undone.';

	/// en: 'Type your email to confirm'
	String get clearDataConfirmField => 'Type your email to confirm';

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

	/// en: 'Master'
	String get sectionMaster => 'Master';

	/// en: 'Master panel'
	String get masterPanel => 'Master panel';

	/// en: 'Manage users and the access allowlist'
	String get masterPanelDescription => 'Manage users and the access allowlist';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Light palette'
	String get lightPalette => 'Light palette';

	/// en: 'Dark palette'
	String get darkPalette => 'Dark palette';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'System'
	String get languageSystem => 'System';

	/// en: 'English'
	String get languageEnglish => 'English';

	/// en: 'Português'
	String get languagePortuguese => 'Português';
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

	/// en: 'Image not available'
	String get missing => 'Image not available';
}

// Path: chat.handlers
class TranslationsChatHandlersEn {
	TranslationsChatHandlersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Image attached.'
	String get imageAttached => 'Image attached.';

	/// en: 'The AI service is temporarily unavailable due to rate limits. Please wait a moment and try again.'
	String get errorQuota => 'The AI service is temporarily unavailable due to rate limits. Please wait a moment and try again.';

	/// en: 'Sorry, I could not process your message. Please try again.'
	String get errorGeneric => 'Sorry, I could not process your message. Please try again.';

	/// en: 'Unknown action.'
	String get unknownAction => 'Unknown action.';

	/// en: 'Unknown account action.'
	String get unknownAccountAction => 'Unknown account action.';

	/// en: 'Unknown category action.'
	String get unknownCategoryAction => 'Unknown category action.';

	/// en: 'Unknown bill action.'
	String get unknownBillAction => 'Unknown bill action.';

	/// en: 'Unknown budget action.'
	String get unknownBudgetAction => 'Unknown budget action.';

	/// en: 'Invalid amount.'
	String get invalidAmount => 'Invalid amount.';

	/// en: 'Failed to create account: $error'
	String accountCreateFailed({required Object error}) => 'Failed to create account: ${error}';

	/// en: 'Account "$name" created successfully!'
	String accountCreated({required Object name}) => 'Account "${name}" created successfully!';

	/// en: 'No account named "$name" found.'
	String accountNotFound({required Object name}) => 'No account named "${name}" found.';

	/// en: 'Failed to find account: $error'
	String accountLoadFailed({required Object error}) => 'Failed to find account: ${error}';

	/// en: 'Failed to delete account: $error'
	String accountDeleteFailed({required Object error}) => 'Failed to delete account: ${error}';

	/// en: 'Account "$name" deleted successfully!'
	String accountDeleted({required Object name}) => 'Account "${name}" deleted successfully!';

	/// en: 'Failed to create category: $error'
	String categoryCreateFailed({required Object error}) => 'Failed to create category: ${error}';

	/// en: 'Category "$name" created successfully!'
	String categoryCreated({required Object name}) => 'Category "${name}" created successfully!';

	/// en: 'No category named "$name" found.'
	String categoryNotFound({required Object name}) => 'No category named "${name}" found.';

	/// en: 'Failed to find category: $error'
	String categoryLoadFailed({required Object error}) => 'Failed to find category: ${error}';

	/// en: 'Failed to delete category: $error'
	String categoryDeleteFailed({required Object error}) => 'Failed to delete category: ${error}';

	/// en: 'Category "$name" deleted successfully!'
	String categoryDeleted({required Object name}) => 'Category "${name}" deleted successfully!';

	/// en: 'Category is required.'
	String get categoryRequired => 'Category is required.';

	/// en: 'Category "$name" doesn't exist. If this was a transfer between your accounts, ask for "transfer" explicitly; otherwise create the category first.'
	String categoryNotFoundCreateFirst({required Object name}) => 'Category "${name}" doesn\'t exist. If this was a transfer between your accounts, ask for "transfer" explicitly; otherwise create the category first.';

	/// en: 'Failed to load categories.'
	String get transactionLoadCategoriesFailed => 'Failed to load categories.';

	/// en: 'Failed to load accounts.'
	String get transactionLoadAccountsFailed => 'Failed to load accounts.';

	/// en: 'Create an account first.'
	String get transactionCreateAccountFirst => 'Create an account first.';

	/// en: 'Could not resolve account.'
	String get transactionUnresolvedAccount => 'Could not resolve account.';

	/// en: 'Failed to create transaction: $error'
	String transactionCreateFailed({required Object error}) => 'Failed to create transaction: ${error}';

	/// en: 'Transaction "$description" of $amount created successfully!'
	String transactionCreated({required Object description, required Object amount}) => 'Transaction "${description}" of ${amount} created successfully!';

	/// en: 'Transfer needs both source and destination accounts.'
	String get transferAccountsRequired => 'Transfer needs both source and destination accounts.';

	/// en: 'Transfer requires at least two accounts.'
	String get transferMinTwoAccounts => 'Transfer requires at least two accounts.';

	/// en: 'Source and destination must be different accounts.'
	String get transferSourceDestSame => 'Source and destination must be different accounts.';

	/// en: 'Could not resolve source account.'
	String get transferUnresolvedSource => 'Could not resolve source account.';

	/// en: 'Could not resolve destination account.'
	String get transferUnresolvedDestination => 'Could not resolve destination account.';

	/// en: 'Failed to create transfer: $error'
	String transferCreateFailed({required Object error}) => 'Failed to create transfer: ${error}';

	/// en: 'Transfer of $amount from "$from" to "$to" created successfully!'
	String transferCreated({required Object amount, required Object from, required Object to}) => 'Transfer of ${amount} from "${from}" to "${to}" created successfully!';

	/// en: 'Bill description is required.'
	String get billDescriptionRequired => 'Bill description is required.';

	/// en: 'Invalid bill amount.'
	String get billAmountInvalid => 'Invalid bill amount.';

	/// en: 'Failed to create bill: $error'
	String billCreateFailed({required Object error}) => 'Failed to create bill: ${error}';

	/// en: 'Bill "$description" of $amount scheduled for $dueDate.'
	String billCreated({required Object description, required Object amount, required Object dueDate}) => 'Bill "${description}" of ${amount} scheduled for ${dueDate}.';

	/// en: 'Bill id required.'
	String get billIdRequired => 'Bill id required.';

	/// en: 'Bill not found.'
	String get billNotFound => 'Bill not found.';

	/// en: 'Bill is already paid and cannot be edited.'
	String get billCannotEditPaid => 'Bill is already paid and cannot be edited.';

	/// en: 'Failed to update bill: $error'
	String billUpdateFailed({required Object error}) => 'Failed to update bill: ${error}';

	/// en: 'Bill "$description" updated.'
	String billUpdated({required Object description}) => 'Bill "${description}" updated.';

	/// en: 'Bill is already paid.'
	String get billAlreadyPaid => 'Bill is already paid.';

	/// en: 'No checking account available to register the payment.'
	String get billNoCheckingAccount => 'No checking account available to register the payment.';

	/// en: 'No income category available to register the payment.'
	String get billNoIncomeCategory => 'No income category available to register the payment.';

	/// en: 'No expense category available to register the payment.'
	String get billNoExpenseCategory => 'No expense category available to register the payment.';

	/// en: 'Failed to mark bill as paid: $error'
	String billPayFailed({required Object error}) => 'Failed to mark bill as paid: ${error}';

	/// en: 'Bill "$description" paid — transaction created.'
	String billPaid({required Object description}) => 'Bill "${description}" paid — transaction created.';

	/// en: 'Bill "$description" paid — transaction created. Next occurrence scheduled for $dueDate.'
	String billPaidWithNext({required Object description, required Object dueDate}) => 'Bill "${description}" paid — transaction created. Next occurrence scheduled for ${dueDate}.';

	/// en: 'Failed to delete bill: $error'
	String billDeleteFailed({required Object error}) => 'Failed to delete bill: ${error}';

	/// en: 'Bill deleted.'
	String get billDeleted => 'Bill deleted.';

	/// en: 'A category is required for the budget.'
	String get budgetCategoryRequired => 'A category is required for the budget.';

	/// en: 'Category "$name" not found.'
	String budgetCategoryNotFound({required Object name}) => 'Category "${name}" not found.';

	/// en: 'Category "$name" doesn't exist. Create it first.'
	String budgetCategoryNotFoundCreate({required Object name}) => 'Category "${name}" doesn\'t exist. Create it first.';

	/// en: 'Budgets are only available for expense categories.'
	String get budgetExpenseOnly => 'Budgets are only available for expense categories.';

	/// en: 'Budgets can only be set on root categories. Use the root "$name".'
	String budgetRootCategoryOnly({required Object name}) => 'Budgets can only be set on root categories. Use the root "${name}".';

	/// en: 'There's already a budget for "$name". Use "update" to change the value.'
	String budgetAlreadyExists({required Object name}) => 'There\'s already a budget for "${name}". Use "update" to change the value.';

	/// en: 'No budget for "$name" yet. Use "create" to define one.'
	String budgetDoesNotExist({required Object name}) => 'No budget for "${name}" yet. Use "create" to define one.';

	/// en: 'Budget amount must be greater than zero.'
	String get budgetAmountPositive => 'Budget amount must be greater than zero.';

	/// en: 'Couldn't load budgets.'
	String get budgetLoadFailed => 'Couldn\'t load budgets.';

	/// en: 'Couldn't load categories.'
	String get budgetLoadCategoriesFailed => 'Couldn\'t load categories.';

	/// en: 'Failed to create budget: $error'
	String budgetCreateFailed({required Object error}) => 'Failed to create budget: ${error}';

	/// en: 'Budget of $amount on "$name" created.'
	String budgetCreated({required Object amount, required Object name}) => 'Budget of ${amount} on "${name}" created.';

	/// en: 'No active budget for "$name".'
	String budgetNoActive({required Object name}) => 'No active budget for "${name}".';

	/// en: 'Failed to update budget: $error'
	String budgetUpdateFailed({required Object error}) => 'Failed to update budget: ${error}';

	/// en: 'Budget of "$name" updated to $amount.'
	String budgetUpdated({required Object name, required Object amount}) => 'Budget of "${name}" updated to ${amount}.';

	/// en: 'Failed to remove budget: $error'
	String budgetDeleteFailed({required Object error}) => 'Failed to remove budget: ${error}';

	/// en: 'Budget of "$name" removed.'
	String budgetDeleted({required Object name}) => 'Budget of "${name}" removed.';

	/// en: 'Which account should I use? Please tell me the account name.'
	String get resolveAccountMissing => 'Which account should I use? Please tell me the account name.';

	/// en: 'Account "$query" not found. Please create it first or use the exact name.'
	String resolveAccountNotFound({required Object query}) => 'Account "${query}" not found. Please create it first or use the exact name.';

	/// en: 'Multiple accounts match "$query": $names. Please be more specific.'
	String resolveAccountMultiple({required Object query, required Object names}) => 'Multiple accounts match "${query}": ${names}. Please be more specific.';
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
			'auth.signOut' => 'Sign Out',
			'auth.email' => 'Email',
			'auth.emailHint' => 'your@email.com',
			'auth.continueWithGoogle' => 'Continue with Google',
			'auth.accessByInviteOnly' => 'Access is by invite only.',
			'accessControl.restrictedTitle' => 'Restricted access',
			'accessControl.restrictedBody' => 'Ask Guilherme to grant access for your email:',
			'accessControl.restrictedBack' => 'Back',
			'masterPanel.title' => 'Master panel',
			'masterPanel.tabUsers' => 'Users',
			'masterPanel.tabAllowlist' => 'Allowlist',
			'masterPanel.usersEmpty' => 'No registered users yet.',
			'masterPanel.allowlistEmpty' => 'No emails authorized yet.',
			'masterPanel.masterBadge' => 'MASTER',
			'masterPanel.addEmailTitle' => 'Authorize email',
			'masterPanel.addEmailNoteLabel' => 'Note (optional)',
			'masterPanel.addEmailNoteHint' => 'e.g. friend\'s name',
			'masterPanel.addEmailSuccess' => 'Email authorized.',
			'masterPanel.removeEmailTitle' => 'Remove access',
			'masterPanel.removeEmailBody' => ({required Object email}) => 'This removes access for ${email}. Their existing data is kept.',
			'masterPanel.removeEmailConfirm' => 'Remove',
			'masterPanel.removeEmailSuccess' => 'Email removed from allowlist.',
			'masterPanel.deleteUserTitle' => 'Delete user',
			'masterPanel.deleteUserBody' => ({required Object name}) => 'This permanently deletes ${name} and all of their data. Type the email to confirm.',
			'masterPanel.deleteUserConfirmField' => 'Type the email',
			'masterPanel.deleteUserSuccess' => 'User deleted.',
			'onboarding.tagline' => 'Take control of your personal finances\nwith smart tracking and AI assistance.',
			'onboarding.step1Title' => 'Track Your Finances',
			'onboarding.step1Body' => 'Log income and expenses effortlessly. Keep a clear view of where your money goes.',
			'onboarding.step2Title' => 'AI-Powered Entry',
			'onboarding.step2Body' => 'Just type naturally — our AI chat extracts transaction data for you automatically.',
			'onboarding.step3Title' => 'Insightful Reports',
			'onboarding.step3Body' => 'Beautiful charts and summaries help you understand your spending habits.',
			'onboarding.next' => 'Next',
			'onboarding.skip' => 'Skip',
			'nav.dashboard' => 'Dashboard',
			'nav.transactions' => 'Transactions',
			'nav.chat' => 'Chat',
			'nav.reports' => 'Reports',
			'nav.profile' => 'Profile',
			'nav.bills' => 'Bills',
			'nav.budgets' => 'Budgets',
			'nav.planning' => 'Planning',
			'dashboard.title' => 'Dashboard',
			'dashboard.totalBalance' => 'Total Balance',
			'dashboard.income' => 'Income',
			'dashboard.expenses' => 'Expenses',
			'dashboard.netResult' => 'Result',
			'dashboard.recentTransactions' => 'Recent Transactions',
			'dashboard.seeAll' => 'See all',
			'dashboard.thisMonth' => 'This month',
			'dashboard.noTransactionsYet' => 'No transactions yet',
			'dashboard.accountBalances' => 'Balances',
			'dashboard.monthResult' => 'Month Result',
			'dashboard.expensesByCategory' => 'Expenses by Category',
			'dashboard.incomeByCategory' => 'Income by Category',
			'dashboard.noAccountsYet' => 'No accounts registered yet',
			'dashboard.creditCardBalance' => 'Credit Card Balance',
			'dashboard.noCreditCardsYet' => 'No credit cards registered yet',
			'dashboard.investmentBalance' => 'Investments',
			'dashboard.noInvestmentsYet' => 'No investment accounts registered yet',
			'dashboard.noExpensesYet' => 'No expenses this month',
			'dashboard.noIncomeYet' => 'No income this month',
			'dashboard.totalExpenses' => 'Total Expenses',
			'dashboard.totalIncome' => 'Total Income',
			'dashboard.transactionList' => 'Transaction list',
			'dashboard.subcategories' => 'Subcategories',
			'dashboard.noSubcategories' => 'No subcategories',
			'dashboard.total' => 'Total',
			'dashboard.close' => 'Close',
			'fiftyThirtyTwenty.title' => '50/30/20',
			'fiftyThirtyTwenty.subtitle' => 'How your month is going',
			'fiftyThirtyTwenty.needsLabel' => 'Needs',
			'fiftyThirtyTwenty.wantsLabel' => 'Wants',
			'fiftyThirtyTwenty.savingsLabel' => 'Savings',
			'fiftyThirtyTwenty.ofTarget' => ({required Object actual, required Object target}) => '${actual}% of ${target}%',
			'fiftyThirtyTwenty.baselinePill' => ({required Object value}) => '100% = ${value}',
			'fiftyThirtyTwenty.noIncomeHeadline' => 'Log income for this month to track the 50/30/20 rule.',
			'fiftyThirtyTwenty.onTrackHeadline' => 'You\'re on track.',
			'fiftyThirtyTwenty.needsAttentionHeadline' => 'A few tweaks would help.',
			'fiftyThirtyTwenty.unclassifiedDominantHeadline' => 'Classify your categories for an accurate read.',
			'fiftyThirtyTwenty.tipNeedsOver' => ({required Object value}) => 'Trim ${value} off needs to hit the target.',
			'fiftyThirtyTwenty.tipWantsOver' => ({required Object value}) => 'You went ${value} over your wants budget this month.',
			'fiftyThirtyTwenty.tipSavingsShortWithAccount' => ({required Object value}) => 'Add ${value} to hit 20% savings.',
			'fiftyThirtyTwenty.tipSavingsShortNoAccount' => 'Create an investment account to start logging contributions.',
			'fiftyThirtyTwenty.tipUnclassified' => ({required Object count}) => '${count} category(ies) still need classification.',
			'fiftyThirtyTwenty.ctaCreateInvestment' => 'Create account',
			'fiftyThirtyTwenty.ctaClassify' => 'Classify',
			'fiftyThirtyTwenty.unclassifiedLabel' => 'Unclassified',
			'fiftyThirtyTwenty.principalDisclaimer' => 'Savings here = monthly contributions (transfers checking → investment). Market yield is not tracked.',
			'fiftyThirtyTwenty.editTargets' => 'Edit targets',
			'fiftyThirtyTwenty.editTargetsHint' => 'Set the percentage for each bucket. The three must add up to 100%.',
			'fiftyThirtyTwenty.resetToClassic' => 'Reset to 50/30/20',
			'fiftyThirtyTwenty.sumOk' => ({required Object percent}) => 'Total: ${percent}% ✓',
			'fiftyThirtyTwenty.sumInvalid' => ({required Object percent}) => 'Total: ${percent}% — must be 100%',
			'fiftyThirtyTwenty.spentOfTarget' => ({required Object spent, required Object target}) => '${spent} / ${target}',
			'fiftyThirtyTwenty.bucketEmpty' => 'No expenses in this bucket this month.',
			'fiftyThirtyTwenty.historyTitle' => 'Last 3 months',
			'fiftyThirtyTwenty.historyEmpty' => 'No history to show yet.',
			'fiftyThirtyTwenty.navLabel' => 'Planning',
			'fiftyThirtyTwenty.subTabBudgets' => 'Budgets',
			'fiftyThirtyTwenty.subTabFiftyThirtyTwenty' => '50/30/20',
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
			'transactions.descriptionOptional' => 'Description (optional)',
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
			'transactions.saveAndAddAnother' => 'Save and add another',
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
			'accounts.investment' => 'Savings Account',
			'accounts.checkingShort' => 'Checking',
			'accounts.investmentShort' => 'Savings',
			'accounts.investmentDescription' => 'Dedicated account for contributions. Shows up as \'investment\' on transfers and feeds the 50/30/20 card.',
			'accounts.investmentYieldDisclaimer' => 'Balance reflects only your contributions (principal). Market yield is not tracked.',
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
			'categories.subcategoryAppearanceInherited' => 'Subcategories inherit the parent category\'s icon and color.',
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
			'categories.formSectionBucket' => '50/30/20 rule',
			'categories.bucketHint' => 'Which group does this category fit into?',
			'categories.incomeCountsTitle' => 'Count toward 50/30/20',
			'categories.incomeCountsHint' => 'When on, income on this category feeds the monthly base (100%). Turn off for one-off receipts (reimbursements, gifts, sold goods) that would otherwise distort the breakdown.',
			'categories.bucketNeeds' => 'Need',
			'categories.bucketWants' => 'Want',
			'categories.bucketUnclassified' => 'Unclassified',
			'categories.bucketHelp' => 'Needs cover essentials (rent, groceries, transport). Wants cover discretionary (leisure, dining out). Savings is handled by transfers to investment accounts.',
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
			'chat.audio.permissionDenied' => 'Microphone permission required to record voice.',
			'chat.audio.recordError' => 'Failed to record audio',
			'chat.image.attach' => 'Attach image',
			'chat.image.takePhoto' => 'Take photo',
			'chat.image.fromGallery' => 'Choose from gallery',
			'chat.image.remove' => 'Remove image',
			'chat.image.pickError' => 'Could not pick image',
			'chat.image.missing' => 'Image not available',
			'chat.handlers.imageAttached' => 'Image attached.',
			'chat.handlers.errorQuota' => 'The AI service is temporarily unavailable due to rate limits. Please wait a moment and try again.',
			'chat.handlers.errorGeneric' => 'Sorry, I could not process your message. Please try again.',
			'chat.handlers.unknownAction' => 'Unknown action.',
			'chat.handlers.unknownAccountAction' => 'Unknown account action.',
			'chat.handlers.unknownCategoryAction' => 'Unknown category action.',
			'chat.handlers.unknownBillAction' => 'Unknown bill action.',
			'chat.handlers.unknownBudgetAction' => 'Unknown budget action.',
			'chat.handlers.invalidAmount' => 'Invalid amount.',
			'chat.handlers.accountCreateFailed' => ({required Object error}) => 'Failed to create account: ${error}',
			'chat.handlers.accountCreated' => ({required Object name}) => 'Account "${name}" created successfully!',
			'chat.handlers.accountNotFound' => ({required Object name}) => 'No account named "${name}" found.',
			'chat.handlers.accountLoadFailed' => ({required Object error}) => 'Failed to find account: ${error}',
			'chat.handlers.accountDeleteFailed' => ({required Object error}) => 'Failed to delete account: ${error}',
			'chat.handlers.accountDeleted' => ({required Object name}) => 'Account "${name}" deleted successfully!',
			'chat.handlers.categoryCreateFailed' => ({required Object error}) => 'Failed to create category: ${error}',
			'chat.handlers.categoryCreated' => ({required Object name}) => 'Category "${name}" created successfully!',
			'chat.handlers.categoryNotFound' => ({required Object name}) => 'No category named "${name}" found.',
			'chat.handlers.categoryLoadFailed' => ({required Object error}) => 'Failed to find category: ${error}',
			'chat.handlers.categoryDeleteFailed' => ({required Object error}) => 'Failed to delete category: ${error}',
			'chat.handlers.categoryDeleted' => ({required Object name}) => 'Category "${name}" deleted successfully!',
			'chat.handlers.categoryRequired' => 'Category is required.',
			'chat.handlers.categoryNotFoundCreateFirst' => ({required Object name}) => 'Category "${name}" doesn\'t exist. If this was a transfer between your accounts, ask for "transfer" explicitly; otherwise create the category first.',
			'chat.handlers.transactionLoadCategoriesFailed' => 'Failed to load categories.',
			'chat.handlers.transactionLoadAccountsFailed' => 'Failed to load accounts.',
			'chat.handlers.transactionCreateAccountFirst' => 'Create an account first.',
			'chat.handlers.transactionUnresolvedAccount' => 'Could not resolve account.',
			'chat.handlers.transactionCreateFailed' => ({required Object error}) => 'Failed to create transaction: ${error}',
			'chat.handlers.transactionCreated' => ({required Object description, required Object amount}) => 'Transaction "${description}" of ${amount} created successfully!',
			'chat.handlers.transferAccountsRequired' => 'Transfer needs both source and destination accounts.',
			'chat.handlers.transferMinTwoAccounts' => 'Transfer requires at least two accounts.',
			'chat.handlers.transferSourceDestSame' => 'Source and destination must be different accounts.',
			'chat.handlers.transferUnresolvedSource' => 'Could not resolve source account.',
			'chat.handlers.transferUnresolvedDestination' => 'Could not resolve destination account.',
			'chat.handlers.transferCreateFailed' => ({required Object error}) => 'Failed to create transfer: ${error}',
			'chat.handlers.transferCreated' => ({required Object amount, required Object from, required Object to}) => 'Transfer of ${amount} from "${from}" to "${to}" created successfully!',
			'chat.handlers.billDescriptionRequired' => 'Bill description is required.',
			'chat.handlers.billAmountInvalid' => 'Invalid bill amount.',
			'chat.handlers.billCreateFailed' => ({required Object error}) => 'Failed to create bill: ${error}',
			'chat.handlers.billCreated' => ({required Object description, required Object amount, required Object dueDate}) => 'Bill "${description}" of ${amount} scheduled for ${dueDate}.',
			'chat.handlers.billIdRequired' => 'Bill id required.',
			'chat.handlers.billNotFound' => 'Bill not found.',
			'chat.handlers.billCannotEditPaid' => 'Bill is already paid and cannot be edited.',
			'chat.handlers.billUpdateFailed' => ({required Object error}) => 'Failed to update bill: ${error}',
			'chat.handlers.billUpdated' => ({required Object description}) => 'Bill "${description}" updated.',
			'chat.handlers.billAlreadyPaid' => 'Bill is already paid.',
			'chat.handlers.billNoCheckingAccount' => 'No checking account available to register the payment.',
			'chat.handlers.billNoIncomeCategory' => 'No income category available to register the payment.',
			'chat.handlers.billNoExpenseCategory' => 'No expense category available to register the payment.',
			'chat.handlers.billPayFailed' => ({required Object error}) => 'Failed to mark bill as paid: ${error}',
			'chat.handlers.billPaid' => ({required Object description}) => 'Bill "${description}" paid — transaction created.',
			'chat.handlers.billPaidWithNext' => ({required Object description, required Object dueDate}) => 'Bill "${description}" paid — transaction created. Next occurrence scheduled for ${dueDate}.',
			'chat.handlers.billDeleteFailed' => ({required Object error}) => 'Failed to delete bill: ${error}',
			'chat.handlers.billDeleted' => 'Bill deleted.',
			'chat.handlers.budgetCategoryRequired' => 'A category is required for the budget.',
			'chat.handlers.budgetCategoryNotFound' => ({required Object name}) => 'Category "${name}" not found.',
			'chat.handlers.budgetCategoryNotFoundCreate' => ({required Object name}) => 'Category "${name}" doesn\'t exist. Create it first.',
			'chat.handlers.budgetExpenseOnly' => 'Budgets are only available for expense categories.',
			'chat.handlers.budgetRootCategoryOnly' => ({required Object name}) => 'Budgets can only be set on root categories. Use the root "${name}".',
			'chat.handlers.budgetAlreadyExists' => ({required Object name}) => 'There\'s already a budget for "${name}". Use "update" to change the value.',
			'chat.handlers.budgetDoesNotExist' => ({required Object name}) => 'No budget for "${name}" yet. Use "create" to define one.',
			'chat.handlers.budgetAmountPositive' => 'Budget amount must be greater than zero.',
			'chat.handlers.budgetLoadFailed' => 'Couldn\'t load budgets.',
			'chat.handlers.budgetLoadCategoriesFailed' => 'Couldn\'t load categories.',
			'chat.handlers.budgetCreateFailed' => ({required Object error}) => 'Failed to create budget: ${error}',
			'chat.handlers.budgetCreated' => ({required Object amount, required Object name}) => 'Budget of ${amount} on "${name}" created.',
			'chat.handlers.budgetNoActive' => ({required Object name}) => 'No active budget for "${name}".',
			'chat.handlers.budgetUpdateFailed' => ({required Object error}) => 'Failed to update budget: ${error}',
			'chat.handlers.budgetUpdated' => ({required Object name, required Object amount}) => 'Budget of "${name}" updated to ${amount}.',
			'chat.handlers.budgetDeleteFailed' => ({required Object error}) => 'Failed to remove budget: ${error}',
			'chat.handlers.budgetDeleted' => ({required Object name}) => 'Budget of "${name}" removed.',
			'chat.handlers.resolveAccountMissing' => 'Which account should I use? Please tell me the account name.',
			'chat.handlers.resolveAccountNotFound' => ({required Object query}) => 'Account "${query}" not found. Please create it first or use the exact name.',
			'chat.handlers.resolveAccountMultiple' => ({required Object query, required Object names}) => 'Multiple accounts match "${query}": ${names}. Please be more specific.',
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
			_ => null,
		} ?? switch (path) {
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
			'bills.virtualBlocked' => 'Pay the current occurrence first',
			'bills.preview' => 'Preview',
			'bills.editScopeTitle' => 'Apply to which occurrences?',
			'bills.editScopeDescription' => 'This is a recurring bill. You can apply the change to this occurrence only, or also to future ones (past occurrences are never affected).',
			'bills.editScopeOnlyThis' => 'Only this one',
			'bills.editScopeAlsoSubsequents' => 'This and the following',
			'bills.importCsv' => 'Import bills',
			'bills.importCsvIntroTitle' => 'Import bills from CSV',
			'bills.importCsvIntroBody' => 'Your file must follow the expected format (columns Type, Description, Amount, Due Date, Status, Recurrence, Category, Notes — where Type is Payable/Receivable, Status is Pending/Paid and Recurrence is Monthly/One-time). Download the example to see how it works.',
			'bills.importCsvDownloadExample' => 'Download example',
			'bills.importCsvSelectFile' => 'Select file',
			'bills.importCsvExampleDownloaded' => 'Example saved.',
			'bills.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'bills.importCsvErrorTitle' => 'Couldn\'t import the CSV',
			'bills.importCsvSuccess' => ({required Object imported, required Object skipped}) => 'Imported ${imported} bills. Skipped ${skipped} (unknown category).',
			'budgets.title' => 'Budgets',
			'budgets.addBudget' => 'New budget',
			'budgets.editBudget' => 'Edit budget',
			'budgets.category' => 'Category',
			'budgets.categoryHint' => 'Pick a category',
			'budgets.categoryRequired' => 'Select a category',
			'budgets.amount' => 'Monthly cap',
			'budgets.amountHint' => '0.00',
			'budgets.summaryTitle' => 'This month',
			'budgets.summaryCap' => 'Total budgeted',
			'budgets.summarySpent' => 'Spent',
			'budgets.summaryRemaining' => 'Available',
			'budgets.spentOf' => ({required Object spent, required Object cap}) => '${spent} of ${cap}',
			'budgets.percentageUsed' => ({required Object value}) => '${value}% used',
			'budgets.remainingOf' => ({required Object value}) => '${value} remaining',
			'budgets.overBy' => ({required Object value}) => 'Over by ${value}',
			'budgets.statusSafe' => 'On track',
			'budgets.statusWarning' => 'Watch out',
			'budgets.statusExceeded' => 'Over budget',
			'budgets.deleteConfirm' => 'Are you sure you want to delete this budget?',
			'budgets.budgetCreated' => 'Budget created',
			'budgets.budgetUpdated' => 'Budget updated',
			'budgets.budgetDeleted' => 'Budget deleted',
			'budgets.duplicateCategory' => 'There\'s already a budget for this category.',
			'budgets.noExpenseCategory' => 'Create at least one expense category first.',
			'budgets.allCategoriesBudgeted' => 'All categories already have a budget.',
			'budgets.emptyTitle' => 'Take control of your spending',
			'budgets.emptyBody' => 'Set a monthly cap per expense category. Financo tracks how much you\'ve spent, how much is left, and warns you upfront when you\'re about to go over.',
			'budgets.emptyExample' => 'Ex: R\$ 1,500 on Food, R\$ 400 on Leisure, R\$ 200 on Transport.',
			'budgets.emptyAction' => 'Create your first budget',
			'budgets.formDetails' => 'Details',
			'budgets.formCategorySection' => 'Category',
			'budgets.importCsv' => 'Import budgets',
			'budgets.importCsvIntroTitle' => 'Import budgets from CSV',
			'budgets.importCsvIntroBody' => 'Your file must follow the expected format (columns Category, Amount). Each row maps to a root expense category by name; categories that don\'t exist or already have a budget are skipped. Download the example to see how it works.',
			'budgets.importCsvDownloadExample' => 'Download example',
			'budgets.importCsvSelectFile' => 'Select file',
			'budgets.importCsvExampleDownloaded' => 'Example saved.',
			'budgets.importCsvExampleFailed' => 'Couldn\'t save the example file.',
			'budgets.importCsvErrorTitle' => 'Couldn\'t import the CSV',
			'budgets.importCsvSuccess' => ({required Object imported, required Object skipped}) => 'Imported ${imported} budgets. Skipped ${skipped} (unknown or duplicate category).',
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
			'profile.clearDataConfirmHeadline' => 'This action is permanent',
			'profile.clearDataConfirmBody' => 'All your transactions, accounts, categories, budgets, bills and chat history will be erased. This cannot be undone.',
			'profile.clearDataConfirmField' => 'Type your email to confirm',
			'profile.clearDataSuccess' => 'Your account data was cleared.',
			'profile.downloadApk' => 'Download Android app',
			'profile.downloadApkDescription' => 'Install the mobile version on your Android device',
			'profile.sectionYourData' => 'Your data',
			'profile.sectionPreferences' => 'Preferences',
			'profile.sectionGetTheApp' => 'Get the app',
			'profile.sectionAccount' => 'Account',
			'profile.sectionDangerZone' => 'Danger zone',
			'profile.sectionMaster' => 'Master',
			'profile.masterPanel' => 'Master panel',
			'profile.masterPanelDescription' => 'Manage users and the access allowlist',
			'profile.appearance' => 'Appearance',
			'profile.version' => 'Version',
			'profile.lightPalette' => 'Light palette',
			'profile.darkPalette' => 'Dark palette',
			'profile.language' => 'Language',
			'profile.languageSystem' => 'System',
			'profile.languageEnglish' => 'English',
			'profile.languagePortuguese' => 'Português',
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
