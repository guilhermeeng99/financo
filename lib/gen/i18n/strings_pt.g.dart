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
	@override late final _TranslationsCommonFrequencyPt frequency = _TranslationsCommonFrequencyPt._(_root);
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
	@override String get show_only_active => 'Mostrar Apenas Contas Ativas';
	@override late final _TranslationsAccountsTypesPt types = _TranslationsAccountsTypesPt._(_root);
	@override late final _TranslationsAccountsValidationPt validation = _TranslationsAccountsValidationPt._(_root);
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
	@override String get show_only_active => 'Mostrar Apenas Categorias Ativas';
	@override String get export_categories => 'Exportar Categorias';
	@override String get import_categories => 'Importar Categorias';
	@override String get select_category => 'Selecionar Categoria';
	@override String get subcategory_of => 'Subcategoria de';
	@override String get uncategorized_parent => 'Categoria Pai Não Definida';
	@override String get category_name_already_exists => 'Já existe uma categoria com este nome';
	@override late final _TranslationsCategoriesValidationPt validation = _TranslationsCategoriesValidationPt._(_root);
}

// Path: transactions
class _TranslationsTransactionsPt extends TranslationsTransactionsEn {
	_TranslationsTransactionsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get new_transaction => 'Nova Transação';
	@override String get edit_transaction => 'Editar Transação';
	@override String get export_transactions => 'Exportar Transações';
	@override String get import_transactions => 'Importar Transações';
	@override late final _TranslationsTransactionsTypesPt types = _TranslationsTransactionsTypesPt._(_root);
	@override late final _TranslationsTransactionsRecurrenceTypePt recurrence_type = _TranslationsTransactionsRecurrenceTypePt._(_root);
	@override late final _TranslationsTransactionsStatusPt status = _TranslationsTransactionsStatusPt._(_root);
	@override late final _TranslationsTransactionsCurrencyPt currency = _TranslationsTransactionsCurrencyPt._(_root);
	@override late final _TranslationsTransactionsValidationPt validation = _TranslationsTransactionsValidationPt._(_root);
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
	@override late final _TranslationsMessagesWarningsPt warnings = _TranslationsMessagesWarningsPt._(_root);
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
	@override String get register => 'Cadastrar';
	@override String get filter => 'Filtrar';
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
	@override String get category => 'Categoria';
	@override String get balance => 'Saldo';
	@override String get available_balance => 'Saldo Disponível';
	@override String get initial_balance_date => 'Data do Saldo Inicial';
	@override String get total => 'Total';
	@override String get icon => 'Ícone';
	@override String get coin => 'Moeda';
	@override String get recurrence => 'Recorrência';
	@override String get frequency => 'Frequência';
}

// Path: common.frequency
class _TranslationsCommonFrequencyPt extends TranslationsCommonFrequencyEn {
	_TranslationsCommonFrequencyPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get daily => 'Diária';
	@override String get weekly => 'Semanal';
	@override String get monthly => 'Mensal';
	@override String get yearly => 'Anual';
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

// Path: accounts.validation
class _TranslationsAccountsValidationPt extends TranslationsAccountsValidationEn {
	_TranslationsAccountsValidationPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name_cannot_be_empty => 'O nome da conta não pode estar vazio';
	@override String name_min_length_number({required Object number}) => 'O nome da conta deve ter pelo menos ${number} caracteres';
	@override String name_max_length_number({required Object number}) => 'O nome da conta deve ter no máximo ${number} caracteres';
	@override String currency_code_length_number({required Object number}) => 'O código da moeda deve ter exatamente ${number} caracteres';
	@override String get currency_code_format => 'O código da moeda deve conter apenas letras maiúsculas';
	@override String get balance_invalid_number => 'O saldo deve ser um número válido';
	@override String balance_min_value_number({required Object number}) => 'O saldo não pode ser menor que ${number}';
	@override String balance_max_value_number({required Object number}) => 'O saldo não pode ser maior que ${number}';
}

// Path: categories.validation
class _TranslationsCategoriesValidationPt extends TranslationsCategoriesValidationEn {
	_TranslationsCategoriesValidationPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name_cannot_be_empty => 'Category name cannot be empty';
	@override String name_min_length_number({required Object number}) => 'Category name must be at least ${number} characters long';
	@override String name_max_length_number({required Object number}) => 'Category name must be at most ${number} characters long';
	@override String get parent_id_must_be_positive => 'Parent category ID must be a positive number';
}

// Path: transactions.types
class _TranslationsTransactionsTypesPt extends TranslationsTransactionsTypesEn {
	_TranslationsTransactionsTypesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get income => 'Receita';
	@override String get expense => 'Despesa';
}

// Path: transactions.recurrence_type
class _TranslationsTransactionsRecurrenceTypePt extends TranslationsTransactionsRecurrenceTypeEn {
	_TranslationsTransactionsRecurrenceTypePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get unique => 'Única';
	@override String get fixed => 'Fixa';
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

// Path: transactions.validation
class _TranslationsTransactionsValidationPt extends TranslationsTransactionsValidationEn {
	_TranslationsTransactionsValidationPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get amount_invalid_number => 'O valor da transação deve ser um número válido';
	@override String get amount_cannot_be_zero => 'O valor da transação deve ser diferente de zero';
	@override String description_max_length_number({required Object number}) => 'A descrição da transação deve ter no máximo ${number} caracteres';
	@override String get account_must_be_selected => 'Uma conta deve ser selecionada';
	@override String get account_id_must_be_positive => 'O ID da conta deve ser um número positivo';
	@override String get category_must_be_selected => 'Uma categoria deve ser selecionada';
	@override String get category_id_must_be_positive => 'O ID da categoria deve ser um número positivo';
	@override String get date_too_far_past => 'A data da transação não pode ser mais de 100 anos no passado';
	@override String get date_too_far_future => 'A data da transação não pode ser mais de 10 anos no futuro';
}

// Path: messages.success
class _TranslationsMessagesSuccessPt extends TranslationsMessagesSuccessEn {
	_TranslationsMessagesSuccessPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get export_successfully => 'Exportado com sucesso!';
	@override String get excel_import_successfully => 'Arquivo Excel importado com sucesso';
}

// Path: messages.warnings
class _TranslationsMessagesWarningsPt extends TranslationsMessagesWarningsEn {
	_TranslationsMessagesWarningsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get no_changes_provided => 'No changes were provided';
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
