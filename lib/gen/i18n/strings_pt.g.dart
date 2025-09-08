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
class TranslationsPt implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

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
class _TranslationsNavigationPt implements TranslationsNavigationEn {
	_TranslationsNavigationPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get overview => 'Visão Geral';
	@override String get releases => 'Lançamentos';
	@override String get categories => 'Categorias';
	@override String get accounts => 'Contas';
}

// Path: common
class _TranslationsCommonPt implements TranslationsCommonEn {
	_TranslationsCommonPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCommonActionsPt actions = _TranslationsCommonActionsPt._(_root);
	@override late final _TranslationsCommonLabelsPt labels = _TranslationsCommonLabelsPt._(_root);
	@override late final _TranslationsCommonFrequencyPt frequency = _TranslationsCommonFrequencyPt._(_root);
}

// Path: accounts
class _TranslationsAccountsPt implements TranslationsAccountsEn {
	_TranslationsAccountsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get new_account => 'Nova Conta';
	@override String get edit_account => 'Editar Conta';
	@override String get select_account => 'Selecionar Conta';
	@override String get show_only_active => 'Mostrar Apenas Contas Ativas';
	@override late final _TranslationsAccountsTypesPt types = _TranslationsAccountsTypesPt._(_root);
	@override late final _TranslationsAccountsValidationPt validation = _TranslationsAccountsValidationPt._(_root);
}

// Path: categories
class _TranslationsCategoriesPt implements TranslationsCategoriesEn {
	_TranslationsCategoriesPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get new_category => 'Nova Categoria';
	@override String get edit_category => 'Editar Categoria';
	@override String get create_sub_category => 'Criar Subcategoria';
	@override String get show_only_active => 'Mostrar Apenas Categorias Ativas';
	@override String get export_categories => 'Exportar Categorias';
	@override String get import_categories => 'Importar Categorias';
	@override String get select_category => 'Selecionar Categoria';
	@override String get subcategory_of => 'Subcategoria de';
	@override late final _TranslationsCategoriesValidationPt validation = _TranslationsCategoriesValidationPt._(_root);
}

// Path: transactions
class _TranslationsTransactionsPt implements TranslationsTransactionsEn {
	_TranslationsTransactionsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get new_transaction => 'Nova Transação';
	@override String get edit_transaction => 'Editar Transação';
	@override String get export_transactions => 'Exportar Transações';
	@override String get import_transactions => 'Importar Transações';
	@override late final _TranslationsTransactionsTypesPt types = _TranslationsTransactionsTypesPt._(_root);
	@override late final _TranslationsTransactionsRecurrenceTypePt recurrence_type = _TranslationsTransactionsRecurrenceTypePt._(_root);
	@override late final _TranslationsTransactionsStatusTypePt status_type = _TranslationsTransactionsStatusTypePt._(_root);
	@override late final _TranslationsTransactionsStatusPt status = _TranslationsTransactionsStatusPt._(_root);
	@override late final _TranslationsTransactionsCurrencyPt currency = _TranslationsTransactionsCurrencyPt._(_root);
	@override late final _TranslationsTransactionsValidationPt validation = _TranslationsTransactionsValidationPt._(_root);
}

// Path: settings
class _TranslationsSettingsPt implements TranslationsSettingsEn {
	_TranslationsSettingsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get additional_settings => 'Configurações Adicionais';
}

// Path: messages
class _TranslationsMessagesPt implements TranslationsMessagesEn {
	_TranslationsMessagesPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMessagesSuccessPt success = _TranslationsMessagesSuccessPt._(_root);
	@override late final _TranslationsMessagesWarningsPt warnings = _TranslationsMessagesWarningsPt._(_root);
	@override late final _TranslationsMessagesErrorsPt errors = _TranslationsMessagesErrorsPt._(_root);
}

// Path: common.actions
class _TranslationsCommonActionsPt implements TranslationsCommonActionsEn {
	_TranslationsCommonActionsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get edit => 'Editar';
	@override String get delete => 'Excluir';
	@override String get save => 'Salvar';
	@override String get register => 'Registrar';
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
class _TranslationsCommonLabelsPt implements TranslationsCommonLabelsEn {
	_TranslationsCommonLabelsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nome';
	@override String get type => 'Tipo';
	@override String get amount => 'Valor';
	@override String get date => 'Data';
	@override String get description => 'Descrição';
	@override String account({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Conta',
		other: 'Contas',
	);
	@override String category({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Categoria',
		other: 'Categorias',
	);
	@override String get subcategory => 'Subcategoria';
	@override String get transactions => 'Transações';
	@override String get balance => 'Saldo';
	@override String get available_balance => 'Saldo Disponível';
	@override String get initial_balance_date => 'Data do Saldo Inicial';
	@override String get total => 'Total';
	@override String get icon => 'Ícone';
	@override String get coin => 'Moeda';
	@override String get status => 'Status';
	@override String get recurrence => 'Recorrência';
	@override String get frequency => 'Frequência';
	@override String get entries => 'Entradas';
	@override String get transfers => 'Transferências';
	@override String get exits => 'Saídas';
	@override String get confirmed => 'Confirmado';
	@override String get projected => 'Projetado';
	@override String result({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Resultado',
		other: 'Resultados',
	);
}

// Path: common.frequency
class _TranslationsCommonFrequencyPt implements TranslationsCommonFrequencyEn {
	_TranslationsCommonFrequencyPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get daily => 'Diária';
	@override String get weekly => 'Semanal';
	@override String get monthly => 'Mensal';
	@override String get yearly => 'Anual';
}

// Path: accounts.types
class _TranslationsAccountsTypesPt implements TranslationsAccountsTypesEn {
	_TranslationsAccountsTypesPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get checking_account => 'Conta Corrente';
	@override String get credit_card => 'Cartão de Crédito';
	@override String get money => 'Dinheiro';
	@override String get others => 'Outros';
}

// Path: accounts.validation
class _TranslationsAccountsValidationPt implements TranslationsAccountsValidationEn {
	_TranslationsAccountsValidationPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name_cannot_be_empty => 'O nome da conta não pode estar vazio';
	@override String name_min_length_number({required Object number}) => 'O nome da conta deve ter pelo menos ${number} caracteres';
	@override String name_max_length_number({required Object number}) => 'O nome da conta deve ter no máximo ${number} caracteres';
	@override String get name_already_exists => 'Já existe uma conta com este nome';
	@override String currency_code_length_number({required Object number}) => 'O código da moeda deve ter exatamente ${number} caracteres';
	@override String get currency_code_format => 'O código da moeda deve conter apenas letras maiúsculas';
	@override String get balance_invalid_number => 'O saldo deve ser um número válido';
	@override String balance_min_value_number({required Object number}) => 'O saldo não pode ser menor que ${number}';
	@override String balance_max_value_number({required Object number}) => 'O saldo não pode ser maior que ${number}';
}

// Path: categories.validation
class _TranslationsCategoriesValidationPt implements TranslationsCategoriesValidationEn {
	_TranslationsCategoriesValidationPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name_cannot_be_empty => 'O nome da categoria não pode estar vazio';
	@override String name_min_length_number({required Object number}) => 'O nome da categoria deve ter pelo menos ${number} caracteres';
	@override String name_max_length_number({required Object number}) => 'O nome da categoria deve ter no máximo ${number} caracteres';
	@override String get parent_id_must_be_positive => 'O ID da categoria pai deve ser um número positivo';
	@override String get uncategorized_parent => 'Categoria Pai Não Definida';
	@override String get category_name_already_exists => 'Já existe uma categoria com este nome';
}

// Path: transactions.types
class _TranslationsTransactionsTypesPt implements TranslationsTransactionsTypesEn {
	_TranslationsTransactionsTypesPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get income => 'Receita';
	@override String get expense => 'Despesa';
}

// Path: transactions.recurrence_type
class _TranslationsTransactionsRecurrenceTypePt implements TranslationsTransactionsRecurrenceTypeEn {
	_TranslationsTransactionsRecurrenceTypePt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get unique => 'Única';
	@override String get fixed => 'Fixa';
}

// Path: transactions.status_type
class _TranslationsTransactionsStatusTypePt implements TranslationsTransactionsStatusTypeEn {
	_TranslationsTransactionsStatusTypePt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get unpaid => 'Não Pago';
	@override String get paid => 'Pago';
}

// Path: transactions.status
class _TranslationsTransactionsStatusPt implements TranslationsTransactionsStatusEn {
	_TranslationsTransactionsStatusPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get to_pay => 'A Pagar';
	@override String get paid => 'Pago';
}

// Path: transactions.currency
class _TranslationsTransactionsCurrencyPt implements TranslationsTransactionsCurrencyEn {
	_TranslationsTransactionsCurrencyPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTransactionsCurrencyTypesPt types = _TranslationsTransactionsCurrencyTypesPt._(_root);
}

// Path: transactions.validation
class _TranslationsTransactionsValidationPt implements TranslationsTransactionsValidationEn {
	_TranslationsTransactionsValidationPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get amount_invalid_number => 'O valor da transação deve ser um número válido';
	@override String get amount_cannot_be_zero => 'O valor da transação deve ser diferente de zero';
	@override String description_max_length_number({required Object number}) => 'A descrição da transação deve ter no máximo ${number} caracteres';
	@override String get account_must_be_selected => 'Uma conta deve ser selecionada';
	@override String get account_id_must_be_positive => 'O ID da conta deve ser um número positivo';
	@override String get category_must_be_selected => 'Uma categoria deve ser selecionada';
	@override String get category_id_must_be_positive => 'O ID da categoria deve ser um número positivo';
	@override String date_too_far_past_number({required Object number}) => 'A data da transação não pode ser de mais de ${number} anos no passado';
	@override String date_too_far_future_number({required Object number}) => 'A data da transação não pode ser de mais de ${number} anos no futuro';
}

// Path: messages.success
class _TranslationsMessagesSuccessPt implements TranslationsMessagesSuccessEn {
	_TranslationsMessagesSuccessPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get export_successfully => 'Exportado com sucesso!';
	@override String get excel_import_successfully => 'Arquivo Excel importado com sucesso';
}

// Path: messages.warnings
class _TranslationsMessagesWarningsPt implements TranslationsMessagesWarningsEn {
	_TranslationsMessagesWarningsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get no_changes_provided => 'Nenhuma alteração foi fornecida';
}

// Path: messages.errors
class _TranslationsMessagesErrorsPt implements TranslationsMessagesErrorsEn {
	_TranslationsMessagesErrorsPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get export_error => 'Erro ao exportar';
	@override String get excel_not_found => 'Arquivo Excel não encontrado';
	@override String get excel_not_valid => 'Arquivo Excel inválido';
}

// Path: transactions.currency.types
class _TranslationsTransactionsCurrencyTypesPt implements TranslationsTransactionsCurrencyTypesEn {
	_TranslationsTransactionsCurrencyTypesPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get brl => 'Real';
	@override String get usd => 'Dólar';
	@override String get eur => 'Euro';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsPt {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'navigation.overview': return 'Visão Geral';
			case 'navigation.releases': return 'Lançamentos';
			case 'navigation.categories': return 'Categorias';
			case 'navigation.accounts': return 'Contas';
			case 'common.actions.edit': return 'Editar';
			case 'common.actions.delete': return 'Excluir';
			case 'common.actions.save': return 'Salvar';
			case 'common.actions.register': return 'Registrar';
			case 'common.actions.filter': return 'Filtrar';
			case 'common.actions.pay': return 'Pagar';
			case 'common.actions.unpay': return 'Cancelar Pagamento';
			case 'common.actions.clone': return 'Clonar';
			case 'common.actions.freeze': return 'Congelar';
			case 'common.actions.unfreeze': return 'Descongelar';
			case 'common.actions.export': return 'Exportar';
			case 'common.actions.import': return 'Importar';
			case 'common.actions.choose_file': return 'Escolher Arquivo';
			case 'common.actions.download_example': return 'Baixar Exemplo';
			case 'common.labels.name': return 'Nome';
			case 'common.labels.type': return 'Tipo';
			case 'common.labels.amount': return 'Valor';
			case 'common.labels.date': return 'Data';
			case 'common.labels.description': return 'Descrição';
			case 'common.labels.account': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Conta',
				other: 'Contas',
			);
			case 'common.labels.category': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Categoria',
				other: 'Categorias',
			);
			case 'common.labels.subcategory': return 'Subcategoria';
			case 'common.labels.transactions': return 'Transações';
			case 'common.labels.balance': return 'Saldo';
			case 'common.labels.available_balance': return 'Saldo Disponível';
			case 'common.labels.initial_balance_date': return 'Data do Saldo Inicial';
			case 'common.labels.total': return 'Total';
			case 'common.labels.icon': return 'Ícone';
			case 'common.labels.coin': return 'Moeda';
			case 'common.labels.status': return 'Status';
			case 'common.labels.recurrence': return 'Recorrência';
			case 'common.labels.frequency': return 'Frequência';
			case 'common.labels.entries': return 'Entradas';
			case 'common.labels.transfers': return 'Transferências';
			case 'common.labels.exits': return 'Saídas';
			case 'common.labels.confirmed': return 'Confirmado';
			case 'common.labels.projected': return 'Projetado';
			case 'common.labels.result': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Resultado',
				other: 'Resultados',
			);
			case 'common.frequency.daily': return 'Diária';
			case 'common.frequency.weekly': return 'Semanal';
			case 'common.frequency.monthly': return 'Mensal';
			case 'common.frequency.yearly': return 'Anual';
			case 'accounts.new_account': return 'Nova Conta';
			case 'accounts.edit_account': return 'Editar Conta';
			case 'accounts.select_account': return 'Selecionar Conta';
			case 'accounts.show_only_active': return 'Mostrar Apenas Contas Ativas';
			case 'accounts.types.checking_account': return 'Conta Corrente';
			case 'accounts.types.credit_card': return 'Cartão de Crédito';
			case 'accounts.types.money': return 'Dinheiro';
			case 'accounts.types.others': return 'Outros';
			case 'accounts.validation.name_cannot_be_empty': return 'O nome da conta não pode estar vazio';
			case 'accounts.validation.name_min_length_number': return ({required Object number}) => 'O nome da conta deve ter pelo menos ${number} caracteres';
			case 'accounts.validation.name_max_length_number': return ({required Object number}) => 'O nome da conta deve ter no máximo ${number} caracteres';
			case 'accounts.validation.name_already_exists': return 'Já existe uma conta com este nome';
			case 'accounts.validation.currency_code_length_number': return ({required Object number}) => 'O código da moeda deve ter exatamente ${number} caracteres';
			case 'accounts.validation.currency_code_format': return 'O código da moeda deve conter apenas letras maiúsculas';
			case 'accounts.validation.balance_invalid_number': return 'O saldo deve ser um número válido';
			case 'accounts.validation.balance_min_value_number': return ({required Object number}) => 'O saldo não pode ser menor que ${number}';
			case 'accounts.validation.balance_max_value_number': return ({required Object number}) => 'O saldo não pode ser maior que ${number}';
			case 'categories.new_category': return 'Nova Categoria';
			case 'categories.edit_category': return 'Editar Categoria';
			case 'categories.create_sub_category': return 'Criar Subcategoria';
			case 'categories.show_only_active': return 'Mostrar Apenas Categorias Ativas';
			case 'categories.export_categories': return 'Exportar Categorias';
			case 'categories.import_categories': return 'Importar Categorias';
			case 'categories.select_category': return 'Selecionar Categoria';
			case 'categories.subcategory_of': return 'Subcategoria de';
			case 'categories.validation.name_cannot_be_empty': return 'O nome da categoria não pode estar vazio';
			case 'categories.validation.name_min_length_number': return ({required Object number}) => 'O nome da categoria deve ter pelo menos ${number} caracteres';
			case 'categories.validation.name_max_length_number': return ({required Object number}) => 'O nome da categoria deve ter no máximo ${number} caracteres';
			case 'categories.validation.parent_id_must_be_positive': return 'O ID da categoria pai deve ser um número positivo';
			case 'categories.validation.uncategorized_parent': return 'Categoria Pai Não Definida';
			case 'categories.validation.category_name_already_exists': return 'Já existe uma categoria com este nome';
			case 'transactions.new_transaction': return 'Nova Transação';
			case 'transactions.edit_transaction': return 'Editar Transação';
			case 'transactions.export_transactions': return 'Exportar Transações';
			case 'transactions.import_transactions': return 'Importar Transações';
			case 'transactions.types.income': return 'Receita';
			case 'transactions.types.expense': return 'Despesa';
			case 'transactions.recurrence_type.unique': return 'Única';
			case 'transactions.recurrence_type.fixed': return 'Fixa';
			case 'transactions.status_type.unpaid': return 'Não Pago';
			case 'transactions.status_type.paid': return 'Pago';
			case 'transactions.status.to_pay': return 'A Pagar';
			case 'transactions.status.paid': return 'Pago';
			case 'transactions.currency.types.brl': return 'Real';
			case 'transactions.currency.types.usd': return 'Dólar';
			case 'transactions.currency.types.eur': return 'Euro';
			case 'transactions.validation.amount_invalid_number': return 'O valor da transação deve ser um número válido';
			case 'transactions.validation.amount_cannot_be_zero': return 'O valor da transação deve ser diferente de zero';
			case 'transactions.validation.description_max_length_number': return ({required Object number}) => 'A descrição da transação deve ter no máximo ${number} caracteres';
			case 'transactions.validation.account_must_be_selected': return 'Uma conta deve ser selecionada';
			case 'transactions.validation.account_id_must_be_positive': return 'O ID da conta deve ser um número positivo';
			case 'transactions.validation.category_must_be_selected': return 'Uma categoria deve ser selecionada';
			case 'transactions.validation.category_id_must_be_positive': return 'O ID da categoria deve ser um número positivo';
			case 'transactions.validation.date_too_far_past_number': return ({required Object number}) => 'A data da transação não pode ser de mais de ${number} anos no passado';
			case 'transactions.validation.date_too_far_future_number': return ({required Object number}) => 'A data da transação não pode ser de mais de ${number} anos no futuro';
			case 'settings.additional_settings': return 'Configurações Adicionais';
			case 'messages.success.export_successfully': return 'Exportado com sucesso!';
			case 'messages.success.excel_import_successfully': return 'Arquivo Excel importado com sucesso';
			case 'messages.warnings.no_changes_provided': return 'Nenhuma alteração foi fornecida';
			case 'messages.errors.export_error': return 'Erro ao exportar';
			case 'messages.errors.excel_not_found': return 'Arquivo Excel não encontrado';
			case 'messages.errors.excel_not_valid': return 'Arquivo Excel inválido';
			default: return null;
		}
	}
}

