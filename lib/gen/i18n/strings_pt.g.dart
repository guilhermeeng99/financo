///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPt extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsPt _root = this; // ignore: unused_field

	@override 
	TranslationsPt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPt(meta: meta ?? this.$meta);

	// Translations
	@override String get overview => 'Overview';
	@override String get releases => 'Releases';
	@override String get register => 'Register';
	@override String get categories => 'Categories';
	@override String get show_only_active_categories => 'Show only active categories';
	@override String get accounts => 'Accounts';
	@override String get to_pay => 'To Pay';
	@override String get paied => 'Paied';
	@override String get type => 'Type';
	@override String get income => 'Income';
	@override String get expense => 'Expense';
	@override String get edit => 'Edit';
	@override String get delete => 'Delete';
	@override String get coin => 'Coin';
	@override String get available_balance => 'Available balance';
	@override String get name => 'Name';
	@override String get save => 'Save';
	@override late final _TranslationsAccountTypePt account_type = _TranslationsAccountTypePt._(_root);
	@override late final _TranslationsCurrencyTypePt currency_type = _TranslationsCurrencyTypePt._(_root);
	@override String get new_account => 'New Account';
	@override String get edit_account => 'Edit Account';
	@override String get new_category => 'New Category';
	@override String get edit_category => 'Edit Category';
	@override String get create_sub_category => 'Create Subcategory';
	@override String get additional_settings => 'Additional Settings';
	@override String get subcategory_of => 'Subcategory of';
	@override String get uncategorized_parent => 'Uncategorized parent';
	@override String get freeze => 'Freeze';
	@override String get unfreeze => 'Unfreeze';
	@override String get balance => 'Balance';
	@override String get icon => 'Icon';
	@override String get initial_balance_date => 'Initial balance date';
}

// Path: account_type
class _TranslationsAccountTypePt extends TranslationsAccountTypeEn {
	_TranslationsAccountTypePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get checking_account => 'Checking Account';
	@override String get credit_card => 'Credit Card';
	@override String get money => 'Money';
	@override String get others => 'Others';
}

// Path: currency_type
class _TranslationsCurrencyTypePt extends TranslationsCurrencyTypeEn {
	_TranslationsCurrencyTypePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get brl => 'Real';
	@override String get usd => 'Dolar';
	@override String get eur => 'Euro';
}
