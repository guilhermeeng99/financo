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
	@override String get register => 'Registrar';
	@override String get categories => 'Categorias';
	@override String get show_only_active_categories => 'Mostrar apenas categorias ativas';
	@override String get export_categories => 'Exportar Categorias';
	@override String get show_only_active_accounts => 'Mostrar apenas contas ativas';
	@override String get accounts => 'Contas';
	@override String get to_pay => 'A Pagar';
	@override String get paied => 'Pago';
	@override String get type => 'Tipo';
	@override String get income => 'Receita';
	@override String get expense => 'Despesa';
	@override String get edit => 'Editar';
	@override String get delete => 'Excluir';
	@override String get coin => 'Moeda';
	@override String get available_balance => 'Saldo disponível';
	@override String get name => 'Nome';
	@override String get save => 'Salvar';
	@override late final _TranslationsAccountTypePt account_type = _TranslationsAccountTypePt._(_root);
	@override late final _TranslationsCurrencyTypePt currency_type = _TranslationsCurrencyTypePt._(_root);
	@override String get new_account => 'Nova Conta';
	@override String get edit_account => 'Editar Conta';
	@override String get new_category => 'Nova Categoria';
	@override String get edit_category => 'Editar Categoria';
	@override String get create_sub_category => 'Criar Subcategoria';
	@override String get additional_settings => 'Configurações Adicionais';
	@override String get subcategory_of => 'Subcategoria de';
	@override String get uncategorized_parent => 'Sem categoria pai';
	@override String get category_name_already_exists => 'Já existe uma categoria com este nome';
	@override String get freeze => 'Congelar';
	@override String get unfreeze => 'Descongelar';
	@override String get balance => 'Saldo';
	@override String get icon => 'Ícone';
	@override String get initial_balance_date => 'Data do saldo inicial';
	@override String get import_categories => 'Importar Categorias';
	@override String get export_successfully => 'Exportado com sucesso!';
	@override String get export_error => 'Erro ao exportar';
	@override String get download_example => 'Baixar Exemplo';
	@override String get choose_file => 'Escolher Arquivo';
	@override String get excel_not_found => 'Arquivo Excel não encontrado';
	@override String get excel_not_valid => 'Arquivo Excel inválido';
	@override String get excel_import_successfully => 'Arquivo Excel importado com sucesso';
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

// Path: currency_type
class _TranslationsCurrencyTypePt extends TranslationsCurrencyTypeEn {
	_TranslationsCurrencyTypePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get brl => 'Real';
	@override String get usd => 'Dólar';
	@override String get eur => 'Euro';
}
