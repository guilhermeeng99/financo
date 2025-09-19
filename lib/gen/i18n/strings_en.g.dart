///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
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
	late final TranslationsNavigationEn navigation = TranslationsNavigationEn._(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsPastAndFutureReleasesEn past_and_future_releases = TranslationsPastAndFutureReleasesEn._(_root);
	late final TranslationsAccountsEn accounts = TranslationsAccountsEn._(_root);
	late final TranslationsCategoriesEn categories = TranslationsCategoriesEn._(_root);
	late final TranslationsTransactionsEn transactions = TranslationsTransactionsEn._(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsMessagesEn messages = TranslationsMessagesEn._(_root);
}

// Path: navigation
class TranslationsNavigationEn {
	TranslationsNavigationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overview'
	String get overview => 'Overview';

	/// en: 'Financial movement'
	String get financial_movement => 'Financial movement';

	/// en: 'Paid and received'
	String get paid_and_received => 'Paid and received';

	/// en: 'To pay and to receive'
	String get to_pay_and_to_receive => 'To pay and to receive';

	/// en: 'Account Statement'
	String get account_statement => 'Account Statement';

	/// en: 'Releases'
	String get releases => 'Releases';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Accounts'
	String get accounts => 'Accounts';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCommonActionsEn actions = TranslationsCommonActionsEn._(_root);
	late final TranslationsCommonLabelsEn labels = TranslationsCommonLabelsEn._(_root);
	late final TranslationsCommonFrequencyEn frequency = TranslationsCommonFrequencyEn._(_root);
	late final TranslationsCommonPeriodTypesEn period_types = TranslationsCommonPeriodTypesEn._(_root);
}

// Path: past_and_future_releases
class TranslationsPastAndFutureReleasesEn {
	TranslationsPastAndFutureReleasesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Period result'
	String get period_result => 'Period result';

	/// en: 'Total to pay'
	String get total_to_pay => 'Total to pay';

	/// en: 'Total to receive'
	String get total_to_receive => 'Total to receive';

	/// en: 'Total received'
	String get total_received => 'Total received';

	/// en: 'Total paid'
	String get total_paid => 'Total paid';
}

// Path: accounts
class TranslationsAccountsEn {
	TranslationsAccountsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Account'
	String get new_account => 'New Account';

	/// en: 'Edit Account'
	String get edit_account => 'Edit Account';

	/// en: 'Select Account'
	String get select_account => 'Select Account';

	/// en: 'Origin Account'
	String get origin_account => 'Origin Account';

	/// en: 'Destination Account'
	String get destination_account => 'Destination Account';

	/// en: 'Show Only Active Accounts'
	String get show_only_active => 'Show Only Active Accounts';

	late final TranslationsAccountsTypesEn types = TranslationsAccountsTypesEn._(_root);
	late final TranslationsAccountsValidationEn validation = TranslationsAccountsValidationEn._(_root);
}

// Path: categories
class TranslationsCategoriesEn {
	TranslationsCategoriesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Category'
	String get new_category => 'New Category';

	/// en: 'Edit Category'
	String get edit_category => 'Edit Category';

	/// en: 'Create Subcategory'
	String get create_sub_category => 'Create Subcategory';

	/// en: 'Show Only Active Categories'
	String get show_only_active => 'Show Only Active Categories';

	/// en: 'Export Categories'
	String get export_categories => 'Export Categories';

	/// en: 'Import Categories'
	String get import_categories => 'Import Categories';

	/// en: 'Select Category'
	String get select_category => 'Select Category';

	/// en: 'Subcategory of'
	String get subcategory_of => 'Subcategory of';

	/// en: 'No Category'
	String get no_category => 'No Category';

	late final TranslationsCategoriesValidationEn validation = TranslationsCategoriesValidationEn._(_root);
}

// Path: transactions
class TranslationsTransactionsEn {
	TranslationsTransactionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Transaction'
	String get new_transaction => 'New Transaction';

	/// en: 'Edit Transaction'
	String get edit_transaction => 'Edit Transaction';

	/// en: 'Export Transactions'
	String get export_transactions => 'Export Transactions';

	/// en: 'Import Transactions'
	String get import_transactions => 'Import Transactions';

	/// en: 'Unknown Transfer'
	String get unknown_transfer => 'Unknown Transfer';

	late final TranslationsTransactionsTypesEn types = TranslationsTransactionsTypesEn._(_root);
	late final TranslationsTransactionsRecurrenceTypeEn recurrence_type = TranslationsTransactionsRecurrenceTypeEn._(_root);
	late final TranslationsTransactionsStatusTypeEn status_type = TranslationsTransactionsStatusTypeEn._(_root);
	late final TranslationsTransactionsStatusEn status = TranslationsTransactionsStatusEn._(_root);
	late final TranslationsTransactionsCurrencyEn currency = TranslationsTransactionsCurrencyEn._(_root);
	late final TranslationsTransactionsValidationEn validation = TranslationsTransactionsValidationEn._(_root);
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Additional Settings'
	String get additional_settings => 'Additional Settings';
}

// Path: messages
class TranslationsMessagesEn {
	TranslationsMessagesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsMessagesSuccessEn success = TranslationsMessagesSuccessEn._(_root);
	late final TranslationsMessagesWarningsEn warnings = TranslationsMessagesWarningsEn._(_root);
	late final TranslationsMessagesErrorsEn errors = TranslationsMessagesErrorsEn._(_root);
}

// Path: common.actions
class TranslationsCommonActionsEn {
	TranslationsCommonActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Pay'
	String get pay => 'Pay';

	/// en: 'Cancel Payment'
	String get unpay => 'Cancel Payment';

	/// en: 'Clone'
	String get clone => 'Clone';

	/// en: 'Freeze'
	String get freeze => 'Freeze';

	/// en: 'Unfreeze'
	String get unfreeze => 'Unfreeze';

	/// en: 'Export'
	String get export => 'Export';

	/// en: 'Import'
	String get import => 'Import';

	/// en: 'Choose File'
	String get choose_file => 'Choose File';

	/// en: 'Download Example'
	String get download_example => 'Download Example';
}

// Path: common.labels
class TranslationsCommonLabelsEn {
	TranslationsCommonLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Description'
	String get description => 'Description';

	/// en: '(one) {Account} (other) {Accounts}'
	String account({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Account',
		other: 'Accounts',
	);

	/// en: '(one) {Category} (other) {Categories}'
	String category({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Category',
		other: 'Categories',
	);

	/// en: 'Subcategory'
	String get subcategory => 'Subcategory';

	/// en: 'Transactions'
	String get transactions => 'Transactions';

	/// en: 'Balance'
	String get balance => 'Balance';

	/// en: 'Available Balance'
	String get available_balance => 'Available Balance';

	/// en: 'Initial Balance Date'
	String get initial_balance_date => 'Initial Balance Date';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Icon'
	String get icon => 'Icon';

	/// en: 'Currency'
	String get coin => 'Currency';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Recurrence'
	String get recurrence => 'Recurrence';

	/// en: 'Frequency'
	String get frequency => 'Frequency';

	/// en: 'Entries'
	String get entries => 'Entries';

	/// en: '(one) {Transfer} (other) {Transfers}'
	String transfers({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Transfer',
		other: 'Transfers',
	);

	/// en: 'Exits'
	String get exits => 'Exits';

	/// en: '(one) {Confirmed} (other) {Confirmed}'
	String confirmed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Confirmed',
		other: 'Confirmed',
	);

	/// en: '(one) {Projected} (other) {Projected}'
	String projected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Projected',
		other: 'Projected',
	);

	/// en: '(one) {Pending} (other) {Pending}'
	String pending({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Pending',
		other: 'Pending',
	);

	/// en: '(one) {Result} (other) {Results}'
	String result({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Result',
		other: 'Results',
	);
}

// Path: common.frequency
class TranslationsCommonFrequencyEn {
	TranslationsCommonFrequencyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Daily'
	String get daily => 'Daily';

	/// en: 'Weekly'
	String get weekly => 'Weekly';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Yearly'
	String get yearly => 'Yearly';
}

// Path: common.period_types
class TranslationsCommonPeriodTypesEn {
	TranslationsCommonPeriodTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Daily'
	String get daily => 'Daily';

	/// en: 'Weekly'
	String get weekly => 'Weekly';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Quarterly'
	String get quarterly => 'Quarterly';

	/// en: 'Semester'
	String get semester => 'Semester';

	/// en: 'Custom'
	String get custom => 'Custom';
}

// Path: accounts.types
class TranslationsAccountsTypesEn {
	TranslationsAccountsTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Checking Account'
	String get checking_account => 'Checking Account';

	/// en: 'Credit Card'
	String get credit_card => 'Credit Card';

	/// en: 'Cash'
	String get money => 'Cash';

	/// en: 'Others'
	String get others => 'Others';
}

// Path: accounts.validation
class TranslationsAccountsValidationEn {
	TranslationsAccountsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account name cannot be empty'
	String get name_cannot_be_empty => 'Account name cannot be empty';

	/// en: 'Account name must be at least $number characters long'
	String name_min_length_number({required Object number}) => 'Account name must be at least ${number} characters long';

	/// en: 'Account name must be at most $number characters long'
	String name_max_length_number({required Object number}) => 'Account name must be at most ${number} characters long';

	/// en: 'An account with this name already exists'
	String get name_already_exists => 'An account with this name already exists';

	/// en: 'Currency code must be exactly $number characters long'
	String currency_code_length_number({required Object number}) => 'Currency code must be exactly ${number} characters long';

	/// en: 'Currency code must contain only capital letters'
	String get currency_code_format => 'Currency code must contain only capital letters';

	/// en: 'Balance must be a valid number'
	String get balance_invalid_number => 'Balance must be a valid number';

	/// en: 'Balance cannot be less than $number'
	String balance_min_value_number({required Object number}) => 'Balance cannot be less than ${number}';

	/// en: 'Balance cannot be greater than $number'
	String balance_max_value_number({required Object number}) => 'Balance cannot be greater than ${number}';
}

// Path: categories.validation
class TranslationsCategoriesValidationEn {
	TranslationsCategoriesValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Category name cannot be empty'
	String get name_cannot_be_empty => 'Category name cannot be empty';

	/// en: 'Category name must be at least $number characters long'
	String name_min_length_number({required Object number}) => 'Category name must be at least ${number} characters long';

	/// en: 'Category name must be at most $number characters long'
	String name_max_length_number({required Object number}) => 'Category name must be at most ${number} characters long';

	/// en: 'Parent category ID must be a positive number'
	String get parent_id_must_be_positive => 'Parent category ID must be a positive number';

	/// en: 'Parent Category Not Defined'
	String get uncategorized_parent => 'Parent Category Not Defined';

	/// en: 'A category with this name already exists'
	String get category_name_already_exists => 'A category with this name already exists';
}

// Path: transactions.types
class TranslationsTransactionsTypesEn {
	TranslationsTransactionsTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expense'
	String get expense => 'Expense';
}

// Path: transactions.recurrence_type
class TranslationsTransactionsRecurrenceTypeEn {
	TranslationsTransactionsRecurrenceTypeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unique'
	String get unique => 'Unique';

	/// en: 'Fixed'
	String get fixed => 'Fixed';
}

// Path: transactions.status_type
class TranslationsTransactionsStatusTypeEn {
	TranslationsTransactionsStatusTypeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unpaid'
	String get unpaid => 'Unpaid';

	/// en: 'Paid'
	String get paid => 'Paid';
}

// Path: transactions.status
class TranslationsTransactionsStatusEn {
	TranslationsTransactionsStatusEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'To Pay'
	String get to_pay => 'To Pay';

	/// en: 'Paid'
	String get paid => 'Paid';
}

// Path: transactions.currency
class TranslationsTransactionsCurrencyEn {
	TranslationsTransactionsCurrencyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTransactionsCurrencyTypesEn types = TranslationsTransactionsCurrencyTypesEn._(_root);
}

// Path: transactions.validation
class TranslationsTransactionsValidationEn {
	TranslationsTransactionsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transaction amount must be a valid number'
	String get amount_invalid_number => 'Transaction amount must be a valid number';

	/// en: 'Transaction amount must be different than zero'
	String get amount_cannot_be_zero => 'Transaction amount must be different than zero';

	/// en: 'Transaction description must be at most $number characters long'
	String description_max_length_number({required Object number}) => 'Transaction description must be at most ${number} characters long';

	/// en: 'Account must be selected'
	String get account_must_be_selected => 'Account must be selected';

	/// en: 'Account ID must be a positive number'
	String get account_id_must_be_positive => 'Account ID must be a positive number';

	/// en: 'Category must be selected'
	String get category_must_be_selected => 'Category must be selected';

	/// en: 'Category ID must be a positive number'
	String get category_id_must_be_positive => 'Category ID must be a positive number';

	/// en: 'Transaction date cannot be more than $number years in the past'
	String date_too_far_past_number({required Object number}) => 'Transaction date cannot be more than ${number} years in the past';

	/// en: 'Transaction date cannot be more than $number years in the future'
	String date_too_far_future_number({required Object number}) => 'Transaction date cannot be more than ${number} years in the future';
}

// Path: messages.success
class TranslationsMessagesSuccessEn {
	TranslationsMessagesSuccessEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exported successfully!'
	String get export_successfully => 'Exported successfully!';

	/// en: 'Excel file imported successfully'
	String get excel_import_successfully => 'Excel file imported successfully';
}

// Path: messages.warnings
class TranslationsMessagesWarningsEn {
	TranslationsMessagesWarningsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No changes were provided'
	String get no_changes_provided => 'No changes were provided';
}

// Path: messages.errors
class TranslationsMessagesErrorsEn {
	TranslationsMessagesErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error while exporting'
	String get export_error => 'Error while exporting';

	/// en: 'Excel file not found'
	String get excel_not_found => 'Excel file not found';

	/// en: 'Invalid Excel file'
	String get excel_not_valid => 'Invalid Excel file';
}

// Path: transactions.currency.types
class TranslationsTransactionsCurrencyTypesEn {
	TranslationsTransactionsCurrencyTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Real'
	String get brl => 'Real';

	/// en: 'Dollar'
	String get usd => 'Dollar';

	/// en: 'Euro'
	String get eur => 'Euro';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'navigation.overview': return 'Overview';
			case 'navigation.financial_movement': return 'Financial movement';
			case 'navigation.paid_and_received': return 'Paid and received';
			case 'navigation.to_pay_and_to_receive': return 'To pay and to receive';
			case 'navigation.account_statement': return 'Account Statement';
			case 'navigation.releases': return 'Releases';
			case 'navigation.register': return 'Register';
			case 'navigation.categories': return 'Categories';
			case 'navigation.accounts': return 'Accounts';
			case 'common.actions.edit': return 'Edit';
			case 'common.actions.delete': return 'Delete';
			case 'common.actions.save': return 'Save';
			case 'common.actions.register': return 'Register';
			case 'common.actions.filter': return 'Filter';
			case 'common.actions.pay': return 'Pay';
			case 'common.actions.unpay': return 'Cancel Payment';
			case 'common.actions.clone': return 'Clone';
			case 'common.actions.freeze': return 'Freeze';
			case 'common.actions.unfreeze': return 'Unfreeze';
			case 'common.actions.export': return 'Export';
			case 'common.actions.import': return 'Import';
			case 'common.actions.choose_file': return 'Choose File';
			case 'common.actions.download_example': return 'Download Example';
			case 'common.labels.name': return 'Name';
			case 'common.labels.type': return 'Type';
			case 'common.labels.amount': return 'Amount';
			case 'common.labels.date': return 'Date';
			case 'common.labels.description': return 'Description';
			case 'common.labels.account': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Account',
				other: 'Accounts',
			);
			case 'common.labels.category': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Category',
				other: 'Categories',
			);
			case 'common.labels.subcategory': return 'Subcategory';
			case 'common.labels.transactions': return 'Transactions';
			case 'common.labels.balance': return 'Balance';
			case 'common.labels.available_balance': return 'Available Balance';
			case 'common.labels.initial_balance_date': return 'Initial Balance Date';
			case 'common.labels.total': return 'Total';
			case 'common.labels.icon': return 'Icon';
			case 'common.labels.coin': return 'Currency';
			case 'common.labels.status': return 'Status';
			case 'common.labels.recurrence': return 'Recurrence';
			case 'common.labels.frequency': return 'Frequency';
			case 'common.labels.entries': return 'Entries';
			case 'common.labels.transfers': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Transfer',
				other: 'Transfers',
			);
			case 'common.labels.exits': return 'Exits';
			case 'common.labels.confirmed': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Confirmed',
				other: 'Confirmed',
			);
			case 'common.labels.projected': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Projected',
				other: 'Projected',
			);
			case 'common.labels.pending': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Pending',
				other: 'Pending',
			);
			case 'common.labels.result': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Result',
				other: 'Results',
			);
			case 'common.frequency.daily': return 'Daily';
			case 'common.frequency.weekly': return 'Weekly';
			case 'common.frequency.monthly': return 'Monthly';
			case 'common.frequency.yearly': return 'Yearly';
			case 'common.period_types.daily': return 'Daily';
			case 'common.period_types.weekly': return 'Weekly';
			case 'common.period_types.monthly': return 'Monthly';
			case 'common.period_types.quarterly': return 'Quarterly';
			case 'common.period_types.semester': return 'Semester';
			case 'common.period_types.custom': return 'Custom';
			case 'past_and_future_releases.period_result': return 'Period result';
			case 'past_and_future_releases.total_to_pay': return 'Total to pay';
			case 'past_and_future_releases.total_to_receive': return 'Total to receive';
			case 'past_and_future_releases.total_received': return 'Total received';
			case 'past_and_future_releases.total_paid': return 'Total paid';
			case 'accounts.new_account': return 'New Account';
			case 'accounts.edit_account': return 'Edit Account';
			case 'accounts.select_account': return 'Select Account';
			case 'accounts.origin_account': return 'Origin Account';
			case 'accounts.destination_account': return 'Destination Account';
			case 'accounts.show_only_active': return 'Show Only Active Accounts';
			case 'accounts.types.checking_account': return 'Checking Account';
			case 'accounts.types.credit_card': return 'Credit Card';
			case 'accounts.types.money': return 'Cash';
			case 'accounts.types.others': return 'Others';
			case 'accounts.validation.name_cannot_be_empty': return 'Account name cannot be empty';
			case 'accounts.validation.name_min_length_number': return ({required Object number}) => 'Account name must be at least ${number} characters long';
			case 'accounts.validation.name_max_length_number': return ({required Object number}) => 'Account name must be at most ${number} characters long';
			case 'accounts.validation.name_already_exists': return 'An account with this name already exists';
			case 'accounts.validation.currency_code_length_number': return ({required Object number}) => 'Currency code must be exactly ${number} characters long';
			case 'accounts.validation.currency_code_format': return 'Currency code must contain only capital letters';
			case 'accounts.validation.balance_invalid_number': return 'Balance must be a valid number';
			case 'accounts.validation.balance_min_value_number': return ({required Object number}) => 'Balance cannot be less than ${number}';
			case 'accounts.validation.balance_max_value_number': return ({required Object number}) => 'Balance cannot be greater than ${number}';
			case 'categories.new_category': return 'New Category';
			case 'categories.edit_category': return 'Edit Category';
			case 'categories.create_sub_category': return 'Create Subcategory';
			case 'categories.show_only_active': return 'Show Only Active Categories';
			case 'categories.export_categories': return 'Export Categories';
			case 'categories.import_categories': return 'Import Categories';
			case 'categories.select_category': return 'Select Category';
			case 'categories.subcategory_of': return 'Subcategory of';
			case 'categories.no_category': return 'No Category';
			case 'categories.validation.name_cannot_be_empty': return 'Category name cannot be empty';
			case 'categories.validation.name_min_length_number': return ({required Object number}) => 'Category name must be at least ${number} characters long';
			case 'categories.validation.name_max_length_number': return ({required Object number}) => 'Category name must be at most ${number} characters long';
			case 'categories.validation.parent_id_must_be_positive': return 'Parent category ID must be a positive number';
			case 'categories.validation.uncategorized_parent': return 'Parent Category Not Defined';
			case 'categories.validation.category_name_already_exists': return 'A category with this name already exists';
			case 'transactions.new_transaction': return 'New Transaction';
			case 'transactions.edit_transaction': return 'Edit Transaction';
			case 'transactions.export_transactions': return 'Export Transactions';
			case 'transactions.import_transactions': return 'Import Transactions';
			case 'transactions.unknown_transfer': return 'Unknown Transfer';
			case 'transactions.types.income': return 'Income';
			case 'transactions.types.expense': return 'Expense';
			case 'transactions.recurrence_type.unique': return 'Unique';
			case 'transactions.recurrence_type.fixed': return 'Fixed';
			case 'transactions.status_type.unpaid': return 'Unpaid';
			case 'transactions.status_type.paid': return 'Paid';
			case 'transactions.status.to_pay': return 'To Pay';
			case 'transactions.status.paid': return 'Paid';
			case 'transactions.currency.types.brl': return 'Real';
			case 'transactions.currency.types.usd': return 'Dollar';
			case 'transactions.currency.types.eur': return 'Euro';
			case 'transactions.validation.amount_invalid_number': return 'Transaction amount must be a valid number';
			case 'transactions.validation.amount_cannot_be_zero': return 'Transaction amount must be different than zero';
			case 'transactions.validation.description_max_length_number': return ({required Object number}) => 'Transaction description must be at most ${number} characters long';
			case 'transactions.validation.account_must_be_selected': return 'Account must be selected';
			case 'transactions.validation.account_id_must_be_positive': return 'Account ID must be a positive number';
			case 'transactions.validation.category_must_be_selected': return 'Category must be selected';
			case 'transactions.validation.category_id_must_be_positive': return 'Category ID must be a positive number';
			case 'transactions.validation.date_too_far_past_number': return ({required Object number}) => 'Transaction date cannot be more than ${number} years in the past';
			case 'transactions.validation.date_too_far_future_number': return ({required Object number}) => 'Transaction date cannot be more than ${number} years in the future';
			case 'settings.additional_settings': return 'Additional Settings';
			case 'messages.success.export_successfully': return 'Exported successfully!';
			case 'messages.success.excel_import_successfully': return 'Excel file imported successfully';
			case 'messages.warnings.no_changes_provided': return 'No changes were provided';
			case 'messages.errors.export_error': return 'Error while exporting';
			case 'messages.errors.excel_not_found': return 'Excel file not found';
			case 'messages.errors.excel_not_valid': return 'Invalid Excel file';
			default: return null;
		}
	}
}

