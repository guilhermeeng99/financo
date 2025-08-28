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

	/// en: 'Overview'
	String get overview => 'Overview';

	/// en: 'Releases'
	String get releases => 'Releases';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Show only active categories'
	String get show_only_active_categories => 'Show only active categories';

	/// en: 'Export Categories'
	String get export_categories => 'Export Categories';

	/// en: 'Show only active accounts'
	String get show_only_active_accounts => 'Show only active accounts';

	/// en: 'Accounts'
	String get accounts => 'Accounts';

	/// en: 'To Pay'
	String get to_pay => 'To Pay';

	/// en: 'Paied'
	String get paied => 'Paied';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expense'
	String get expense => 'Expense';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Coin'
	String get coin => 'Coin';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Available balance'
	String get available_balance => 'Available balance';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Amout'
	String get amout => 'Amout';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Recurrence'
	String get recurrence => 'Recurrence';

	/// en: 'Frequency'
	String get frequency => 'Frequency';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Select Category'
	String get select_category => 'Select Category';

	/// en: 'Select Account'
	String get select_account => 'Select Account';

	late final TranslationsAccountTypeEn account_type = TranslationsAccountTypeEn.internal(_root);
	late final TranslationsCurrencyTypeEn currency_type = TranslationsCurrencyTypeEn.internal(_root);

	/// en: 'New Account'
	String get new_account => 'New Account';

	/// en: 'Edit Account'
	String get edit_account => 'Edit Account';

	/// en: 'New Category'
	String get new_category => 'New Category';

	/// en: 'Edit Category'
	String get edit_category => 'Edit Category';

	/// en: 'Create Subcategory'
	String get create_sub_category => 'Create Subcategory';

	/// en: 'Additional Settings'
	String get additional_settings => 'Additional Settings';

	/// en: 'Subcategory of'
	String get subcategory_of => 'Subcategory of';

	/// en: 'Uncategorized parent'
	String get uncategorized_parent => 'Uncategorized parent';

	/// en: 'A category with this name already exists'
	String get category_name_already_exists => 'A category with this name already exists';

	/// en: 'Freeze'
	String get freeze => 'Freeze';

	/// en: 'Unfreeze'
	String get unfreeze => 'Unfreeze';

	/// en: 'Balance'
	String get balance => 'Balance';

	/// en: 'Icon'
	String get icon => 'Icon';

	/// en: 'Initial balance date'
	String get initial_balance_date => 'Initial balance date';

	/// en: 'Import Categories'
	String get import_categories => 'Import Categories';

	/// en: 'Exported successfully!'
	String get export_successfully => 'Exported successfully!';

	/// en: 'Error exporting'
	String get export_error => 'Error exporting';

	/// en: 'Download Example'
	String get download_example => 'Download Example';

	/// en: 'Choose File'
	String get choose_file => 'Choose File';

	/// en: 'Excel file not found'
	String get excel_not_found => 'Excel file not found';

	/// en: 'Excel file not valid'
	String get excel_not_valid => 'Excel file not valid';

	/// en: 'Excel file imported successfully'
	String get excel_import_successfully => 'Excel file imported successfully';

	/// en: 'New Transaction'
	String get new_transaction => 'New Transaction';

	/// en: 'Edit Transaction'
	String get edit_transaction => 'Edit Transaction';
}

// Path: account_type
class TranslationsAccountTypeEn {
	TranslationsAccountTypeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Checking Account'
	String get checking_account => 'Checking Account';

	/// en: 'Credit Card'
	String get credit_card => 'Credit Card';

	/// en: 'Money'
	String get money => 'Money';

	/// en: 'Others'
	String get others => 'Others';
}

// Path: currency_type
class TranslationsCurrencyTypeEn {
	TranslationsCurrencyTypeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Real'
	String get brl => 'Real';

	/// en: 'Dolar'
	String get usd => 'Dolar';

	/// en: 'Euro'
	String get eur => 'Euro';
}
