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
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsNavigationEn navigation = TranslationsNavigationEn.internal(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsAccountsEn accounts = TranslationsAccountsEn.internal(_root);
	late final TranslationsCategoriesEn categories = TranslationsCategoriesEn.internal(_root);
	late final TranslationsTransactionsEn transactions = TranslationsTransactionsEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsMessagesEn messages = TranslationsMessagesEn.internal(_root);
}

// Path: navigation
class TranslationsNavigationEn {
	TranslationsNavigationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overview'
	String get overview => 'Overview';

	/// en: 'Releases'
	String get releases => 'Releases';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Accounts'
	String get accounts => 'Accounts';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCommonActionsEn actions = TranslationsCommonActionsEn.internal(_root);
	late final TranslationsCommonLabelsEn labels = TranslationsCommonLabelsEn.internal(_root);
	late final TranslationsCommonFrequencyEn frequency = TranslationsCommonFrequencyEn.internal(_root);
}

// Path: accounts
class TranslationsAccountsEn {
	TranslationsAccountsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Accounts'
	String get title => 'Accounts';

	/// en: 'New Account'
	String get new_account => 'New Account';

	/// en: 'Edit Account'
	String get edit_account => 'Edit Account';

	/// en: 'Select Account'
	String get select_account => 'Select Account';

	/// en: 'Show Only Active Accounts'
	String get show_only_active => 'Show Only Active Accounts';

	late final TranslationsAccountsTypesEn types = TranslationsAccountsTypesEn.internal(_root);
}

// Path: categories
class TranslationsCategoriesEn {
	TranslationsCategoriesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Categories'
	String get title => 'Categories';

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

	/// en: 'Parent Category Not Defined'
	String get uncategorized_parent => 'Parent Category Not Defined';

	/// en: 'A category with this name already exists'
	String get category_name_already_exists => 'A category with this name already exists';
}

// Path: transactions
class TranslationsTransactionsEn {
	TranslationsTransactionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Transaction'
	String get new_transaction => 'New Transaction';

	/// en: 'Edit Transaction'
	String get edit_transaction => 'Edit Transaction';

	late final TranslationsTransactionsTypesEn types = TranslationsTransactionsTypesEn.internal(_root);
	late final TranslationsTransactionsRecurrenceTypeEn recurrence_type = TranslationsTransactionsRecurrenceTypeEn.internal(_root);
	late final TranslationsTransactionsStatusEn status = TranslationsTransactionsStatusEn.internal(_root);
	late final TranslationsTransactionsCurrencyEn currency = TranslationsTransactionsCurrencyEn.internal(_root);
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Additional Settings'
	String get additional_settings => 'Additional Settings';
}

// Path: messages
class TranslationsMessagesEn {
	TranslationsMessagesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsMessagesSuccessEn success = TranslationsMessagesSuccessEn.internal(_root);
	late final TranslationsMessagesErrorsEn errors = TranslationsMessagesErrorsEn.internal(_root);
}

// Path: common.actions
class TranslationsCommonActionsEn {
	TranslationsCommonActionsEn.internal(this._root);

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
	TranslationsCommonLabelsEn.internal(this._root);

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

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Category'
	String get category => 'Category';

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

	/// en: 'Recurrence'
	String get recurrence => 'Recurrence';

	/// en: 'Frequency'
	String get frequency => 'Frequency';
}

// Path: common.frequency
class TranslationsCommonFrequencyEn {
	TranslationsCommonFrequencyEn.internal(this._root);

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

// Path: accounts.types
class TranslationsAccountsTypesEn {
	TranslationsAccountsTypesEn.internal(this._root);

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

// Path: transactions.types
class TranslationsTransactionsTypesEn {
	TranslationsTransactionsTypesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expense'
	String get expense => 'Expense';
}

// Path: transactions.recurrence_type
class TranslationsTransactionsRecurrenceTypeEn {
	TranslationsTransactionsRecurrenceTypeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unique'
	String get unique => 'Unique';

	/// en: 'Fixed'
	String get fixed => 'Fixed';
}

// Path: transactions.status
class TranslationsTransactionsStatusEn {
	TranslationsTransactionsStatusEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'To Pay'
	String get to_pay => 'To Pay';

	/// en: 'Paid'
	String get paid => 'Paid';
}

// Path: transactions.currency
class TranslationsTransactionsCurrencyEn {
	TranslationsTransactionsCurrencyEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTransactionsCurrencyTypesEn types = TranslationsTransactionsCurrencyTypesEn.internal(_root);
}

// Path: messages.success
class TranslationsMessagesSuccessEn {
	TranslationsMessagesSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exported successfully!'
	String get export_successfully => 'Exported successfully!';

	/// en: 'Excel file imported successfully'
	String get excel_import_successfully => 'Excel file imported successfully';
}

// Path: messages.errors
class TranslationsMessagesErrorsEn {
	TranslationsMessagesErrorsEn.internal(this._root);

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
	TranslationsTransactionsCurrencyTypesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Real'
	String get brl => 'Real';

	/// en: 'Dollar'
	String get usd => 'Dollar';

	/// en: 'Euro'
	String get eur => 'Euro';
}
