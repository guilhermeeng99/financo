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

	/// en: 'Accounts'
	String get accounts => 'Accounts';

	/// en: 'To Pay'
	String get to_pay => 'To Pay';

	/// en: 'Paied'
	String get paied => 'Paied';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Coin'
	String get coin => 'Coin';

	/// en: 'Available balance'
	String get available_balance => 'Available balance';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Save'
	String get save => 'Save';

	late final TranslationsAccountTypeEn account_type = TranslationsAccountTypeEn.internal(_root);

	/// en: 'New Account'
	String get new_account => 'New Account';

	/// en: 'Additional Settings'
	String get additional_settings => 'Additional Settings';
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
