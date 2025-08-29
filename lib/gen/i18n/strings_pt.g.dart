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
	@override late final _TranslationsNavigationPt navigation = _TranslationsNavigationPt._(_root);
	@override late final _TranslationsCommonPt common = _TranslationsCommonPt._(_root);
	@override late final _TranslationsAccountsPt accounts = _TranslationsAccountsPt._(_root);
	@override late final _TranslationsCategoriesPt categories = _TranslationsCategoriesPt._(_root);
	@override late final _TranslationsTransactionsPt transactions = _TranslationsTransactionsPt._(_root);
	@override late final _TranslationsSettingsPt settings = _TranslationsSettingsPt._(_root);
	@override late final _TranslationsMessagesPt messages = _TranslationsMessagesPt._(_root);
}

// Path: navigation
class _TranslationsNavigationPt extends TranslationsNavigationEn {
	_TranslationsNavigationPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get overview => 'Visão Geral';
	@override String get releases => 'Lançamentos';
	@override String get categories => 'Categorias';
	@override String get accounts => 'Contas';
}

// Path: common
class _TranslationsCommonPt extends TranslationsCommonEn {
	_TranslationsCommonPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCommonActionsPt actions = _TranslationsCommonActionsPt._(_root);
	@override late final _TranslationsCommonLabelsPt labels = _TranslationsCommonLabelsPt._(_root);
}

// Path: accounts
class _TranslationsAccountsPt extends TranslationsAccountsEn {
	_TranslationsAccountsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Contas';
	@override String get new_account => 'Nova Conta';
	@override String get edit_account => 'Editar Conta';
	@override String get select_account => 'Selecionar Conta';
	@override String get show_only_active => 'Mostrar apenas contas ativas';
	@override late final _TranslationsAccountsTypesPt types = _TranslationsAccountsTypesPt._(_root);
}

// Path: categories
class _TranslationsCategoriesPt extends TranslationsCategoriesEn {
	_TranslationsCategoriesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Categorias';
	@override String get new_category => 'Nova Categoria';
	@override String get edit_category => 'Editar Categoria';
	@override String get create_sub_category => 'Criar Subcategoria';
	@override String get show_only_active => 'Mostrar apenas categorias ativas';
	@override String get export_categories => 'Exportar Categorias';
	@override String get import_categories => 'Importar Categorias';
	@override String get select_category => 'Selecionar Categoria';
	@override String get subcategory_of => 'Subcategoria de';
	@override String get uncategorized_parent => 'Categoria pai não definida';
	@override String get category_name_already_exists => 'Já existe uma categoria com este nome';
}

// Path: transactions
class _TranslationsTransactionsPt extends TranslationsTransactionsEn {
	_TranslationsTransactionsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get new_transaction => 'Nova Transação';
	@override String get edit_transaction => 'Editar Transação';
	@override late final _TranslationsTransactionsTypesPt types = _TranslationsTransactionsTypesPt._(_root);
	@override late final _TranslationsTransactionsStatusPt status = _TranslationsTransactionsStatusPt._(_root);
	@override late final _TranslationsTransactionsCurrencyPt currency = _TranslationsTransactionsCurrencyPt._(_root);
}

// Path: settings
class _TranslationsSettingsPt extends TranslationsSettingsEn {
	_TranslationsSettingsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get additional_settings => 'Configurações Adicionais';
}

// Path: messages
class _TranslationsMessagesPt extends TranslationsMessagesEn {
	_TranslationsMessagesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMessagesSuccessPt success = _TranslationsMessagesSuccessPt._(_root);
	@override late final _TranslationsMessagesErrorsPt errors = _TranslationsMessagesErrorsPt._(_root);
}

// Path: common.actions
class _TranslationsCommonActionsPt extends TranslationsCommonActionsEn {
	_TranslationsCommonActionsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get edit => 'Editar';
	@override String get delete => 'Excluir';
	@override String get save => 'Salvar';
	@override String get register => 'Registrar';
	@override String get pay => 'Pagar';
	@override String get unpay => 'Cancelar Pagamento';
	@override String get clone => 'Clonar';
	@override String get freeze => 'Congelar';
	@override String get unfreeze => 'Descongelar';
	@override String get export => 'Exportar';
	@override String get import => 'Importar';
	@override String get choose_file => 'Escolher Arquivo';
	@override String get download_example => 'Baixar Exemplo';
}

// Path: common.labels
class _TranslationsCommonLabelsPt extends TranslationsCommonLabelsEn {
	_TranslationsCommonLabelsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nome';
	@override String get type => 'Tipo';
	@override String get amount => 'Valor';
	@override String get date => 'Data';
	@override String get description => 'Descrição';
	@override String get account => 'Conta';
	@override String get category => 'Category';
	@override String get balance => 'Saldo';
	@override String get available_balance => 'Saldo disponível';
	@override String get initial_balance_date => 'Data do saldo inicial';
	@override String get icon => 'Ícone';
	@override String get coin => 'Moeda';
	@override String get recurrence => 'Recorrência';
	@override String get frequency => 'Frequência';
}

// Path: accounts.types
class _TranslationsAccountsTypesPt extends TranslationsAccountsTypesEn {
	_TranslationsAccountsTypesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get checking_account => 'Conta Corrente';
	@override String get credit_card => 'Cartão de Crédito';
	@override String get money => 'Dinheiro';
	@override String get others => 'Outros';
}

// Path: transactions.types
class _TranslationsTransactionsTypesPt extends TranslationsTransactionsTypesEn {
	_TranslationsTransactionsTypesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get income => 'Receita';
	@override String get expense => 'Despesa';
}

// Path: transactions.status
class _TranslationsTransactionsStatusPt extends TranslationsTransactionsStatusEn {
	_TranslationsTransactionsStatusPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get to_pay => 'A Pagar';
	@override String get paid => 'Pago';
}

// Path: transactions.currency
class _TranslationsTransactionsCurrencyPt extends TranslationsTransactionsCurrencyEn {
	_TranslationsTransactionsCurrencyPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTransactionsCurrencyTypesPt types = _TranslationsTransactionsCurrencyTypesPt._(_root);
}

// Path: messages.success
class _TranslationsMessagesSuccessPt extends TranslationsMessagesSuccessEn {
	_TranslationsMessagesSuccessPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get export_successfully => 'Exportado com sucesso!';
	@override String get excel_import_successfully => 'Arquivo Excel importado com sucesso';
}

// Path: messages.errors
class _TranslationsMessagesErrorsPt extends TranslationsMessagesErrorsEn {
	_TranslationsMessagesErrorsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get export_error => 'Erro ao exportar';
	@override String get excel_not_found => 'Arquivo Excel não encontrado';
	@override String get excel_not_valid => 'Arquivo Excel inválido';
}

// Path: transactions.currency.types
class _TranslationsTransactionsCurrencyTypesPt extends TranslationsTransactionsCurrencyTypesEn {
	_TranslationsTransactionsCurrencyTypesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get brl => 'Real';
	@override String get usd => 'Dólar';
	@override String get eur => 'Euro';
}
