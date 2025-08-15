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
	@override String get accounts => 'Accounts';
	@override String get to_pay => 'To Pay';
	@override String get paied => 'Paied';
	@override String get type => 'Type';
	@override String get coin => 'Coin';
	@override String get available_balance => 'Available balance';
	@override String get name => 'Name';
	@override String get save => 'Save';
	@override late final _TranslationsAccountTypePt account_type = _TranslationsAccountTypePt._(_root);
	@override String get new_account => 'New Account';
	@override String get additional_settings => 'Additional Settings';
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
