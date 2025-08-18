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
	@override String get overview => 'Visão Geral';
	@override String get releases => 'Lançamentos';
	@override String get register => 'Cadastrar';
	@override String get categories => 'Categorias';
	@override String get accounts => 'Contas';
	@override String get to_pay => 'A Pagar';
	@override String get paied => 'Pago';
	@override String get type => 'Tipo';
	@override String get coin => 'Moeda';
	@override String get available_balance => 'Saldo disponível';
	@override String get name => 'Nome';
	@override String get save => 'Salvar';
	@override late final _TranslationsAccountTypePt account_type = _TranslationsAccountTypePt._(_root);
	@override String get new_account => 'Nova Conta';
	@override String get additional_settings => 'Configurações Adicionais';
}

// Path: account_type
class _TranslationsAccountTypePt extends TranslationsAccountTypeEn {
	_TranslationsAccountTypePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get checking_account => 'Conta Corrente';
	@override String get credit_card => 'Cartão de Crédito';
	@override String get money => 'Dinheiro';
	@override String get others => 'Outros';
}
