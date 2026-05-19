///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPtBr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPtBr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ptBr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt-BR>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsPtBr _root = this; // ignore: unused_field

	@override 
	TranslationsPtBr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPtBr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsGeneralPtBr general = _TranslationsGeneralPtBr._(_root);
	@override late final _TranslationsValidatorsPtBr validators = _TranslationsValidatorsPtBr._(_root);
	@override late final _TranslationsAuthPtBr auth = _TranslationsAuthPtBr._(_root);
	@override late final _TranslationsAccessControlPtBr accessControl = _TranslationsAccessControlPtBr._(_root);
	@override late final _TranslationsMasterPanelPtBr masterPanel = _TranslationsMasterPanelPtBr._(_root);
	@override late final _TranslationsOnboardingPtBr onboarding = _TranslationsOnboardingPtBr._(_root);
	@override late final _TranslationsNavPtBr nav = _TranslationsNavPtBr._(_root);
	@override late final _TranslationsDashboardPtBr dashboard = _TranslationsDashboardPtBr._(_root);
	@override late final _TranslationsFiftyThirtyTwentyPtBr fiftyThirtyTwenty = _TranslationsFiftyThirtyTwentyPtBr._(_root);
	@override late final _TranslationsTransactionsPtBr transactions = _TranslationsTransactionsPtBr._(_root);
	@override late final _TranslationsAccountsPtBr accounts = _TranslationsAccountsPtBr._(_root);
	@override late final _TranslationsCategoriesPtBr categories = _TranslationsCategoriesPtBr._(_root);
	@override late final _TranslationsChatPtBr chat = _TranslationsChatPtBr._(_root);
	@override late final _TranslationsReportsPtBr reports = _TranslationsReportsPtBr._(_root);
	@override late final _TranslationsBillsPtBr bills = _TranslationsBillsPtBr._(_root);
	@override late final _TranslationsBudgetsPtBr budgets = _TranslationsBudgetsPtBr._(_root);
	@override late final _TranslationsProfilePtBr profile = _TranslationsProfilePtBr._(_root);
	@override late final _TranslationsStartupPtBr startup = _TranslationsStartupPtBr._(_root);
	@override late final _TranslationsInvestmentsPtBr investments = _TranslationsInvestmentsPtBr._(_root);
}

// Path: general
class _TranslationsGeneralPtBr implements TranslationsGeneralEn {
	_TranslationsGeneralPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Carregando...';
	@override String get error => 'Ocorreu um erro';
	@override String get retry => 'Tentar novamente';
	@override String get cancel => 'Cancelar';
	@override String get confirm => 'Confirmar';
	@override String get save => 'Salvar';
	@override String get delete => 'Excluir';
	@override String get edit => 'Editar';
	@override String get add => 'Adicionar';
	@override String get search => 'Buscar';
	@override String get noResults => 'Nenhum resultado encontrado';
	@override String get success => 'Sucesso';
	@override String get or => 'ou';
	@override String get ok => 'OK';
	@override String get update => 'Atualizar';
	@override String get create => 'Criar';
	@override String get yes => 'Sim';
	@override String get no => 'Não';
	@override String get all => 'Todos';
	@override String get defaultLabel => 'Padrão';
}

// Path: validators
class _TranslationsValidatorsPtBr implements TranslationsValidatorsEn {
	_TranslationsValidatorsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get required => 'Este campo é obrigatório.';
	@override String get emailRequired => 'O e-mail é obrigatório.';
	@override String get emailInvalid => 'Informe um e-mail válido.';
	@override String get passwordRequired => 'A senha é obrigatória.';
	@override String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres.';
	@override String get amountRequired => 'O valor é obrigatório.';
	@override String get amountInvalid => 'Informe um valor válido.';
	@override String get dateInFuture => 'A data não pode estar no futuro.';
	@override String get selectAccount => 'Selecione uma conta';
	@override String get selectCategory => 'Selecione uma categoria';
}

// Path: auth
class _TranslationsAuthPtBr implements TranslationsAuthEn {
	_TranslationsAuthPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get signOut => 'Sair';
	@override String get email => 'E-mail';
	@override String get emailHint => 'seu@email.com';
	@override String get continueWithGoogle => 'Continuar com o Google';
	@override String get accessByInviteOnly => 'O acesso é apenas por convite.';
}

// Path: accessControl
class _TranslationsAccessControlPtBr implements TranslationsAccessControlEn {
	_TranslationsAccessControlPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get restrictedTitle => 'Acesso restrito';
	@override String get restrictedBody => 'Peça ao Guilherme para liberar o acesso para o seu e-mail:';
	@override String get restrictedBack => 'Voltar';
}

// Path: masterPanel
class _TranslationsMasterPanelPtBr implements TranslationsMasterPanelEn {
	_TranslationsMasterPanelPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Painel master';
	@override String get tabUsers => 'Usuários';
	@override String get tabAllowlist => 'Lista de permissões';
	@override String get usersEmpty => 'Nenhum usuário cadastrado ainda.';
	@override String get allowlistEmpty => 'Nenhum e-mail autorizado ainda.';
	@override String get masterBadge => 'MASTER';
	@override String get addEmailTitle => 'Autorizar e-mail';
	@override String get addEmailNoteLabel => 'Observação (opcional)';
	@override String get addEmailNoteHint => 'ex.: nome do amigo';
	@override String get addEmailSuccess => 'E-mail autorizado.';
	@override String get removeEmailTitle => 'Remover acesso';
	@override String removeEmailBody({required Object email}) => 'Isso remove o acesso de ${email}. Os dados existentes serão mantidos.';
	@override String get removeEmailConfirm => 'Remover';
	@override String get removeEmailSuccess => 'E-mail removido da lista de permissões.';
	@override String get deleteUserTitle => 'Excluir usuário';
	@override String deleteUserBody({required Object name}) => 'Isso exclui permanentemente ${name} e todos os seus dados. Digite o e-mail para confirmar.';
	@override String get deleteUserConfirmField => 'Digite o e-mail';
	@override String get deleteUserSuccess => 'Usuário excluído.';
}

// Path: onboarding
class _TranslationsOnboardingPtBr implements TranslationsOnboardingEn {
	_TranslationsOnboardingPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Tome controle das suas finanças pessoais\ncom acompanhamento inteligente e ajuda da IA.';
	@override String get step1Title => 'Acompanhe suas finanças';
	@override String get step1Body => 'Registre receitas e despesas sem esforço. Mantenha uma visão clara de para onde seu dinheiro vai.';
	@override String get step2Title => 'Lançamentos com IA';
	@override String get step2Body => 'Basta digitar naturalmente — nossa IA extrai os dados da transação automaticamente para você.';
	@override String get step3Title => 'Relatórios reveladores';
	@override String get step3Body => 'Gráficos e resumos bonitos te ajudam a entender seus hábitos de consumo.';
	@override String get next => 'Próximo';
	@override String get skip => 'Pular';
}

// Path: nav
class _TranslationsNavPtBr implements TranslationsNavEn {
	_TranslationsNavPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get dashboard => 'Início';
	@override String get transactions => 'Transações';
	@override String get chat => 'Chat';
	@override String get reports => 'Relatórios';
	@override String get profile => 'Perfil';
	@override String get bills => 'Contas';
	@override String get budgets => 'Orçamento';
	@override String get planning => 'Planejamento';
	@override String get investments => 'Investimentos';
}

// Path: dashboard
class _TranslationsDashboardPtBr implements TranslationsDashboardEn {
	_TranslationsDashboardPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Início';
	@override String get totalBalance => 'Saldo total';
	@override String get income => 'Receitas';
	@override String get expenses => 'Despesas';
	@override String get netResult => 'Resultado';
	@override String get recentTransactions => 'Transações recentes';
	@override String get seeAll => 'Ver tudo';
	@override String get thisMonth => 'Este mês';
	@override String get noTransactionsYet => 'Nenhuma transação ainda';
	@override String get accountBalances => 'Saldos';
	@override String get monthResult => 'Resultado do mês';
	@override String get expensesByCategory => 'Despesas por categoria';
	@override String get incomeByCategory => 'Receitas por categoria';
	@override String get noAccountsYet => 'Nenhuma conta cadastrada ainda';
	@override String get creditCardBalance => 'Saldo do cartão';
	@override String get noCreditCardsYet => 'Nenhum cartão de crédito cadastrado';
	@override String get investmentBalance => 'Investimentos';
	@override String get noInvestmentsYet => 'Nenhuma conta de investimento cadastrada';
	@override String get noExpensesYet => 'Nenhuma despesa neste mês';
	@override String get noIncomeYet => 'Nenhuma receita neste mês';
	@override String get totalExpenses => 'Total de despesas';
	@override String get totalIncome => 'Total de receitas';
	@override String get transactionList => 'Lista de transações';
	@override String get subcategories => 'Subcategorias';
	@override String get noSubcategories => 'Sem subcategorias';
	@override String get total => 'Total';
	@override String get close => 'Fechar';
}

// Path: fiftyThirtyTwenty
class _TranslationsFiftyThirtyTwentyPtBr implements TranslationsFiftyThirtyTwentyEn {
	_TranslationsFiftyThirtyTwentyPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => '50/30/20';
	@override String get subtitle => 'Como está seu mês';
	@override String get needsLabel => 'Necessidades';
	@override String get wantsLabel => 'Desejos';
	@override String get savingsLabel => 'Investimento';
	@override String ofTarget({required Object actual, required Object target}) => '${actual}% de ${target}%';
	@override String baselinePill({required Object value}) => '100% = ${value}';
	@override String get noIncomeHeadline => 'Registre uma receita do mês para acompanhar a regra 50/30/20.';
	@override String get onTrackHeadline => 'Você está no caminho.';
	@override String get needsAttentionHeadline => 'Alguns ajustes ajudariam.';
	@override String get unclassifiedDominantHeadline => 'Classifique suas categorias para um diagnóstico preciso.';
	@override String tipNeedsOver({required Object value}) => 'Reduza ${value} em necessidades para ficar no alvo.';
	@override String tipWantsOver({required Object value}) => 'Você passou ${value} do orçamento de desejos este mês.';
	@override String tipSavingsShortWithAccount({required Object value}) => 'Faltam ${value} para atingir 20% de investimento.';
	@override String get tipSavingsShortNoAccount => 'Crie uma conta de investimento para começar a registrar seus aportes.';
	@override String tipUnclassified({required Object count}) => '${count} categoria(s) ainda sem classificação.';
	@override String get ctaCreateInvestment => 'Criar conta';
	@override String get ctaClassify => 'Classificar';
	@override String get unclassifiedLabel => 'Sem classificação';
	@override String get principalDisclaimer => 'Investimento aqui = aportes do mês (transferências corrente → investimento). Rendimento de mercado não é acompanhado.';
	@override String get editTargets => 'Editar metas';
	@override String get editTargetsHint => 'Defina o percentual de cada categoria. Os três precisam somar 100%.';
	@override String get resetToClassic => 'Restaurar 50/30/20 padrão';
	@override String sumOk({required Object percent}) => 'Soma: ${percent}% ✓';
	@override String sumInvalid({required Object percent}) => 'Soma: ${percent}% — precisa ser 100%';
	@override String spentOfTarget({required Object spent, required Object target}) => '${spent} / ${target}';
	@override String get bucketEmpty => 'Sem despesas nesse grupo este mês.';
	@override String get historyTitle => 'Últimos 3 meses';
	@override String get historyEmpty => 'Ainda não há histórico para mostrar.';
	@override String get navLabel => 'Planejamento';
	@override String get subTabBudgets => 'Orçamentos';
	@override String get subTabFiftyThirtyTwenty => '50/30/20';
	@override String get subTabBills => 'Contas';
}

// Path: transactions
class _TranslationsTransactionsPtBr implements TranslationsTransactionsEn {
	_TranslationsTransactionsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transações';
	@override String get empty => 'Nenhuma transação. Adicione sua primeira para começar.';
	@override String get addTransaction => 'Nova transação';
	@override String get editTransaction => 'Editar transação';
	@override String get confirmPaymentTitle => 'Confirmar pagamento';
	@override String get confirmReceiptTitle => 'Confirmar recebimento';
	@override String get transactionDetails => 'Detalhes da transação';
	@override String get transaction => 'Transação';
	@override String get transactionNotFound => 'Transação não encontrada';
	@override String get type => 'Tipo';
	@override String get income => 'Receita';
	@override String get expense => 'Despesa';
	@override String get amount => 'Valor';
	@override String get amountLabel => 'Valor';
	@override String get amountHint => '0,00';
	@override String get description => 'Descrição';
	@override String get descriptionOptional => 'Descrição (opcional)';
	@override String get descriptionHint => 'ex.: Compras no mercado';
	@override String get date => 'Data';
	@override String get category => 'Categoria';
	@override String get account => 'Conta';
	@override String get notes => 'Observações';
	@override String get notesOptional => 'Observações (opcional)';
	@override String get notesHint => 'Detalhes adicionais...';
	@override String get transfer => 'Transferência';
	@override String get sourceAccount => 'Conta de origem';
	@override String get destinationAccount => 'Conta de destino';
	@override String get transferCreated => 'Transferência criada';
	@override String get saveAndAddAnother => 'Salvar e lançar outra';
	@override String get deleteTransaction => 'Excluir transação';
	@override String get deleteConfirm => 'Tem certeza que deseja excluir esta transação?';
	@override String get transactionUpdated => 'Transação atualizada';
	@override String get transactionCreated => 'Transação criada';
	@override String get saved => 'Transação salva!';
	@override String get deleted => 'Transação excluída.';
	@override String get importCsv => 'Importar transações';
	@override String get importCsvIntroTitle => 'Importar transações de CSV';
	@override String get importCsvIntroBody => 'Seu arquivo deve seguir o formato esperado (colunas Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência — onde Tipo é Despesa/Receita/Transferência/Pagamento). Baixe o exemplo para ver como funciona.';
	@override String get importCsvDownloadExample => 'Baixar exemplo';
	@override String get importCsvSelectFile => 'Selecionar arquivo';
	@override String get importCsvExampleDownloaded => 'Exemplo salvo.';
	@override String get importCsvExampleFailed => 'Não foi possível salvar o arquivo de exemplo.';
	@override String get importCsvErrorTitle => 'Não foi possível importar o CSV';
	@override String get importInProgressTitle => 'Importando transações...';
	@override String importProgressCounter({required Object processed, required Object total}) => '${processed} de ${total}';
	@override String importMissingFields({required Object fields}) => 'Preencha: ${fields}';
	@override String importReview({required Object count}) => 'Revisar importação: ${count} transações serão criadas.';
	@override String get importMissingCategories => 'Categorias faltando:';
	@override String get importMissingAccounts => 'Contas faltando:';
	@override String importSkippedRows({required Object count}) => '${count} linhas foram ignoradas (formato inválido).';
	@override String importSuccess({required Object imported, required Object skipped}) => 'Importadas ${imported} transações. Ignoradas ${skipped} linhas.';
	@override String get importBlocked => 'Não é possível importar: algumas categorias ou contas não foram encontradas.';
	@override String importTransfers({required Object count}) => '${count} transferências';
	@override String importExpenses({required Object count}) => '${count} despesas';
	@override String importIncomes({required Object count}) => '${count} receitas';
	@override String get importPageTitle => 'Revisar importação';
	@override String get importPageSubtitle => 'Toque numa linha para editar · lixeira para remover';
	@override String importTabExpense({required Object count}) => 'Despesa (${count})';
	@override String importTabIncome({required Object count}) => 'Receita (${count})';
	@override String importTabTransfer({required Object count}) => 'Transferência (${count})';
	@override String get importEmptyTab => 'Nada para importar nesta aba.';
	@override String get importEditTitle => 'Editar transação';
	@override String get importNothingLeft => 'Nada para importar.';
	@override String importSubmit({required Object count}) => 'Importar ${count} transações';
	@override String get importMissingAfterEditPrefix => 'Resolva as referências faltando antes de importar:';
	@override String importSkippedRowsPill({required Object count}) => '${count} linhas ignoradas';
}

// Path: accounts
class _TranslationsAccountsPtBr implements TranslationsAccountsEn {
	_TranslationsAccountsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Contas';
	@override String get addAccount => 'Nova conta';
	@override String get editAccount => 'Editar conta';
	@override String get account => 'Conta';
	@override String get accountNotFound => 'Conta não encontrada';
	@override String get checking => 'Conta corrente';
	@override String get creditCard => 'Cartão de crédito';
	@override String get investment => 'Conta investimento';
	@override String get checkingShort => 'Corrente';
	@override String get investmentShort => 'Investimento';
	@override String get investmentDescription => 'Conta dedicada a aportes. Aparece como \'investimento\' nas transferências e alimenta o cartão 50/30/20.';
	@override String get investmentYieldDisclaimer => 'O saldo reflete apenas seus aportes (principal). Rendimentos do mercado não são acompanhados.';
	@override String get name => 'Apelido da conta';
	@override String get nameHint => 'ex.: Nubank Gui';
	@override String get bank => 'Banco';
	@override String get bankHint => 'ex.: Nubank';
	@override String get bankOthers => 'Outros';
	@override String get linkedAccount => 'Conta corrente vinculada';
	@override String get balance => 'Saldo';
	@override String get currentBalance => 'Saldo atual';
	@override String get balanceLabel => 'Saldo inicial (R\$)';
	@override String get balanceHint => '0,00';
	@override String get creditLimit => 'Limite';
	@override String get creditLimitLabel => 'Limite (R\$)';
	@override String get creditLimitHint => '0,00';
	@override String get closingDay => 'Dia de fechamento';
	@override String get dueDay => 'Dia de vencimento';
	@override String get availableCredit => 'Limite disponível';
	@override String get currentBill => 'Fatura atual';
	@override String get type => 'Tipo';
	@override String get empty => 'Nenhuma conta. Adicione sua primeira conta bancária ou cartão.';
	@override String get emptySubtitle => 'Adicione suas contas bancárias e cartões de crédito.';
	@override String get accountUpdated => 'Conta atualizada';
	@override String get accountCreated => 'Conta criada';
	@override String get saved => 'Conta salva!';
	@override String get deleted => 'Conta excluída.';
	@override String get deleteConfirm => 'Tem certeza que deseja excluir esta conta?';
	@override String get statement => 'Resumo mensal';
	@override String get monthIncome => 'Receitas';
	@override String get monthExpenses => 'Despesas';
	@override String get monthResult => 'Resultado';
	@override String get noTransactionsInPeriod => 'Sem transações neste período';
	@override String get formSectionType => 'Tipo';
	@override String get formSectionDetails => 'Detalhes';
	@override String get formSectionCreditCard => 'Cartão de crédito';
	@override String get pickClosingDay => 'Dia de fechamento';
	@override String get pickDueDay => 'Dia de vencimento';
	@override String get pickLinkedAccount => 'Conta corrente vinculada';
	@override String get pickBank => 'Escolha um banco';
	@override String get bankSearchHint => 'Buscar banco';
	@override String get bankSearchNoResults => 'Nenhum banco corresponde à busca.';
	@override String get noLinkedCandidates => 'Crie uma conta corrente primeiro.';
	@override String get addFirst => 'Adicionar primeira conta';
	@override String get emptyTitle => 'Nenhuma conta ainda';
	@override String get importCsv => 'Importar contas';
	@override String get importCsvIntroTitle => 'Importar contas de CSV';
	@override String get importCsvIntroBody => 'Seu arquivo deve seguir o formato esperado (colunas Nome, Saldo inicial, Tipo, Banco, Limite, Próximo Vencimento, Fechamento — onde Tipo é Conta Corrente ou Cartão de Crédito). Baixe o exemplo para ver como funciona.';
	@override String get importCsvDownloadExample => 'Baixar exemplo';
	@override String get importCsvSelectFile => 'Selecionar arquivo';
	@override String get importCsvExampleDownloaded => 'Exemplo salvo.';
	@override String get importCsvExampleFailed => 'Não foi possível salvar o arquivo de exemplo.';
	@override String get importCsvErrorTitle => 'Não foi possível importar o CSV';
	@override String get importPageTitle => 'Revisar importação';
	@override String get importPageSubtitle => 'Toque numa linha para editar · lixeira para remover';
	@override String importTabChecking({required Object count}) => 'Corrente (${count})';
	@override String importTabCreditCard({required Object count}) => 'Cartão (${count})';
	@override String get importEmptyTab => 'Nada para importar nesta aba.';
	@override String get importDuplicatesHeader => 'Serão ignoradas (já existem)';
	@override String get importEditTitle => 'Editar conta';
	@override String get importNothingLeft => 'Nada para importar.';
	@override String importSubmit({required Object count}) => 'Importar ${count} contas';
	@override String get importMissingLinkPrefix => 'Selecione uma conta corrente vinculada para:';
	@override String importSuccessDetailed({required Object imported, required Object duplicates}) => 'Importadas ${imported} contas. Ignoradas ${duplicates} duplicadas.';
	@override String get importInProgressTitle => 'Importando contas...';
	@override String importProgressCounter({required Object processed, required Object total}) => '${processed} de ${total}';
	@override String importMissingFields({required Object fields}) => 'Preencha: ${fields}';
}

// Path: categories
class _TranslationsCategoriesPtBr implements TranslationsCategoriesEn {
	_TranslationsCategoriesPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Categorias';
	@override String get addCategory => 'Adicionar categoria';
	@override String get editCategory => 'Editar categoria';
	@override String get name => 'Nome da categoria';
	@override String get nameHint => 'ex.: Mercado';
	@override String get incomeType => 'Receita';
	@override String get expenseType => 'Despesa';
	@override String get bothType => 'Ambos';
	@override String get empty => 'Nenhuma categoria. As categorias aparecerão aqui.';
	@override String get saved => 'Categoria salva!';
	@override String get deleted => 'Categoria excluída.';
	@override String get deleteConfirm => 'Tem certeza que deseja excluir esta categoria?';
	@override String get reassignPrompt => 'Selecione uma categoria para realocar as transações:';
	@override String get categoryUpdated => 'Categoria atualizada';
	@override String get categoryCreated => 'Categoria criada';
	@override String get cannotDeleteDefault => 'Categorias padrão não podem ser excluídas.';
	@override String get cannotDeleteLast => 'Crie outra categoria antes de excluir esta.';
	@override String get selectIcon => 'Selecionar ícone';
	@override String get selectColor => 'Selecionar cor';
	@override String get chooseIcon => 'Escolha um ícone';
	@override String get iconSearchHint => 'Buscar (ex.: car, carro)';
	@override String get iconSearchNoResults => 'Nenhum ícone corresponde à busca.';
	@override String get parentCategory => 'Categoria pai';
	@override String get noParent => 'Sem categoria pai';
	@override String get subcategoryLabel => 'Subcategoria';
	@override String get subcategoryAppearanceInherited => 'Subcategorias herdam o ícone e a cor da categoria pai.';
	@override String get importCsv => 'Importar categorias';
	@override String get importCsvIntroTitle => 'Importar categorias de CSV';
	@override String get importCsvIntroBody => 'Seu arquivo deve seguir o formato esperado (colunas Categoria, Subcategoria, Tipo — onde Tipo é Receita/Despesa ou Income/Expense). Baixe o exemplo para ver como funciona.';
	@override String get importCsvDownloadExample => 'Baixar exemplo';
	@override String get importCsvSelectFile => 'Selecionar arquivo';
	@override String get importCsvExampleDownloaded => 'Exemplo salvo.';
	@override String get importCsvExampleFailed => 'Não foi possível salvar o arquivo de exemplo.';
	@override String get importCsvErrorTitle => 'Não foi possível importar o CSV';
	@override String importSuccess({required Object count}) => 'Importadas ${count} categorias.';
	@override String importReview({required Object arg}) => 'Revisar importação: ${arg} novos itens serão criados.';
	@override String importDuplicates({required Object arg}) => '${arg} itens duplicados serão ignorados.';
	@override String importSuccessDetailed({required Object imported, required Object duplicates}) => 'Importados ${imported} itens. Ignorados ${duplicates} duplicados.';
	@override String get importPageTitle => 'Revisar importação';
	@override String get importPageSubtitle => 'Toque num item para editar · arraste a lixeira para remover';
	@override String importTabExpense({required Object count}) => 'Despesa (${count})';
	@override String importTabIncome({required Object count}) => 'Receita (${count})';
	@override String get importEmptyTab => 'Nada para importar nesta aba.';
	@override String get importDuplicatesHeader => 'Serão ignorados (já existem)';
	@override String get importEditTitle => 'Editar categoria';
	@override String importDeleteRoot({required Object name, required Object count}) => 'Remover ${name} e suas ${count} subcategorias?';
	@override String get importDeleteRootConfirm => 'Remover';
	@override String get importNothingLeft => 'Nada para importar.';
	@override String importSubmit({required Object count}) => 'Importar ${count} itens';
	@override String get importInProgressTitle => 'Importando categorias...';
	@override String importProgressCounter({required Object processed, required Object total}) => '${processed} de ${total}';
	@override String get formSectionType => 'Tipo';
	@override String get formSectionDetails => 'Detalhes';
	@override String get formSectionAppearance => 'Aparência';
	@override String get formSectionBucket => 'Regra 50/30/20';
	@override String get bucketHint => 'Em qual grupo essa categoria entra?';
	@override String get incomeCountsTitle => 'Considerar na regra 50/30/20';
	@override String get incomeCountsHint => 'Quando ativo, as receitas desta categoria entram no cálculo da renda mensal (100%). Desative para receitas eventuais (reembolso, presente, venda) que não devem distorcer o cálculo.';
	@override String get bucketNeeds => 'Necessidade';
	@override String get bucketWants => 'Desejo';
	@override String get bucketUnclassified => 'Sem classificação';
	@override String get bucketHelp => 'Necessidades cobrem o essencial (aluguel, mercado, transporte). Desejos cobrem o discricionário (lazer, restaurantes). Investimento é tratado pelas transferências para contas de investimento.';
	@override String get pickParent => 'Categoria pai';
	@override String get searchHint => 'Buscar categorias';
	@override String get searchNoResults => 'Nenhuma categoria corresponde à busca.';
	@override String get noParentChosen => 'Nenhuma';
	@override String get addFirst => 'Adicionar primeira categoria';
	@override String get emptyTitle => 'Nenhuma categoria ainda';
}

// Path: chat
class _TranslationsChatPtBr implements TranslationsChatEn {
	_TranslationsChatPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Assistente IA';
	@override String get placeholder => 'Digite uma mensagem...';
	@override String get welcomeTitle => 'Olá! Sou seu assistente financeiro.';
	@override String get welcomeBody => 'Me conte sobre suas transações e eu te ajudo a registrá-las.';
	@override String get confirmPrompt => 'Detectei a seguinte transação. Está correta?';
	@override String get confirmed => 'Transação salva!';
	@override String get cancelled => 'Transação cancelada.';
	@override String get error => 'Desculpe, não consegui entender. Pode tentar de novo?';
	@override String get aiName => 'Finanço IA';
	@override String get online => 'Online';
	@override String get today => 'Hoje';
	@override String get yesterday => 'Ontem';
	@override String get tryAsking => 'Experimente perguntar';
	@override String get suggestion1 => 'Gastei R\$ 30 na padaria';
	@override String get suggestion2 => 'Quanto tenho na conta Nubank?';
	@override String get suggestion3 => 'Mostrar minhas contas atrasadas';
	@override String get suggestion4 => 'Criar uma categoria chamada Lazer';
	@override late final _TranslationsChatActionPtBr action = _TranslationsChatActionPtBr._(_root);
	@override late final _TranslationsChatAudioPtBr audio = _TranslationsChatAudioPtBr._(_root);
	@override late final _TranslationsChatImagePtBr image = _TranslationsChatImagePtBr._(_root);
	@override late final _TranslationsChatHandlersPtBr handlers = _TranslationsChatHandlersPtBr._(_root);
}

// Path: reports
class _TranslationsReportsPtBr implements TranslationsReportsEn {
	_TranslationsReportsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Relatórios';
	@override String get incomeVsExpenses => 'Receitas vs Despesas';
	@override String get expensesByCategory => 'Despesas por categoria';
	@override String get income => 'Receitas';
	@override String get expenses => 'Despesas';
	@override String get net => 'Líquido';
	@override String get currentMonth => 'Mês atual';
	@override String get lastMonth => 'Mês passado';
	@override String get customRange => 'Período personalizado';
	@override String get categoryBreakdown => 'Detalhamento por categoria';
	@override String get monthlyComparison => 'Comparativo mensal';
	@override String get balanceEvolution => 'Evolução do saldo';
	@override String get noData => 'Dados insuficientes para gerar relatórios.';
}

// Path: bills
class _TranslationsBillsPtBr implements TranslationsBillsEn {
	_TranslationsBillsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Contas';
	@override String get empty => 'Nenhuma conta. Adicione uma conta para receber lembretes antes do vencimento.';
	@override String get addBill => 'Nova conta';
	@override String get editBill => 'Editar conta';
	@override String get description => 'Descrição';
	@override String get descriptionHint => 'ex.: Energia';
	@override String get amount => 'Valor';
	@override String get amountLabel => 'Valor';
	@override String get dueDate => 'Vencimento';
	@override String get recurrence => 'Recorrência';
	@override String get oneShot => 'Única';
	@override String get monthly => 'Mensal';
	@override String get type => 'Tipo';
	@override String get typePayable => 'A pagar';
	@override String get typeReceivable => 'A receber';
	@override String get filterAll => 'Todas';
	@override String get category => 'Categoria';
	@override String get categoryRequired => 'Selecione uma categoria';
	@override String get notes => 'Observações (opcional)';
	@override String get notesHint => 'Detalhes adicionais...';
	@override String get markAsPaid => 'Marcar como paga';
	@override String get markAsReceived => 'Marcar como recebida';
	@override String get paid => 'Paga';
	@override String get received => 'Recebida';
	@override String get pending => 'Pendente';
	@override String get overdue => 'Atrasada';
	@override String get dueToday => 'Vence hoje';
	@override String get upcoming => 'Próximas';
	@override String get overdueGroup => 'Atrasadas';
	@override String get todayGroup => 'Hoje';
	@override String get upcomingGroup => 'Próximas';
	@override String get paidGroup => 'Quitadas';
	@override String get deleteConfirm => 'Tem certeza que deseja excluir esta conta?';
	@override String get billCreated => 'Conta criada';
	@override String get billUpdated => 'Conta atualizada';
	@override String get billDeleted => 'Conta excluída';
	@override String get billPaid => 'Conta paga — transação criada';
	@override String get billReceived => 'Pagamento recebido — transação criada';
	@override String get nextOccurrenceCreated => 'Conta do próximo mês agendada';
	@override String get alreadyPaid => 'Esta conta já está quitada';
	@override String get cannotEditPaid => 'Contas quitadas não podem ser editadas';
	@override String get payDialogTitle => 'Pagar conta';
	@override String get receiveDialogTitle => 'Registrar pagamento recebido';
	@override String get selectAccount => 'Conta';
	@override String get selectCategory => 'Categoria';
	@override String daysOverdue({required Object days}) => '${days} dias em atraso';
	@override String dueInDays({required Object days}) => 'em ${days} dias';
	@override String get dueTomorrow => 'amanhã';
	@override String get noExpenseCategory => 'Crie ao menos uma categoria de despesa primeiro.';
	@override String get noIncomeCategory => 'Crie ao menos uma categoria de receita primeiro.';
	@override String get summaryTitle => 'Este mês';
	@override String get summaryAllCaughtUp => 'Nada vencendo — você está em dia';
	@override String overdueChip({required Object count}) => '${count} em atraso';
	@override String pendingCount({required Object count}) => '${count} pendentes';
	@override String get emptyTitle => 'Nenhuma conta ainda';
	@override String get addFirst => 'Adicionar primeira conta';
	@override String get formDetails => 'Detalhes';
	@override String get formClassification => 'Classificação';
	@override String get pickCategory => 'Escolha uma categoria';
	@override late final _TranslationsBillsNotificationPtBr notification = _TranslationsBillsNotificationPtBr._(_root);
	@override late final _TranslationsBillsMatchPtBr match = _TranslationsBillsMatchPtBr._(_root);
	@override String get virtualBlocked => 'Pague a ocorrência atual primeiro';
	@override String get preview => 'Pré-visualização';
	@override String get editScopeTitle => 'Aplicar a quais ocorrências?';
	@override String get editScopeDescription => 'Esta é uma cobrança recorrente. Você pode aplicar a alteração apenas a esta ocorrência ou também às futuras (não afeta as anteriores).';
	@override String get editScopeOnlyThis => 'Apenas esta';
	@override String get editScopeAlsoSubsequents => 'Esta e as subsequentes';
	@override String get importCsv => 'Importar contas';
	@override String get importCsvIntroTitle => 'Importar contas de CSV';
	@override String get importCsvIntroBody => 'Seu arquivo deve seguir o formato esperado (colunas Tipo, Descrição, Valor, Vencimento, Status, Recorrência, Categoria, Observações — onde Tipo é A pagar/A receber, Status é Pendente/Paga e Recorrência é Mensal/Única). Baixe o exemplo para ver como funciona.';
	@override String get importCsvDownloadExample => 'Baixar exemplo';
	@override String get importCsvSelectFile => 'Selecionar arquivo';
	@override String get importCsvExampleDownloaded => 'Exemplo salvo.';
	@override String get importCsvExampleFailed => 'Não foi possível salvar o arquivo de exemplo.';
	@override String get importCsvErrorTitle => 'Não foi possível importar o CSV';
	@override String importCsvSuccess({required Object imported, required Object skipped}) => 'Importadas ${imported} contas. Ignoradas ${skipped} (categoria desconhecida).';
}

// Path: budgets
class _TranslationsBudgetsPtBr implements TranslationsBudgetsEn {
	_TranslationsBudgetsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Orçamento';
	@override String get addBudget => 'Novo orçamento';
	@override String get editBudget => 'Editar orçamento';
	@override String get category => 'Categoria';
	@override String get categoryHint => 'Escolha uma categoria';
	@override String get categoryRequired => 'Selecione uma categoria';
	@override String get amount => 'Valor mensal';
	@override String get amountHint => '0,00';
	@override String get summaryTitle => 'Resumo do mês';
	@override String get summaryCap => 'Total orçado';
	@override String get summarySpent => 'Gasto';
	@override String get summaryRemaining => 'Disponível';
	@override String spentOf({required Object spent, required Object cap}) => '${spent} de ${cap}';
	@override String percentageUsed({required Object value}) => '${value}% usado';
	@override String remainingOf({required Object value}) => 'Restam ${value}';
	@override String overBy({required Object value}) => 'Estourou em ${value}';
	@override String get statusSafe => 'Tranquilo';
	@override String get statusWarning => 'Atenção';
	@override String get statusExceeded => 'Estourou';
	@override String get deleteConfirm => 'Tem certeza que deseja excluir este orçamento?';
	@override String get budgetCreated => 'Orçamento criado';
	@override String get budgetUpdated => 'Orçamento atualizado';
	@override String get budgetDeleted => 'Orçamento excluído';
	@override String get duplicateCategory => 'Já existe um orçamento para essa categoria.';
	@override String get noExpenseCategory => 'Crie ao menos uma categoria de despesa antes.';
	@override String get allCategoriesBudgeted => 'Todas as categorias já têm orçamento.';
	@override String get emptyTitle => 'Tome controle dos seus gastos';
	@override String get emptyBody => 'Defina um teto mensal por categoria de despesa. O Finanço acompanha quanto você gastou, quanto ainda resta, e mostra de cara quando você está prestes a estourar.';
	@override String get emptyExample => 'Ex: R\$ 1.500 em Alimentação, R\$ 400 em Lazer, R\$ 200 em Transporte.';
	@override String get emptyAction => 'Criar primeiro orçamento';
	@override String get formDetails => 'Detalhes';
	@override String get formCategorySection => 'Categoria';
	@override String get importCsv => 'Importar orçamentos';
	@override String get importCsvIntroTitle => 'Importar orçamentos de CSV';
	@override String get importCsvIntroBody => 'Seu arquivo deve seguir o formato esperado (colunas Categoria, Valor). Cada linha aponta para uma categoria de despesa raiz pelo nome; categorias que não existem ou já têm orçamento são ignoradas. Baixe o exemplo para ver como funciona.';
	@override String get importCsvDownloadExample => 'Baixar exemplo';
	@override String get importCsvSelectFile => 'Selecionar arquivo';
	@override String get importCsvExampleDownloaded => 'Exemplo salvo.';
	@override String get importCsvExampleFailed => 'Não foi possível salvar o arquivo de exemplo.';
	@override String get importCsvErrorTitle => 'Não foi possível importar o CSV';
	@override String importCsvSuccess({required Object imported, required Object skipped}) => 'Importados ${imported} orçamentos. Ignorados ${skipped} (categoria desconhecida ou duplicada).';
}

// Path: profile
class _TranslationsProfilePtBr implements TranslationsProfileEn {
	_TranslationsProfilePtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Perfil';
	@override String get editProfile => 'Editar perfil';
	@override String get accounts => 'Contas';
	@override String get categories => 'Categorias';
	@override String get bills => 'Contas a pagar/receber';
	@override String get theme => 'Tema';
	@override String get themeLight => 'Claro';
	@override String get themeDark => 'Escuro';
	@override String get themeSystem => 'Sistema';
	@override String get signOutConfirm => 'Tem certeza que deseja sair?';
	@override String get clearData => 'Limpar todos os meus dados';
	@override String get clearDataDescription => 'Excluir transações, chat, categorias e contas';
	@override String get clearDataConfirm => 'Isso excluirá permanentemente todos os dados da sua conta. Continuar?';
	@override String get clearDataConfirmHeadline => 'Esta ação é permanente';
	@override String get clearDataConfirmBody => 'Todas as suas transações, contas, categorias, orçamentos, contas a pagar e histórico do chat serão apagados. Não é possível desfazer.';
	@override String get clearDataConfirmField => 'Digite seu e-mail para confirmar';
	@override String get clearDataSuccess => 'Os dados da sua conta foram limpos.';
	@override String get downloadApk => 'Baixar app Android';
	@override String get downloadApkDescription => 'Instale a versão mobile no seu dispositivo Android';
	@override String get sectionYourData => 'Seus dados';
	@override String get sectionPreferences => 'Preferências';
	@override String get sectionGetTheApp => 'Baixar o app';
	@override String get sectionAccount => 'Conta';
	@override String get sectionDangerZone => 'Zona de perigo';
	@override String get sectionMaster => 'Master';
	@override String get masterPanel => 'Painel master';
	@override String get masterPanelDescription => 'Gerencie usuários e a lista de permissões';
	@override String get appearance => 'Aparência';
	@override String get version => 'Versão';
	@override String get lightPalette => 'Paleta clara';
	@override String get darkPalette => 'Paleta escura';
	@override String get language => 'Idioma';
	@override String get languageSystem => 'Sistema';
	@override String get languageEnglish => 'English';
	@override String get languagePortuguese => 'Português';
}

// Path: startup
class _TranslationsStartupPtBr implements TranslationsStartupEn {
	_TranslationsStartupPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Suas finanças, em sintonia.';
	@override String get stepCheckingAuth => 'Verificando sua conta';
	@override String get stepSyncingData => 'Sincronizando seus dados';
	@override String get stepReady => 'Quase lá';
	@override String get errorTitle => 'Algo deu errado';
	@override String get errorRetry => 'Tentar novamente';
}

// Path: investments
class _TranslationsInvestmentsPtBr implements TranslationsInvestmentsEn {
	_TranslationsInvestmentsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Investimentos';
	@override String get heroTitle => 'PATRIMÔNIO INVESTIDO';
	@override String get heroAllocated => 'Alocado';
	@override String get heroPending => 'Pendente';
	@override String pendingBannerTitle({required Object amount}) => '${amount} não alocados';
	@override String get pendingBannerSubtitle => 'Indique onde esse dinheiro está investido.';
	@override String get sectionAllocation => 'Alocação';
	@override String get sectionClasses => 'Classes';
	@override String get sectionRebalance => 'Rebalanceamento';
	@override String get sectionAccountPending => 'Pendência por conta';
	@override String get allocationEmpty => 'Sem aportes no momento. Crie classes e registre alocações para ver a distribuição.';
	@override String classRowSubtitle({required Object actual, required Object target}) => '${actual} de ${target}';
	@override String get classRowOnTarget => 'no alvo';
	@override String classRowUnderTarget({required Object amount}) => '${amount} abaixo';
	@override String classRowOverTarget({required Object amount}) => '${amount} acima';
	@override String accountPending({required Object amount}) => '${amount} não alocados';
	@override String accountOverflow({required Object allocated, required Object balance}) => 'Alocação (${allocated}) excede o saldo (${balance}) — reconcilie';
	@override String get allocateAction => 'Alocar';
	@override String rebalanceAllocatePending({required Object amount}) => 'Alocar ${amount} pendentes';
	@override String rebalanceBuy({required Object amount, required Object className}) => 'Aportar ${amount} em ${className}';
	@override String rebalanceSell({required Object amount, required Object className}) => 'Resgatar ${amount} de ${className}';
	@override String targetsBanner({required Object percent}) => 'Os alvos somam ${percent}% — ajuste para 100%.';
	@override String orphanBanner({required Object count}) => 'Manutenção: ${count} holding(s) órfão(s) ignorados nos cálculos.';
	@override String get emptyNoAccountTitle => 'Crie uma conta de investimento';
	@override String get emptyNoAccountMessage => 'Antes de declarar onde seu dinheiro está alocado, cadastre uma conta do tipo Investimento. Ela vira o teto que as classes vão dividir.';
	@override String get emptyNoAccountExample => 'Ex.: "Carteira XP" com saldo R\$ 60.000';
	@override String get emptyNoAccountAction => 'Criar conta';
	@override String get emptyNoClassesTitle => 'Defina suas classes de investimento';
	@override String get emptyNoClassesMessage => 'Crie buckets que representem como você divide seus aportes. Cada classe carrega o alvo (%) que você quer atingir — a tela compara o real contra o alvo.';
	@override String get emptyNoClassesExample => 'Ex.: ARCA — Ações 25% · FIIs 25% · Cripto 25% · Renda Fixa 25%';
	@override String get emptyNoClassesAction => 'Criar classe';
	@override String get sectionIdentity => 'Identidade';
	@override String get sectionTarget => 'Alvo';
	@override String get classNameLabel => 'Nome';
	@override String get classNameHint => 'ex.: Real Estate';
	@override String get classIcon => 'Ícone';
	@override String get classColor => 'Cor';
	@override String get targetPercentLabel => '% alvo';
	@override String get targetHelper => 'Quanto do patrimônio você quer alocado nesta classe.';
	@override String get targetSubclassHelper => 'Quanto da classe pai esta subclasse deve representar.';
	@override String get newClassTitle => 'Nova classe';
	@override String get editClassTitle => 'Editar classe';
	@override String get newSubclassTitle => 'Nova subclasse';
	@override String get editSubclassTitle => 'Editar subclasse';
	@override String get createClass => 'Criar classe';
	@override String get createSubclass => 'Criar subclasse';
	@override String get saveClass => 'Salvar classe';
	@override String get classCreated => 'Classe criada';
	@override String get classUpdated => 'Classe atualizada';
	@override String get subclassNameHint => 'ex.: Apple';
	@override String get parentLabel => 'Classe pai';
	@override String get parentPlaceholder => 'Nenhuma — classe raiz';
	@override String get pickParentClass => 'Escolher classe pai';
	@override String get parentPickerEmpty => 'Crie uma classe raiz primeiro.';
	@override String get parentPickerNone => 'Nenhuma (classe raiz)';
	@override String subclassInheritsHint({required Object parent}) => 'Subclasse herda ícone e cor de ${parent}.';
	@override String subclassOf({required Object parent}) => 'Subclasse de ${parent}';
	@override String subclassRowSubtitle({required Object percent}) => '${percent} da classe';
	@override String get addSubclass => 'Adicionar subclasse';
	@override String get classRowNoSubclasses => 'Sem subclasses ainda — toque para criar.';
	@override String get classDetailTitle => 'Classe';
	@override String get detailSubclassesSection => 'Subclasses';
	@override String detailTargetAmount({required Object amount}) => 'Meta: ${amount}';
	@override String get detailNoSubclassesTitle => 'Crie sua primeira subclasse';
	@override String get detailNoSubclassesBody => 'Subclasses são onde o dinheiro é realmente alocado (ex.: Apple, Tesla). A classe organiza o grupo.';
	@override String subclassDetailLine({required Object amount, required Object percent}) => '${amount} · ${percent} da classe';
	@override String subclassSuggestionAdd({required Object amount}) => 'Aporte ${amount} para chegar à meta sugerida';
	@override String subclassSuggestionTrim({required Object amount}) => 'Reduza ${amount} — está acima da meta sugerida';
	@override String get subclassSuggestionBalanced => 'No alvo sugerido';
	@override String get subclassSuggestionNoTarget => 'Defina um alvo % para ver sugestão';
	@override String get deleteClassTitle => 'Excluir classe';
	@override String get deleteClassConfirm => 'Holdings vinculados precisam ser reatribuídos ou removidos antes. Deseja prosseguir?';
	@override String get deleteClassSuccess => 'Classe excluída';
	@override String get newHoldingTitle => 'Nova alocação';
	@override String get editHoldingTitle => 'Editar alocação';
	@override String get createHolding => 'Criar alocação';
	@override String get saveHolding => 'Salvar alocação';
	@override String get deleteHoldingTitle => 'Excluir alocação';
	@override String get deleteHoldingConfirm => 'Esta alocação será removida da composição. O saldo da conta não é afetado.';
	@override String get account => 'Conta';
	@override String get assetClass => 'Classe';
	@override String get amount => 'Valor';
	@override String get notes => 'Notas';
	@override String get notesHint => 'Detalhes opcionais (ex.: CDB Banco Inter, vence 2028)';
	@override String get pickAccount => 'Selecione uma conta';
	@override String get pickClass => 'Selecione uma classe';
	@override String get pickerEmpty => 'Nada para escolher ainda.';
	@override String amountHelper({required Object available}) => 'Disponível na conta: ${available}';
	@override String amountOverflow({required Object available}) => 'Acima do disponível (${available})';
	@override String get targetShort => 'alvo';
	@override String get fabAddClass => 'Nova classe';
	@override String get fabAddClassSubtitle => 'Crie uma categoria de investimento (ex.: FIIs).';
	@override String get fabAddHolding => 'Nova alocação';
	@override String get fabAddHoldingSubtitle => 'Indique onde uma parte do saldo está investida.';
	@override String get fabAddHoldingNoAccount => 'Crie uma conta de investimento primeiro.';
	@override String get fabAddHoldingNoClass => 'Crie uma classe primeiro.';
	@override String get fabAddHoldingNoSubclass => 'Crie uma subclasse antes de alocar — classes são apenas organizadoras.';
}

// Path: chat.action
class _TranslationsChatActionPtBr implements TranslationsChatActionEn {
	_TranslationsChatActionPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get transactionExpense => 'Confirmar despesa';
	@override String get transactionIncome => 'Confirmar receita';
	@override String get transfer => 'Confirmar transferência';
	@override String get fieldFromAccount => 'De';
	@override String get fieldToAccount => 'Para';
	@override String get accountCreate => 'Criar conta';
	@override String get accountDelete => 'Excluir conta';
	@override String get categoryCreate => 'Criar categoria';
	@override String get categoryDelete => 'Excluir categoria';
	@override String get billCreate => 'Agendar conta';
	@override String get billUpdate => 'Atualizar conta';
	@override String get billMarkPaid => 'Marcar como paga';
	@override String get billDelete => 'Excluir conta';
	@override String get budgetCreate => 'Criar orçamento';
	@override String get budgetUpdate => 'Atualizar orçamento';
	@override String get budgetDelete => 'Excluir orçamento';
	@override String get fieldAmount => 'Valor';
	@override String get fieldDescription => 'Descrição';
	@override String get fieldCategory => 'Categoria';
	@override String get fieldAccount => 'Conta';
	@override String get fieldDate => 'Data';
	@override String get fieldType => 'Tipo';
	@override String get fieldBank => 'Banco';
	@override String get fieldCreditLimit => 'Limite';
	@override String get fieldClosingDay => 'Dia de fechamento';
	@override String get fieldDueDay => 'Dia de vencimento';
	@override String get fieldDueDate => 'Data de vencimento';
	@override String get fieldRecurrence => 'Recorrência';
	@override String get fieldName => 'Nome';
	@override String get fieldLinkedAccount => 'Conta vinculada';
	@override String get fieldBalance => 'Saldo inicial';
	@override String get fieldNotes => 'Observações';
	@override String get confirm => 'Confirmar';
	@override String get cancel => 'Cancelar';
	@override String get statusConfirmed => 'Confirmada';
	@override String get statusCancelled => 'Cancelada';
}

// Path: chat.audio
class _TranslationsChatAudioPtBr implements TranslationsChatAudioEn {
	_TranslationsChatAudioPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get start => 'Gravar mensagem de voz';
	@override String get stop => 'Parar gravação';
	@override String get cancel => 'Cancelar';
	@override String get recording => 'Gravando';
	@override String get transcribing => 'Transcrevendo...';
	@override String get permissionDenied => 'Permissão de microfone necessária para gravar voz.';
	@override String get recordError => 'Falha ao gravar áudio';
}

// Path: chat.image
class _TranslationsChatImagePtBr implements TranslationsChatImageEn {
	_TranslationsChatImagePtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get attach => 'Anexar imagem';
	@override String get takePhoto => 'Tirar foto';
	@override String get fromGallery => 'Escolher da galeria';
	@override String get remove => 'Remover imagem';
	@override String get pickError => 'Não foi possível escolher a imagem';
	@override String get missing => 'Imagem não disponível';
}

// Path: chat.handlers
class _TranslationsChatHandlersPtBr implements TranslationsChatHandlersEn {
	_TranslationsChatHandlersPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get imageAttached => 'Imagem anexada.';
	@override String get errorQuota => 'O serviço de IA está temporariamente indisponível por limite de uso. Tente novamente em instantes.';
	@override String get errorGeneric => 'Desculpe, não consegui processar sua mensagem. Tente novamente.';
	@override String get unknownAction => 'Ação desconhecida.';
	@override String get unknownAccountAction => 'Ação de conta desconhecida.';
	@override String get unknownCategoryAction => 'Ação de categoria desconhecida.';
	@override String get unknownBillAction => 'Ação de boleto desconhecida.';
	@override String get unknownBudgetAction => 'Ação de orçamento desconhecida.';
	@override String get invalidAmount => 'Valor inválido.';
	@override String accountCreateFailed({required Object error}) => 'Falha ao criar conta: ${error}';
	@override String accountCreated({required Object name}) => 'Conta "${name}" criada com sucesso!';
	@override String accountNotFound({required Object name}) => 'Nenhuma conta chamada "${name}" encontrada.';
	@override String accountLoadFailed({required Object error}) => 'Falha ao localizar conta: ${error}';
	@override String accountDeleteFailed({required Object error}) => 'Falha ao excluir conta: ${error}';
	@override String accountDeleted({required Object name}) => 'Conta "${name}" removida com sucesso!';
	@override String categoryCreateFailed({required Object error}) => 'Falha ao criar categoria: ${error}';
	@override String categoryCreated({required Object name}) => 'Categoria "${name}" criada com sucesso!';
	@override String categoryNotFound({required Object name}) => 'Nenhuma categoria chamada "${name}" encontrada.';
	@override String categoryLoadFailed({required Object error}) => 'Falha ao localizar categoria: ${error}';
	@override String categoryDeleteFailed({required Object error}) => 'Falha ao excluir categoria: ${error}';
	@override String categoryDeleted({required Object name}) => 'Categoria "${name}" removida com sucesso!';
	@override String get categoryRequired => 'Categoria é obrigatória.';
	@override String categoryNotFoundCreateFirst({required Object name}) => 'Categoria "${name}" não existe. Se for uma transferência entre suas contas, peça "transferência" explicitamente; senão, crie a categoria primeiro.';
	@override String get transactionLoadCategoriesFailed => 'Falha ao carregar categorias.';
	@override String get transactionLoadAccountsFailed => 'Falha ao carregar contas.';
	@override String get transactionCreateAccountFirst => 'Crie uma conta primeiro.';
	@override String get transactionUnresolvedAccount => 'Não foi possível resolver a conta.';
	@override String transactionCreateFailed({required Object error}) => 'Falha ao criar transação: ${error}';
	@override String transactionCreated({required Object description, required Object amount}) => 'Transação "${description}" de ${amount} criada com sucesso!';
	@override String get transferAccountsRequired => 'Transferência precisa de origem e destino.';
	@override String get transferMinTwoAccounts => 'Transferência requer ao menos duas contas.';
	@override String get transferSourceDestSame => 'Origem e destino devem ser contas diferentes.';
	@override String get transferUnresolvedSource => 'Não foi possível resolver a conta de origem.';
	@override String get transferUnresolvedDestination => 'Não foi possível resolver a conta de destino.';
	@override String transferCreateFailed({required Object error}) => 'Falha ao criar transferência: ${error}';
	@override String transferCreated({required Object amount, required Object from, required Object to}) => 'Transferência de ${amount} de "${from}" para "${to}" criada com sucesso!';
	@override String get billDescriptionRequired => 'Descrição do boleto é obrigatória.';
	@override String get billAmountInvalid => 'Valor do boleto inválido.';
	@override String billCreateFailed({required Object error}) => 'Falha ao criar boleto: ${error}';
	@override String billCreated({required Object description, required Object amount, required Object dueDate}) => 'Boleto "${description}" de ${amount} agendado para ${dueDate}.';
	@override String get billIdRequired => 'Id do boleto é obrigatório.';
	@override String get billNotFound => 'Boleto não encontrado.';
	@override String get billCannotEditPaid => 'O boleto já foi pago e não pode ser editado.';
	@override String billUpdateFailed({required Object error}) => 'Falha ao atualizar boleto: ${error}';
	@override String billUpdated({required Object description}) => 'Boleto "${description}" atualizado.';
	@override String get billAlreadyPaid => 'O boleto já está pago.';
	@override String get billNoCheckingAccount => 'Nenhuma conta corrente disponível para registrar o pagamento.';
	@override String get billNoIncomeCategory => 'Nenhuma categoria de receita disponível para registrar o pagamento.';
	@override String get billNoExpenseCategory => 'Nenhuma categoria de despesa disponível para registrar o pagamento.';
	@override String billPayFailed({required Object error}) => 'Falha ao marcar boleto como pago: ${error}';
	@override String billPaid({required Object description}) => 'Boleto "${description}" pago — transação criada.';
	@override String billPaidWithNext({required Object description, required Object dueDate}) => 'Boleto "${description}" pago — transação criada. Próxima ocorrência agendada para ${dueDate}.';
	@override String billDeleteFailed({required Object error}) => 'Falha ao excluir boleto: ${error}';
	@override String get billDeleted => 'Boleto excluído.';
	@override String get budgetCategoryRequired => 'Categoria é obrigatória para orçamento.';
	@override String budgetCategoryNotFound({required Object name}) => 'Categoria "${name}" não encontrada.';
	@override String budgetCategoryNotFoundCreate({required Object name}) => 'Categoria "${name}" não existe. Crie-a primeiro.';
	@override String get budgetExpenseOnly => 'Orçamento só vale para categorias de despesa.';
	@override String budgetRootCategoryOnly({required Object name}) => 'Orçamento só pode ser criado em categoria-pai. Use a categoria raiz "${name}".';
	@override String budgetAlreadyExists({required Object name}) => 'Já existe um orçamento para "${name}". Use "atualizar" para mudar o valor.';
	@override String budgetDoesNotExist({required Object name}) => 'Não existe orçamento para "${name}" ainda. Use "criar" para definir um.';
	@override String get budgetAmountPositive => 'Valor do orçamento deve ser maior que zero.';
	@override String get budgetLoadFailed => 'Não foi possível carregar orçamentos.';
	@override String get budgetLoadCategoriesFailed => 'Não foi possível carregar categorias.';
	@override String budgetCreateFailed({required Object error}) => 'Falha ao criar orçamento: ${error}';
	@override String budgetCreated({required Object amount, required Object name}) => 'Orçamento de ${amount} em "${name}" criado.';
	@override String budgetNoActive({required Object name}) => 'Nenhum orçamento ativo para "${name}".';
	@override String budgetUpdateFailed({required Object error}) => 'Falha ao atualizar orçamento: ${error}';
	@override String budgetUpdated({required Object name, required Object amount}) => 'Orçamento de "${name}" atualizado para ${amount}.';
	@override String budgetDeleteFailed({required Object error}) => 'Falha ao remover orçamento: ${error}';
	@override String budgetDeleted({required Object name}) => 'Orçamento de "${name}" removido.';
	@override String get resolveAccountMissing => 'Qual conta devo usar? Me diga o nome da conta.';
	@override String resolveAccountNotFound({required Object query}) => 'Conta "${query}" não encontrada. Crie-a primeiro ou use o nome exato.';
	@override String resolveAccountMultiple({required Object query, required Object names}) => 'Várias contas correspondem a "${query}": ${names}. Seja mais específico.';
}

// Path: bills.notification
class _TranslationsBillsNotificationPtBr implements TranslationsBillsNotificationEn {
	_TranslationsBillsNotificationPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String title({required Object count}) => 'Você tem ${count} conta(s) para pagar';
	@override String bodyDueToday({required Object description, required Object amount}) => '${description} (${amount}) vence hoje';
	@override String bodyOverdue({required Object description, required Object amount}) => '${description} (${amount}) está atrasada';
}

// Path: bills.match
class _TranslationsBillsMatchPtBr implements TranslationsBillsMatchEn {
	_TranslationsBillsMatchPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String bannerTitle({required Object count}) => '${count} possível(is) pagamento(s) detectado(s)';
	@override String get bannerSubtitle => 'Toque para confirmar se alguma transação existente quita uma conta pendente';
	@override String get sheetTitle => 'Confirmar pagamentos';
	@override String get sheetIntro => 'Encontramos transações que podem estar pagando suas contas pendentes. Confirme uma a uma.';
	@override String get candidateQuestion => 'Esta transação foi esta conta?';
	@override String get yesItWas => 'Sim';
	@override String get notThisOne => 'Não';
	@override String get matchAccepted => 'Conta marcada como quitada';
	@override String get matchRejected => 'Entendido — não vamos sugerir esta de novo';
	@override String get billLabel => 'Conta';
	@override String get transactionLabel => 'Transação';
	@override String get fieldDescription => 'Descrição';
	@override String get fieldCategory => 'Categoria';
	@override String get fieldAmount => 'Valor';
	@override String get fieldDate => 'Data';
	@override String get fieldEmpty => '—';
}

/// The flat map containing all translations for locale <pt-BR>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPtBr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'general.loading' => 'Carregando...',
			'general.error' => 'Ocorreu um erro',
			'general.retry' => 'Tentar novamente',
			'general.cancel' => 'Cancelar',
			'general.confirm' => 'Confirmar',
			'general.save' => 'Salvar',
			'general.delete' => 'Excluir',
			'general.edit' => 'Editar',
			'general.add' => 'Adicionar',
			'general.search' => 'Buscar',
			'general.noResults' => 'Nenhum resultado encontrado',
			'general.success' => 'Sucesso',
			'general.or' => 'ou',
			'general.ok' => 'OK',
			'general.update' => 'Atualizar',
			'general.create' => 'Criar',
			'general.yes' => 'Sim',
			'general.no' => 'Não',
			'general.all' => 'Todos',
			'general.defaultLabel' => 'Padrão',
			'validators.required' => 'Este campo é obrigatório.',
			'validators.emailRequired' => 'O e-mail é obrigatório.',
			'validators.emailInvalid' => 'Informe um e-mail válido.',
			'validators.passwordRequired' => 'A senha é obrigatória.',
			'validators.passwordMinLength' => 'A senha deve ter pelo menos 6 caracteres.',
			'validators.amountRequired' => 'O valor é obrigatório.',
			'validators.amountInvalid' => 'Informe um valor válido.',
			'validators.dateInFuture' => 'A data não pode estar no futuro.',
			'validators.selectAccount' => 'Selecione uma conta',
			'validators.selectCategory' => 'Selecione uma categoria',
			'auth.signOut' => 'Sair',
			'auth.email' => 'E-mail',
			'auth.emailHint' => 'seu@email.com',
			'auth.continueWithGoogle' => 'Continuar com o Google',
			'auth.accessByInviteOnly' => 'O acesso é apenas por convite.',
			'accessControl.restrictedTitle' => 'Acesso restrito',
			'accessControl.restrictedBody' => 'Peça ao Guilherme para liberar o acesso para o seu e-mail:',
			'accessControl.restrictedBack' => 'Voltar',
			'masterPanel.title' => 'Painel master',
			'masterPanel.tabUsers' => 'Usuários',
			'masterPanel.tabAllowlist' => 'Lista de permissões',
			'masterPanel.usersEmpty' => 'Nenhum usuário cadastrado ainda.',
			'masterPanel.allowlistEmpty' => 'Nenhum e-mail autorizado ainda.',
			'masterPanel.masterBadge' => 'MASTER',
			'masterPanel.addEmailTitle' => 'Autorizar e-mail',
			'masterPanel.addEmailNoteLabel' => 'Observação (opcional)',
			'masterPanel.addEmailNoteHint' => 'ex.: nome do amigo',
			'masterPanel.addEmailSuccess' => 'E-mail autorizado.',
			'masterPanel.removeEmailTitle' => 'Remover acesso',
			'masterPanel.removeEmailBody' => ({required Object email}) => 'Isso remove o acesso de ${email}. Os dados existentes serão mantidos.',
			'masterPanel.removeEmailConfirm' => 'Remover',
			'masterPanel.removeEmailSuccess' => 'E-mail removido da lista de permissões.',
			'masterPanel.deleteUserTitle' => 'Excluir usuário',
			'masterPanel.deleteUserBody' => ({required Object name}) => 'Isso exclui permanentemente ${name} e todos os seus dados. Digite o e-mail para confirmar.',
			'masterPanel.deleteUserConfirmField' => 'Digite o e-mail',
			'masterPanel.deleteUserSuccess' => 'Usuário excluído.',
			'onboarding.tagline' => 'Tome controle das suas finanças pessoais\ncom acompanhamento inteligente e ajuda da IA.',
			'onboarding.step1Title' => 'Acompanhe suas finanças',
			'onboarding.step1Body' => 'Registre receitas e despesas sem esforço. Mantenha uma visão clara de para onde seu dinheiro vai.',
			'onboarding.step2Title' => 'Lançamentos com IA',
			'onboarding.step2Body' => 'Basta digitar naturalmente — nossa IA extrai os dados da transação automaticamente para você.',
			'onboarding.step3Title' => 'Relatórios reveladores',
			'onboarding.step3Body' => 'Gráficos e resumos bonitos te ajudam a entender seus hábitos de consumo.',
			'onboarding.next' => 'Próximo',
			'onboarding.skip' => 'Pular',
			'nav.dashboard' => 'Início',
			'nav.transactions' => 'Transações',
			'nav.chat' => 'Chat',
			'nav.reports' => 'Relatórios',
			'nav.profile' => 'Perfil',
			'nav.bills' => 'Contas',
			'nav.budgets' => 'Orçamento',
			'nav.planning' => 'Planejamento',
			'nav.investments' => 'Investimentos',
			'dashboard.title' => 'Início',
			'dashboard.totalBalance' => 'Saldo total',
			'dashboard.income' => 'Receitas',
			'dashboard.expenses' => 'Despesas',
			'dashboard.netResult' => 'Resultado',
			'dashboard.recentTransactions' => 'Transações recentes',
			'dashboard.seeAll' => 'Ver tudo',
			'dashboard.thisMonth' => 'Este mês',
			'dashboard.noTransactionsYet' => 'Nenhuma transação ainda',
			'dashboard.accountBalances' => 'Saldos',
			'dashboard.monthResult' => 'Resultado do mês',
			'dashboard.expensesByCategory' => 'Despesas por categoria',
			'dashboard.incomeByCategory' => 'Receitas por categoria',
			'dashboard.noAccountsYet' => 'Nenhuma conta cadastrada ainda',
			'dashboard.creditCardBalance' => 'Saldo do cartão',
			'dashboard.noCreditCardsYet' => 'Nenhum cartão de crédito cadastrado',
			'dashboard.investmentBalance' => 'Investimentos',
			'dashboard.noInvestmentsYet' => 'Nenhuma conta de investimento cadastrada',
			'dashboard.noExpensesYet' => 'Nenhuma despesa neste mês',
			'dashboard.noIncomeYet' => 'Nenhuma receita neste mês',
			'dashboard.totalExpenses' => 'Total de despesas',
			'dashboard.totalIncome' => 'Total de receitas',
			'dashboard.transactionList' => 'Lista de transações',
			'dashboard.subcategories' => 'Subcategorias',
			'dashboard.noSubcategories' => 'Sem subcategorias',
			'dashboard.total' => 'Total',
			'dashboard.close' => 'Fechar',
			'fiftyThirtyTwenty.title' => '50/30/20',
			'fiftyThirtyTwenty.subtitle' => 'Como está seu mês',
			'fiftyThirtyTwenty.needsLabel' => 'Necessidades',
			'fiftyThirtyTwenty.wantsLabel' => 'Desejos',
			'fiftyThirtyTwenty.savingsLabel' => 'Investimento',
			'fiftyThirtyTwenty.ofTarget' => ({required Object actual, required Object target}) => '${actual}% de ${target}%',
			'fiftyThirtyTwenty.baselinePill' => ({required Object value}) => '100% = ${value}',
			'fiftyThirtyTwenty.noIncomeHeadline' => 'Registre uma receita do mês para acompanhar a regra 50/30/20.',
			'fiftyThirtyTwenty.onTrackHeadline' => 'Você está no caminho.',
			'fiftyThirtyTwenty.needsAttentionHeadline' => 'Alguns ajustes ajudariam.',
			'fiftyThirtyTwenty.unclassifiedDominantHeadline' => 'Classifique suas categorias para um diagnóstico preciso.',
			'fiftyThirtyTwenty.tipNeedsOver' => ({required Object value}) => 'Reduza ${value} em necessidades para ficar no alvo.',
			'fiftyThirtyTwenty.tipWantsOver' => ({required Object value}) => 'Você passou ${value} do orçamento de desejos este mês.',
			'fiftyThirtyTwenty.tipSavingsShortWithAccount' => ({required Object value}) => 'Faltam ${value} para atingir 20% de investimento.',
			'fiftyThirtyTwenty.tipSavingsShortNoAccount' => 'Crie uma conta de investimento para começar a registrar seus aportes.',
			'fiftyThirtyTwenty.tipUnclassified' => ({required Object count}) => '${count} categoria(s) ainda sem classificação.',
			'fiftyThirtyTwenty.ctaCreateInvestment' => 'Criar conta',
			'fiftyThirtyTwenty.ctaClassify' => 'Classificar',
			'fiftyThirtyTwenty.unclassifiedLabel' => 'Sem classificação',
			'fiftyThirtyTwenty.principalDisclaimer' => 'Investimento aqui = aportes do mês (transferências corrente → investimento). Rendimento de mercado não é acompanhado.',
			'fiftyThirtyTwenty.editTargets' => 'Editar metas',
			'fiftyThirtyTwenty.editTargetsHint' => 'Defina o percentual de cada categoria. Os três precisam somar 100%.',
			'fiftyThirtyTwenty.resetToClassic' => 'Restaurar 50/30/20 padrão',
			'fiftyThirtyTwenty.sumOk' => ({required Object percent}) => 'Soma: ${percent}% ✓',
			'fiftyThirtyTwenty.sumInvalid' => ({required Object percent}) => 'Soma: ${percent}% — precisa ser 100%',
			'fiftyThirtyTwenty.spentOfTarget' => ({required Object spent, required Object target}) => '${spent} / ${target}',
			'fiftyThirtyTwenty.bucketEmpty' => 'Sem despesas nesse grupo este mês.',
			'fiftyThirtyTwenty.historyTitle' => 'Últimos 3 meses',
			'fiftyThirtyTwenty.historyEmpty' => 'Ainda não há histórico para mostrar.',
			'fiftyThirtyTwenty.navLabel' => 'Planejamento',
			'fiftyThirtyTwenty.subTabBudgets' => 'Orçamentos',
			'fiftyThirtyTwenty.subTabFiftyThirtyTwenty' => '50/30/20',
			'fiftyThirtyTwenty.subTabBills' => 'Contas',
			'transactions.title' => 'Transações',
			'transactions.empty' => 'Nenhuma transação. Adicione sua primeira para começar.',
			'transactions.addTransaction' => 'Nova transação',
			'transactions.editTransaction' => 'Editar transação',
			'transactions.confirmPaymentTitle' => 'Confirmar pagamento',
			'transactions.confirmReceiptTitle' => 'Confirmar recebimento',
			'transactions.transactionDetails' => 'Detalhes da transação',
			'transactions.transaction' => 'Transação',
			'transactions.transactionNotFound' => 'Transação não encontrada',
			'transactions.type' => 'Tipo',
			'transactions.income' => 'Receita',
			'transactions.expense' => 'Despesa',
			'transactions.amount' => 'Valor',
			'transactions.amountLabel' => 'Valor',
			'transactions.amountHint' => '0,00',
			'transactions.description' => 'Descrição',
			'transactions.descriptionOptional' => 'Descrição (opcional)',
			'transactions.descriptionHint' => 'ex.: Compras no mercado',
			'transactions.date' => 'Data',
			'transactions.category' => 'Categoria',
			'transactions.account' => 'Conta',
			'transactions.notes' => 'Observações',
			'transactions.notesOptional' => 'Observações (opcional)',
			'transactions.notesHint' => 'Detalhes adicionais...',
			'transactions.transfer' => 'Transferência',
			'transactions.sourceAccount' => 'Conta de origem',
			'transactions.destinationAccount' => 'Conta de destino',
			'transactions.transferCreated' => 'Transferência criada',
			'transactions.saveAndAddAnother' => 'Salvar e lançar outra',
			'transactions.deleteTransaction' => 'Excluir transação',
			'transactions.deleteConfirm' => 'Tem certeza que deseja excluir esta transação?',
			'transactions.transactionUpdated' => 'Transação atualizada',
			'transactions.transactionCreated' => 'Transação criada',
			'transactions.saved' => 'Transação salva!',
			'transactions.deleted' => 'Transação excluída.',
			'transactions.importCsv' => 'Importar transações',
			'transactions.importCsvIntroTitle' => 'Importar transações de CSV',
			'transactions.importCsvIntroBody' => 'Seu arquivo deve seguir o formato esperado (colunas Tipo, Data, Valor, Descrição, Categoria, Conta, Conta transferência — onde Tipo é Despesa/Receita/Transferência/Pagamento). Baixe o exemplo para ver como funciona.',
			'transactions.importCsvDownloadExample' => 'Baixar exemplo',
			'transactions.importCsvSelectFile' => 'Selecionar arquivo',
			'transactions.importCsvExampleDownloaded' => 'Exemplo salvo.',
			'transactions.importCsvExampleFailed' => 'Não foi possível salvar o arquivo de exemplo.',
			'transactions.importCsvErrorTitle' => 'Não foi possível importar o CSV',
			'transactions.importInProgressTitle' => 'Importando transações...',
			'transactions.importProgressCounter' => ({required Object processed, required Object total}) => '${processed} de ${total}',
			'transactions.importMissingFields' => ({required Object fields}) => 'Preencha: ${fields}',
			'transactions.importReview' => ({required Object count}) => 'Revisar importação: ${count} transações serão criadas.',
			'transactions.importMissingCategories' => 'Categorias faltando:',
			'transactions.importMissingAccounts' => 'Contas faltando:',
			'transactions.importSkippedRows' => ({required Object count}) => '${count} linhas foram ignoradas (formato inválido).',
			'transactions.importSuccess' => ({required Object imported, required Object skipped}) => 'Importadas ${imported} transações. Ignoradas ${skipped} linhas.',
			'transactions.importBlocked' => 'Não é possível importar: algumas categorias ou contas não foram encontradas.',
			'transactions.importTransfers' => ({required Object count}) => '${count} transferências',
			'transactions.importExpenses' => ({required Object count}) => '${count} despesas',
			'transactions.importIncomes' => ({required Object count}) => '${count} receitas',
			'transactions.importPageTitle' => 'Revisar importação',
			'transactions.importPageSubtitle' => 'Toque numa linha para editar · lixeira para remover',
			'transactions.importTabExpense' => ({required Object count}) => 'Despesa (${count})',
			'transactions.importTabIncome' => ({required Object count}) => 'Receita (${count})',
			'transactions.importTabTransfer' => ({required Object count}) => 'Transferência (${count})',
			'transactions.importEmptyTab' => 'Nada para importar nesta aba.',
			'transactions.importEditTitle' => 'Editar transação',
			'transactions.importNothingLeft' => 'Nada para importar.',
			'transactions.importSubmit' => ({required Object count}) => 'Importar ${count} transações',
			'transactions.importMissingAfterEditPrefix' => 'Resolva as referências faltando antes de importar:',
			'transactions.importSkippedRowsPill' => ({required Object count}) => '${count} linhas ignoradas',
			'accounts.title' => 'Contas',
			'accounts.addAccount' => 'Nova conta',
			'accounts.editAccount' => 'Editar conta',
			'accounts.account' => 'Conta',
			'accounts.accountNotFound' => 'Conta não encontrada',
			'accounts.checking' => 'Conta corrente',
			'accounts.creditCard' => 'Cartão de crédito',
			'accounts.investment' => 'Conta investimento',
			'accounts.checkingShort' => 'Corrente',
			'accounts.investmentShort' => 'Investimento',
			'accounts.investmentDescription' => 'Conta dedicada a aportes. Aparece como \'investimento\' nas transferências e alimenta o cartão 50/30/20.',
			'accounts.investmentYieldDisclaimer' => 'O saldo reflete apenas seus aportes (principal). Rendimentos do mercado não são acompanhados.',
			'accounts.name' => 'Apelido da conta',
			'accounts.nameHint' => 'ex.: Nubank Gui',
			'accounts.bank' => 'Banco',
			'accounts.bankHint' => 'ex.: Nubank',
			'accounts.bankOthers' => 'Outros',
			'accounts.linkedAccount' => 'Conta corrente vinculada',
			'accounts.balance' => 'Saldo',
			'accounts.currentBalance' => 'Saldo atual',
			'accounts.balanceLabel' => 'Saldo inicial (R\$)',
			'accounts.balanceHint' => '0,00',
			'accounts.creditLimit' => 'Limite',
			'accounts.creditLimitLabel' => 'Limite (R\$)',
			'accounts.creditLimitHint' => '0,00',
			'accounts.closingDay' => 'Dia de fechamento',
			'accounts.dueDay' => 'Dia de vencimento',
			'accounts.availableCredit' => 'Limite disponível',
			'accounts.currentBill' => 'Fatura atual',
			'accounts.type' => 'Tipo',
			'accounts.empty' => 'Nenhuma conta. Adicione sua primeira conta bancária ou cartão.',
			'accounts.emptySubtitle' => 'Adicione suas contas bancárias e cartões de crédito.',
			'accounts.accountUpdated' => 'Conta atualizada',
			'accounts.accountCreated' => 'Conta criada',
			'accounts.saved' => 'Conta salva!',
			'accounts.deleted' => 'Conta excluída.',
			'accounts.deleteConfirm' => 'Tem certeza que deseja excluir esta conta?',
			'accounts.statement' => 'Resumo mensal',
			'accounts.monthIncome' => 'Receitas',
			'accounts.monthExpenses' => 'Despesas',
			'accounts.monthResult' => 'Resultado',
			'accounts.noTransactionsInPeriod' => 'Sem transações neste período',
			'accounts.formSectionType' => 'Tipo',
			'accounts.formSectionDetails' => 'Detalhes',
			'accounts.formSectionCreditCard' => 'Cartão de crédito',
			'accounts.pickClosingDay' => 'Dia de fechamento',
			'accounts.pickDueDay' => 'Dia de vencimento',
			'accounts.pickLinkedAccount' => 'Conta corrente vinculada',
			'accounts.pickBank' => 'Escolha um banco',
			'accounts.bankSearchHint' => 'Buscar banco',
			'accounts.bankSearchNoResults' => 'Nenhum banco corresponde à busca.',
			'accounts.noLinkedCandidates' => 'Crie uma conta corrente primeiro.',
			'accounts.addFirst' => 'Adicionar primeira conta',
			'accounts.emptyTitle' => 'Nenhuma conta ainda',
			'accounts.importCsv' => 'Importar contas',
			'accounts.importCsvIntroTitle' => 'Importar contas de CSV',
			'accounts.importCsvIntroBody' => 'Seu arquivo deve seguir o formato esperado (colunas Nome, Saldo inicial, Tipo, Banco, Limite, Próximo Vencimento, Fechamento — onde Tipo é Conta Corrente ou Cartão de Crédito). Baixe o exemplo para ver como funciona.',
			'accounts.importCsvDownloadExample' => 'Baixar exemplo',
			'accounts.importCsvSelectFile' => 'Selecionar arquivo',
			'accounts.importCsvExampleDownloaded' => 'Exemplo salvo.',
			'accounts.importCsvExampleFailed' => 'Não foi possível salvar o arquivo de exemplo.',
			'accounts.importCsvErrorTitle' => 'Não foi possível importar o CSV',
			'accounts.importPageTitle' => 'Revisar importação',
			'accounts.importPageSubtitle' => 'Toque numa linha para editar · lixeira para remover',
			'accounts.importTabChecking' => ({required Object count}) => 'Corrente (${count})',
			'accounts.importTabCreditCard' => ({required Object count}) => 'Cartão (${count})',
			'accounts.importEmptyTab' => 'Nada para importar nesta aba.',
			'accounts.importDuplicatesHeader' => 'Serão ignoradas (já existem)',
			'accounts.importEditTitle' => 'Editar conta',
			'accounts.importNothingLeft' => 'Nada para importar.',
			'accounts.importSubmit' => ({required Object count}) => 'Importar ${count} contas',
			'accounts.importMissingLinkPrefix' => 'Selecione uma conta corrente vinculada para:',
			'accounts.importSuccessDetailed' => ({required Object imported, required Object duplicates}) => 'Importadas ${imported} contas. Ignoradas ${duplicates} duplicadas.',
			'accounts.importInProgressTitle' => 'Importando contas...',
			'accounts.importProgressCounter' => ({required Object processed, required Object total}) => '${processed} de ${total}',
			'accounts.importMissingFields' => ({required Object fields}) => 'Preencha: ${fields}',
			'categories.title' => 'Categorias',
			'categories.addCategory' => 'Adicionar categoria',
			'categories.editCategory' => 'Editar categoria',
			'categories.name' => 'Nome da categoria',
			'categories.nameHint' => 'ex.: Mercado',
			'categories.incomeType' => 'Receita',
			'categories.expenseType' => 'Despesa',
			'categories.bothType' => 'Ambos',
			'categories.empty' => 'Nenhuma categoria. As categorias aparecerão aqui.',
			'categories.saved' => 'Categoria salva!',
			'categories.deleted' => 'Categoria excluída.',
			'categories.deleteConfirm' => 'Tem certeza que deseja excluir esta categoria?',
			'categories.reassignPrompt' => 'Selecione uma categoria para realocar as transações:',
			'categories.categoryUpdated' => 'Categoria atualizada',
			'categories.categoryCreated' => 'Categoria criada',
			'categories.cannotDeleteDefault' => 'Categorias padrão não podem ser excluídas.',
			'categories.cannotDeleteLast' => 'Crie outra categoria antes de excluir esta.',
			'categories.selectIcon' => 'Selecionar ícone',
			'categories.selectColor' => 'Selecionar cor',
			'categories.chooseIcon' => 'Escolha um ícone',
			'categories.iconSearchHint' => 'Buscar (ex.: car, carro)',
			'categories.iconSearchNoResults' => 'Nenhum ícone corresponde à busca.',
			'categories.parentCategory' => 'Categoria pai',
			'categories.noParent' => 'Sem categoria pai',
			'categories.subcategoryLabel' => 'Subcategoria',
			'categories.subcategoryAppearanceInherited' => 'Subcategorias herdam o ícone e a cor da categoria pai.',
			'categories.importCsv' => 'Importar categorias',
			'categories.importCsvIntroTitle' => 'Importar categorias de CSV',
			'categories.importCsvIntroBody' => 'Seu arquivo deve seguir o formato esperado (colunas Categoria, Subcategoria, Tipo — onde Tipo é Receita/Despesa ou Income/Expense). Baixe o exemplo para ver como funciona.',
			'categories.importCsvDownloadExample' => 'Baixar exemplo',
			'categories.importCsvSelectFile' => 'Selecionar arquivo',
			'categories.importCsvExampleDownloaded' => 'Exemplo salvo.',
			'categories.importCsvExampleFailed' => 'Não foi possível salvar o arquivo de exemplo.',
			'categories.importCsvErrorTitle' => 'Não foi possível importar o CSV',
			'categories.importSuccess' => ({required Object count}) => 'Importadas ${count} categorias.',
			'categories.importReview' => ({required Object arg}) => 'Revisar importação: ${arg} novos itens serão criados.',
			'categories.importDuplicates' => ({required Object arg}) => '${arg} itens duplicados serão ignorados.',
			'categories.importSuccessDetailed' => ({required Object imported, required Object duplicates}) => 'Importados ${imported} itens. Ignorados ${duplicates} duplicados.',
			'categories.importPageTitle' => 'Revisar importação',
			'categories.importPageSubtitle' => 'Toque num item para editar · arraste a lixeira para remover',
			'categories.importTabExpense' => ({required Object count}) => 'Despesa (${count})',
			'categories.importTabIncome' => ({required Object count}) => 'Receita (${count})',
			'categories.importEmptyTab' => 'Nada para importar nesta aba.',
			'categories.importDuplicatesHeader' => 'Serão ignorados (já existem)',
			'categories.importEditTitle' => 'Editar categoria',
			'categories.importDeleteRoot' => ({required Object name, required Object count}) => 'Remover ${name} e suas ${count} subcategorias?',
			'categories.importDeleteRootConfirm' => 'Remover',
			'categories.importNothingLeft' => 'Nada para importar.',
			'categories.importSubmit' => ({required Object count}) => 'Importar ${count} itens',
			'categories.importInProgressTitle' => 'Importando categorias...',
			'categories.importProgressCounter' => ({required Object processed, required Object total}) => '${processed} de ${total}',
			'categories.formSectionType' => 'Tipo',
			'categories.formSectionDetails' => 'Detalhes',
			'categories.formSectionAppearance' => 'Aparência',
			'categories.formSectionBucket' => 'Regra 50/30/20',
			'categories.bucketHint' => 'Em qual grupo essa categoria entra?',
			'categories.incomeCountsTitle' => 'Considerar na regra 50/30/20',
			'categories.incomeCountsHint' => 'Quando ativo, as receitas desta categoria entram no cálculo da renda mensal (100%). Desative para receitas eventuais (reembolso, presente, venda) que não devem distorcer o cálculo.',
			'categories.bucketNeeds' => 'Necessidade',
			'categories.bucketWants' => 'Desejo',
			'categories.bucketUnclassified' => 'Sem classificação',
			'categories.bucketHelp' => 'Necessidades cobrem o essencial (aluguel, mercado, transporte). Desejos cobrem o discricionário (lazer, restaurantes). Investimento é tratado pelas transferências para contas de investimento.',
			'categories.pickParent' => 'Categoria pai',
			'categories.searchHint' => 'Buscar categorias',
			'categories.searchNoResults' => 'Nenhuma categoria corresponde à busca.',
			'categories.noParentChosen' => 'Nenhuma',
			'categories.addFirst' => 'Adicionar primeira categoria',
			'categories.emptyTitle' => 'Nenhuma categoria ainda',
			'chat.title' => 'Assistente IA',
			'chat.placeholder' => 'Digite uma mensagem...',
			'chat.welcomeTitle' => 'Olá! Sou seu assistente financeiro.',
			'chat.welcomeBody' => 'Me conte sobre suas transações e eu te ajudo a registrá-las.',
			'chat.confirmPrompt' => 'Detectei a seguinte transação. Está correta?',
			'chat.confirmed' => 'Transação salva!',
			'chat.cancelled' => 'Transação cancelada.',
			'chat.error' => 'Desculpe, não consegui entender. Pode tentar de novo?',
			'chat.aiName' => 'Finanço IA',
			'chat.online' => 'Online',
			'chat.today' => 'Hoje',
			'chat.yesterday' => 'Ontem',
			'chat.tryAsking' => 'Experimente perguntar',
			'chat.suggestion1' => 'Gastei R\$ 30 na padaria',
			'chat.suggestion2' => 'Quanto tenho na conta Nubank?',
			'chat.suggestion3' => 'Mostrar minhas contas atrasadas',
			'chat.suggestion4' => 'Criar uma categoria chamada Lazer',
			'chat.action.transactionExpense' => 'Confirmar despesa',
			'chat.action.transactionIncome' => 'Confirmar receita',
			'chat.action.transfer' => 'Confirmar transferência',
			'chat.action.fieldFromAccount' => 'De',
			'chat.action.fieldToAccount' => 'Para',
			'chat.action.accountCreate' => 'Criar conta',
			'chat.action.accountDelete' => 'Excluir conta',
			'chat.action.categoryCreate' => 'Criar categoria',
			'chat.action.categoryDelete' => 'Excluir categoria',
			'chat.action.billCreate' => 'Agendar conta',
			'chat.action.billUpdate' => 'Atualizar conta',
			'chat.action.billMarkPaid' => 'Marcar como paga',
			'chat.action.billDelete' => 'Excluir conta',
			'chat.action.budgetCreate' => 'Criar orçamento',
			'chat.action.budgetUpdate' => 'Atualizar orçamento',
			'chat.action.budgetDelete' => 'Excluir orçamento',
			'chat.action.fieldAmount' => 'Valor',
			'chat.action.fieldDescription' => 'Descrição',
			'chat.action.fieldCategory' => 'Categoria',
			'chat.action.fieldAccount' => 'Conta',
			'chat.action.fieldDate' => 'Data',
			'chat.action.fieldType' => 'Tipo',
			'chat.action.fieldBank' => 'Banco',
			'chat.action.fieldCreditLimit' => 'Limite',
			'chat.action.fieldClosingDay' => 'Dia de fechamento',
			'chat.action.fieldDueDay' => 'Dia de vencimento',
			'chat.action.fieldDueDate' => 'Data de vencimento',
			'chat.action.fieldRecurrence' => 'Recorrência',
			'chat.action.fieldName' => 'Nome',
			'chat.action.fieldLinkedAccount' => 'Conta vinculada',
			'chat.action.fieldBalance' => 'Saldo inicial',
			'chat.action.fieldNotes' => 'Observações',
			'chat.action.confirm' => 'Confirmar',
			'chat.action.cancel' => 'Cancelar',
			'chat.action.statusConfirmed' => 'Confirmada',
			'chat.action.statusCancelled' => 'Cancelada',
			'chat.audio.start' => 'Gravar mensagem de voz',
			'chat.audio.stop' => 'Parar gravação',
			'chat.audio.cancel' => 'Cancelar',
			'chat.audio.recording' => 'Gravando',
			'chat.audio.transcribing' => 'Transcrevendo...',
			'chat.audio.permissionDenied' => 'Permissão de microfone necessária para gravar voz.',
			'chat.audio.recordError' => 'Falha ao gravar áudio',
			'chat.image.attach' => 'Anexar imagem',
			'chat.image.takePhoto' => 'Tirar foto',
			'chat.image.fromGallery' => 'Escolher da galeria',
			'chat.image.remove' => 'Remover imagem',
			'chat.image.pickError' => 'Não foi possível escolher a imagem',
			'chat.image.missing' => 'Imagem não disponível',
			'chat.handlers.imageAttached' => 'Imagem anexada.',
			'chat.handlers.errorQuota' => 'O serviço de IA está temporariamente indisponível por limite de uso. Tente novamente em instantes.',
			'chat.handlers.errorGeneric' => 'Desculpe, não consegui processar sua mensagem. Tente novamente.',
			'chat.handlers.unknownAction' => 'Ação desconhecida.',
			'chat.handlers.unknownAccountAction' => 'Ação de conta desconhecida.',
			'chat.handlers.unknownCategoryAction' => 'Ação de categoria desconhecida.',
			'chat.handlers.unknownBillAction' => 'Ação de boleto desconhecida.',
			'chat.handlers.unknownBudgetAction' => 'Ação de orçamento desconhecida.',
			'chat.handlers.invalidAmount' => 'Valor inválido.',
			'chat.handlers.accountCreateFailed' => ({required Object error}) => 'Falha ao criar conta: ${error}',
			'chat.handlers.accountCreated' => ({required Object name}) => 'Conta "${name}" criada com sucesso!',
			'chat.handlers.accountNotFound' => ({required Object name}) => 'Nenhuma conta chamada "${name}" encontrada.',
			'chat.handlers.accountLoadFailed' => ({required Object error}) => 'Falha ao localizar conta: ${error}',
			'chat.handlers.accountDeleteFailed' => ({required Object error}) => 'Falha ao excluir conta: ${error}',
			'chat.handlers.accountDeleted' => ({required Object name}) => 'Conta "${name}" removida com sucesso!',
			'chat.handlers.categoryCreateFailed' => ({required Object error}) => 'Falha ao criar categoria: ${error}',
			'chat.handlers.categoryCreated' => ({required Object name}) => 'Categoria "${name}" criada com sucesso!',
			'chat.handlers.categoryNotFound' => ({required Object name}) => 'Nenhuma categoria chamada "${name}" encontrada.',
			'chat.handlers.categoryLoadFailed' => ({required Object error}) => 'Falha ao localizar categoria: ${error}',
			'chat.handlers.categoryDeleteFailed' => ({required Object error}) => 'Falha ao excluir categoria: ${error}',
			'chat.handlers.categoryDeleted' => ({required Object name}) => 'Categoria "${name}" removida com sucesso!',
			'chat.handlers.categoryRequired' => 'Categoria é obrigatória.',
			'chat.handlers.categoryNotFoundCreateFirst' => ({required Object name}) => 'Categoria "${name}" não existe. Se for uma transferência entre suas contas, peça "transferência" explicitamente; senão, crie a categoria primeiro.',
			'chat.handlers.transactionLoadCategoriesFailed' => 'Falha ao carregar categorias.',
			'chat.handlers.transactionLoadAccountsFailed' => 'Falha ao carregar contas.',
			'chat.handlers.transactionCreateAccountFirst' => 'Crie uma conta primeiro.',
			'chat.handlers.transactionUnresolvedAccount' => 'Não foi possível resolver a conta.',
			'chat.handlers.transactionCreateFailed' => ({required Object error}) => 'Falha ao criar transação: ${error}',
			'chat.handlers.transactionCreated' => ({required Object description, required Object amount}) => 'Transação "${description}" de ${amount} criada com sucesso!',
			'chat.handlers.transferAccountsRequired' => 'Transferência precisa de origem e destino.',
			'chat.handlers.transferMinTwoAccounts' => 'Transferência requer ao menos duas contas.',
			'chat.handlers.transferSourceDestSame' => 'Origem e destino devem ser contas diferentes.',
			'chat.handlers.transferUnresolvedSource' => 'Não foi possível resolver a conta de origem.',
			'chat.handlers.transferUnresolvedDestination' => 'Não foi possível resolver a conta de destino.',
			'chat.handlers.transferCreateFailed' => ({required Object error}) => 'Falha ao criar transferência: ${error}',
			'chat.handlers.transferCreated' => ({required Object amount, required Object from, required Object to}) => 'Transferência de ${amount} de "${from}" para "${to}" criada com sucesso!',
			'chat.handlers.billDescriptionRequired' => 'Descrição do boleto é obrigatória.',
			'chat.handlers.billAmountInvalid' => 'Valor do boleto inválido.',
			'chat.handlers.billCreateFailed' => ({required Object error}) => 'Falha ao criar boleto: ${error}',
			'chat.handlers.billCreated' => ({required Object description, required Object amount, required Object dueDate}) => 'Boleto "${description}" de ${amount} agendado para ${dueDate}.',
			'chat.handlers.billIdRequired' => 'Id do boleto é obrigatório.',
			'chat.handlers.billNotFound' => 'Boleto não encontrado.',
			'chat.handlers.billCannotEditPaid' => 'O boleto já foi pago e não pode ser editado.',
			'chat.handlers.billUpdateFailed' => ({required Object error}) => 'Falha ao atualizar boleto: ${error}',
			'chat.handlers.billUpdated' => ({required Object description}) => 'Boleto "${description}" atualizado.',
			'chat.handlers.billAlreadyPaid' => 'O boleto já está pago.',
			'chat.handlers.billNoCheckingAccount' => 'Nenhuma conta corrente disponível para registrar o pagamento.',
			'chat.handlers.billNoIncomeCategory' => 'Nenhuma categoria de receita disponível para registrar o pagamento.',
			'chat.handlers.billNoExpenseCategory' => 'Nenhuma categoria de despesa disponível para registrar o pagamento.',
			'chat.handlers.billPayFailed' => ({required Object error}) => 'Falha ao marcar boleto como pago: ${error}',
			'chat.handlers.billPaid' => ({required Object description}) => 'Boleto "${description}" pago — transação criada.',
			'chat.handlers.billPaidWithNext' => ({required Object description, required Object dueDate}) => 'Boleto "${description}" pago — transação criada. Próxima ocorrência agendada para ${dueDate}.',
			'chat.handlers.billDeleteFailed' => ({required Object error}) => 'Falha ao excluir boleto: ${error}',
			'chat.handlers.billDeleted' => 'Boleto excluído.',
			'chat.handlers.budgetCategoryRequired' => 'Categoria é obrigatória para orçamento.',
			'chat.handlers.budgetCategoryNotFound' => ({required Object name}) => 'Categoria "${name}" não encontrada.',
			'chat.handlers.budgetCategoryNotFoundCreate' => ({required Object name}) => 'Categoria "${name}" não existe. Crie-a primeiro.',
			'chat.handlers.budgetExpenseOnly' => 'Orçamento só vale para categorias de despesa.',
			'chat.handlers.budgetRootCategoryOnly' => ({required Object name}) => 'Orçamento só pode ser criado em categoria-pai. Use a categoria raiz "${name}".',
			'chat.handlers.budgetAlreadyExists' => ({required Object name}) => 'Já existe um orçamento para "${name}". Use "atualizar" para mudar o valor.',
			'chat.handlers.budgetDoesNotExist' => ({required Object name}) => 'Não existe orçamento para "${name}" ainda. Use "criar" para definir um.',
			'chat.handlers.budgetAmountPositive' => 'Valor do orçamento deve ser maior que zero.',
			'chat.handlers.budgetLoadFailed' => 'Não foi possível carregar orçamentos.',
			'chat.handlers.budgetLoadCategoriesFailed' => 'Não foi possível carregar categorias.',
			'chat.handlers.budgetCreateFailed' => ({required Object error}) => 'Falha ao criar orçamento: ${error}',
			'chat.handlers.budgetCreated' => ({required Object amount, required Object name}) => 'Orçamento de ${amount} em "${name}" criado.',
			'chat.handlers.budgetNoActive' => ({required Object name}) => 'Nenhum orçamento ativo para "${name}".',
			'chat.handlers.budgetUpdateFailed' => ({required Object error}) => 'Falha ao atualizar orçamento: ${error}',
			'chat.handlers.budgetUpdated' => ({required Object name, required Object amount}) => 'Orçamento de "${name}" atualizado para ${amount}.',
			'chat.handlers.budgetDeleteFailed' => ({required Object error}) => 'Falha ao remover orçamento: ${error}',
			'chat.handlers.budgetDeleted' => ({required Object name}) => 'Orçamento de "${name}" removido.',
			'chat.handlers.resolveAccountMissing' => 'Qual conta devo usar? Me diga o nome da conta.',
			'chat.handlers.resolveAccountNotFound' => ({required Object query}) => 'Conta "${query}" não encontrada. Crie-a primeiro ou use o nome exato.',
			'chat.handlers.resolveAccountMultiple' => ({required Object query, required Object names}) => 'Várias contas correspondem a "${query}": ${names}. Seja mais específico.',
			'reports.title' => 'Relatórios',
			'reports.incomeVsExpenses' => 'Receitas vs Despesas',
			'reports.expensesByCategory' => 'Despesas por categoria',
			'reports.income' => 'Receitas',
			'reports.expenses' => 'Despesas',
			'reports.net' => 'Líquido',
			'reports.currentMonth' => 'Mês atual',
			'reports.lastMonth' => 'Mês passado',
			'reports.customRange' => 'Período personalizado',
			'reports.categoryBreakdown' => 'Detalhamento por categoria',
			'reports.monthlyComparison' => 'Comparativo mensal',
			'reports.balanceEvolution' => 'Evolução do saldo',
			'reports.noData' => 'Dados insuficientes para gerar relatórios.',
			'bills.title' => 'Contas',
			'bills.empty' => 'Nenhuma conta. Adicione uma conta para receber lembretes antes do vencimento.',
			'bills.addBill' => 'Nova conta',
			'bills.editBill' => 'Editar conta',
			'bills.description' => 'Descrição',
			'bills.descriptionHint' => 'ex.: Energia',
			'bills.amount' => 'Valor',
			'bills.amountLabel' => 'Valor',
			'bills.dueDate' => 'Vencimento',
			'bills.recurrence' => 'Recorrência',
			'bills.oneShot' => 'Única',
			'bills.monthly' => 'Mensal',
			'bills.type' => 'Tipo',
			'bills.typePayable' => 'A pagar',
			'bills.typeReceivable' => 'A receber',
			_ => null,
		} ?? switch (path) {
			'bills.filterAll' => 'Todas',
			'bills.category' => 'Categoria',
			'bills.categoryRequired' => 'Selecione uma categoria',
			'bills.notes' => 'Observações (opcional)',
			'bills.notesHint' => 'Detalhes adicionais...',
			'bills.markAsPaid' => 'Marcar como paga',
			'bills.markAsReceived' => 'Marcar como recebida',
			'bills.paid' => 'Paga',
			'bills.received' => 'Recebida',
			'bills.pending' => 'Pendente',
			'bills.overdue' => 'Atrasada',
			'bills.dueToday' => 'Vence hoje',
			'bills.upcoming' => 'Próximas',
			'bills.overdueGroup' => 'Atrasadas',
			'bills.todayGroup' => 'Hoje',
			'bills.upcomingGroup' => 'Próximas',
			'bills.paidGroup' => 'Quitadas',
			'bills.deleteConfirm' => 'Tem certeza que deseja excluir esta conta?',
			'bills.billCreated' => 'Conta criada',
			'bills.billUpdated' => 'Conta atualizada',
			'bills.billDeleted' => 'Conta excluída',
			'bills.billPaid' => 'Conta paga — transação criada',
			'bills.billReceived' => 'Pagamento recebido — transação criada',
			'bills.nextOccurrenceCreated' => 'Conta do próximo mês agendada',
			'bills.alreadyPaid' => 'Esta conta já está quitada',
			'bills.cannotEditPaid' => 'Contas quitadas não podem ser editadas',
			'bills.payDialogTitle' => 'Pagar conta',
			'bills.receiveDialogTitle' => 'Registrar pagamento recebido',
			'bills.selectAccount' => 'Conta',
			'bills.selectCategory' => 'Categoria',
			'bills.daysOverdue' => ({required Object days}) => '${days} dias em atraso',
			'bills.dueInDays' => ({required Object days}) => 'em ${days} dias',
			'bills.dueTomorrow' => 'amanhã',
			'bills.noExpenseCategory' => 'Crie ao menos uma categoria de despesa primeiro.',
			'bills.noIncomeCategory' => 'Crie ao menos uma categoria de receita primeiro.',
			'bills.summaryTitle' => 'Este mês',
			'bills.summaryAllCaughtUp' => 'Nada vencendo — você está em dia',
			'bills.overdueChip' => ({required Object count}) => '${count} em atraso',
			'bills.pendingCount' => ({required Object count}) => '${count} pendentes',
			'bills.emptyTitle' => 'Nenhuma conta ainda',
			'bills.addFirst' => 'Adicionar primeira conta',
			'bills.formDetails' => 'Detalhes',
			'bills.formClassification' => 'Classificação',
			'bills.pickCategory' => 'Escolha uma categoria',
			'bills.notification.title' => ({required Object count}) => 'Você tem ${count} conta(s) para pagar',
			'bills.notification.bodyDueToday' => ({required Object description, required Object amount}) => '${description} (${amount}) vence hoje',
			'bills.notification.bodyOverdue' => ({required Object description, required Object amount}) => '${description} (${amount}) está atrasada',
			'bills.match.bannerTitle' => ({required Object count}) => '${count} possível(is) pagamento(s) detectado(s)',
			'bills.match.bannerSubtitle' => 'Toque para confirmar se alguma transação existente quita uma conta pendente',
			'bills.match.sheetTitle' => 'Confirmar pagamentos',
			'bills.match.sheetIntro' => 'Encontramos transações que podem estar pagando suas contas pendentes. Confirme uma a uma.',
			'bills.match.candidateQuestion' => 'Esta transação foi esta conta?',
			'bills.match.yesItWas' => 'Sim',
			'bills.match.notThisOne' => 'Não',
			'bills.match.matchAccepted' => 'Conta marcada como quitada',
			'bills.match.matchRejected' => 'Entendido — não vamos sugerir esta de novo',
			'bills.match.billLabel' => 'Conta',
			'bills.match.transactionLabel' => 'Transação',
			'bills.match.fieldDescription' => 'Descrição',
			'bills.match.fieldCategory' => 'Categoria',
			'bills.match.fieldAmount' => 'Valor',
			'bills.match.fieldDate' => 'Data',
			'bills.match.fieldEmpty' => '—',
			'bills.virtualBlocked' => 'Pague a ocorrência atual primeiro',
			'bills.preview' => 'Pré-visualização',
			'bills.editScopeTitle' => 'Aplicar a quais ocorrências?',
			'bills.editScopeDescription' => 'Esta é uma cobrança recorrente. Você pode aplicar a alteração apenas a esta ocorrência ou também às futuras (não afeta as anteriores).',
			'bills.editScopeOnlyThis' => 'Apenas esta',
			'bills.editScopeAlsoSubsequents' => 'Esta e as subsequentes',
			'bills.importCsv' => 'Importar contas',
			'bills.importCsvIntroTitle' => 'Importar contas de CSV',
			'bills.importCsvIntroBody' => 'Seu arquivo deve seguir o formato esperado (colunas Tipo, Descrição, Valor, Vencimento, Status, Recorrência, Categoria, Observações — onde Tipo é A pagar/A receber, Status é Pendente/Paga e Recorrência é Mensal/Única). Baixe o exemplo para ver como funciona.',
			'bills.importCsvDownloadExample' => 'Baixar exemplo',
			'bills.importCsvSelectFile' => 'Selecionar arquivo',
			'bills.importCsvExampleDownloaded' => 'Exemplo salvo.',
			'bills.importCsvExampleFailed' => 'Não foi possível salvar o arquivo de exemplo.',
			'bills.importCsvErrorTitle' => 'Não foi possível importar o CSV',
			'bills.importCsvSuccess' => ({required Object imported, required Object skipped}) => 'Importadas ${imported} contas. Ignoradas ${skipped} (categoria desconhecida).',
			'budgets.title' => 'Orçamento',
			'budgets.addBudget' => 'Novo orçamento',
			'budgets.editBudget' => 'Editar orçamento',
			'budgets.category' => 'Categoria',
			'budgets.categoryHint' => 'Escolha uma categoria',
			'budgets.categoryRequired' => 'Selecione uma categoria',
			'budgets.amount' => 'Valor mensal',
			'budgets.amountHint' => '0,00',
			'budgets.summaryTitle' => 'Resumo do mês',
			'budgets.summaryCap' => 'Total orçado',
			'budgets.summarySpent' => 'Gasto',
			'budgets.summaryRemaining' => 'Disponível',
			'budgets.spentOf' => ({required Object spent, required Object cap}) => '${spent} de ${cap}',
			'budgets.percentageUsed' => ({required Object value}) => '${value}% usado',
			'budgets.remainingOf' => ({required Object value}) => 'Restam ${value}',
			'budgets.overBy' => ({required Object value}) => 'Estourou em ${value}',
			'budgets.statusSafe' => 'Tranquilo',
			'budgets.statusWarning' => 'Atenção',
			'budgets.statusExceeded' => 'Estourou',
			'budgets.deleteConfirm' => 'Tem certeza que deseja excluir este orçamento?',
			'budgets.budgetCreated' => 'Orçamento criado',
			'budgets.budgetUpdated' => 'Orçamento atualizado',
			'budgets.budgetDeleted' => 'Orçamento excluído',
			'budgets.duplicateCategory' => 'Já existe um orçamento para essa categoria.',
			'budgets.noExpenseCategory' => 'Crie ao menos uma categoria de despesa antes.',
			'budgets.allCategoriesBudgeted' => 'Todas as categorias já têm orçamento.',
			'budgets.emptyTitle' => 'Tome controle dos seus gastos',
			'budgets.emptyBody' => 'Defina um teto mensal por categoria de despesa. O Finanço acompanha quanto você gastou, quanto ainda resta, e mostra de cara quando você está prestes a estourar.',
			'budgets.emptyExample' => 'Ex: R\$ 1.500 em Alimentação, R\$ 400 em Lazer, R\$ 200 em Transporte.',
			'budgets.emptyAction' => 'Criar primeiro orçamento',
			'budgets.formDetails' => 'Detalhes',
			'budgets.formCategorySection' => 'Categoria',
			'budgets.importCsv' => 'Importar orçamentos',
			'budgets.importCsvIntroTitle' => 'Importar orçamentos de CSV',
			'budgets.importCsvIntroBody' => 'Seu arquivo deve seguir o formato esperado (colunas Categoria, Valor). Cada linha aponta para uma categoria de despesa raiz pelo nome; categorias que não existem ou já têm orçamento são ignoradas. Baixe o exemplo para ver como funciona.',
			'budgets.importCsvDownloadExample' => 'Baixar exemplo',
			'budgets.importCsvSelectFile' => 'Selecionar arquivo',
			'budgets.importCsvExampleDownloaded' => 'Exemplo salvo.',
			'budgets.importCsvExampleFailed' => 'Não foi possível salvar o arquivo de exemplo.',
			'budgets.importCsvErrorTitle' => 'Não foi possível importar o CSV',
			'budgets.importCsvSuccess' => ({required Object imported, required Object skipped}) => 'Importados ${imported} orçamentos. Ignorados ${skipped} (categoria desconhecida ou duplicada).',
			'profile.title' => 'Perfil',
			'profile.editProfile' => 'Editar perfil',
			'profile.accounts' => 'Contas',
			'profile.categories' => 'Categorias',
			'profile.bills' => 'Contas a pagar/receber',
			'profile.theme' => 'Tema',
			'profile.themeLight' => 'Claro',
			'profile.themeDark' => 'Escuro',
			'profile.themeSystem' => 'Sistema',
			'profile.signOutConfirm' => 'Tem certeza que deseja sair?',
			'profile.clearData' => 'Limpar todos os meus dados',
			'profile.clearDataDescription' => 'Excluir transações, chat, categorias e contas',
			'profile.clearDataConfirm' => 'Isso excluirá permanentemente todos os dados da sua conta. Continuar?',
			'profile.clearDataConfirmHeadline' => 'Esta ação é permanente',
			'profile.clearDataConfirmBody' => 'Todas as suas transações, contas, categorias, orçamentos, contas a pagar e histórico do chat serão apagados. Não é possível desfazer.',
			'profile.clearDataConfirmField' => 'Digite seu e-mail para confirmar',
			'profile.clearDataSuccess' => 'Os dados da sua conta foram limpos.',
			'profile.downloadApk' => 'Baixar app Android',
			'profile.downloadApkDescription' => 'Instale a versão mobile no seu dispositivo Android',
			'profile.sectionYourData' => 'Seus dados',
			'profile.sectionPreferences' => 'Preferências',
			'profile.sectionGetTheApp' => 'Baixar o app',
			'profile.sectionAccount' => 'Conta',
			'profile.sectionDangerZone' => 'Zona de perigo',
			'profile.sectionMaster' => 'Master',
			'profile.masterPanel' => 'Painel master',
			'profile.masterPanelDescription' => 'Gerencie usuários e a lista de permissões',
			'profile.appearance' => 'Aparência',
			'profile.version' => 'Versão',
			'profile.lightPalette' => 'Paleta clara',
			'profile.darkPalette' => 'Paleta escura',
			'profile.language' => 'Idioma',
			'profile.languageSystem' => 'Sistema',
			'profile.languageEnglish' => 'English',
			'profile.languagePortuguese' => 'Português',
			'startup.tagline' => 'Suas finanças, em sintonia.',
			'startup.stepCheckingAuth' => 'Verificando sua conta',
			'startup.stepSyncingData' => 'Sincronizando seus dados',
			'startup.stepReady' => 'Quase lá',
			'startup.errorTitle' => 'Algo deu errado',
			'startup.errorRetry' => 'Tentar novamente',
			'investments.title' => 'Investimentos',
			'investments.heroTitle' => 'PATRIMÔNIO INVESTIDO',
			'investments.heroAllocated' => 'Alocado',
			'investments.heroPending' => 'Pendente',
			'investments.pendingBannerTitle' => ({required Object amount}) => '${amount} não alocados',
			'investments.pendingBannerSubtitle' => 'Indique onde esse dinheiro está investido.',
			'investments.sectionAllocation' => 'Alocação',
			'investments.sectionClasses' => 'Classes',
			'investments.sectionRebalance' => 'Rebalanceamento',
			'investments.sectionAccountPending' => 'Pendência por conta',
			'investments.allocationEmpty' => 'Sem aportes no momento. Crie classes e registre alocações para ver a distribuição.',
			'investments.classRowSubtitle' => ({required Object actual, required Object target}) => '${actual} de ${target}',
			'investments.classRowOnTarget' => 'no alvo',
			'investments.classRowUnderTarget' => ({required Object amount}) => '${amount} abaixo',
			'investments.classRowOverTarget' => ({required Object amount}) => '${amount} acima',
			'investments.accountPending' => ({required Object amount}) => '${amount} não alocados',
			'investments.accountOverflow' => ({required Object allocated, required Object balance}) => 'Alocação (${allocated}) excede o saldo (${balance}) — reconcilie',
			'investments.allocateAction' => 'Alocar',
			'investments.rebalanceAllocatePending' => ({required Object amount}) => 'Alocar ${amount} pendentes',
			'investments.rebalanceBuy' => ({required Object amount, required Object className}) => 'Aportar ${amount} em ${className}',
			'investments.rebalanceSell' => ({required Object amount, required Object className}) => 'Resgatar ${amount} de ${className}',
			'investments.targetsBanner' => ({required Object percent}) => 'Os alvos somam ${percent}% — ajuste para 100%.',
			'investments.orphanBanner' => ({required Object count}) => 'Manutenção: ${count} holding(s) órfão(s) ignorados nos cálculos.',
			'investments.emptyNoAccountTitle' => 'Crie uma conta de investimento',
			'investments.emptyNoAccountMessage' => 'Antes de declarar onde seu dinheiro está alocado, cadastre uma conta do tipo Investimento. Ela vira o teto que as classes vão dividir.',
			'investments.emptyNoAccountExample' => 'Ex.: "Carteira XP" com saldo R\$ 60.000',
			'investments.emptyNoAccountAction' => 'Criar conta',
			'investments.emptyNoClassesTitle' => 'Defina suas classes de investimento',
			'investments.emptyNoClassesMessage' => 'Crie buckets que representem como você divide seus aportes. Cada classe carrega o alvo (%) que você quer atingir — a tela compara o real contra o alvo.',
			'investments.emptyNoClassesExample' => 'Ex.: ARCA — Ações 25% · FIIs 25% · Cripto 25% · Renda Fixa 25%',
			'investments.emptyNoClassesAction' => 'Criar classe',
			'investments.sectionIdentity' => 'Identidade',
			'investments.sectionTarget' => 'Alvo',
			'investments.classNameLabel' => 'Nome',
			'investments.classNameHint' => 'ex.: Real Estate',
			'investments.classIcon' => 'Ícone',
			'investments.classColor' => 'Cor',
			'investments.targetPercentLabel' => '% alvo',
			'investments.targetHelper' => 'Quanto do patrimônio você quer alocado nesta classe.',
			'investments.targetSubclassHelper' => 'Quanto da classe pai esta subclasse deve representar.',
			'investments.newClassTitle' => 'Nova classe',
			'investments.editClassTitle' => 'Editar classe',
			'investments.newSubclassTitle' => 'Nova subclasse',
			'investments.editSubclassTitle' => 'Editar subclasse',
			'investments.createClass' => 'Criar classe',
			'investments.createSubclass' => 'Criar subclasse',
			'investments.saveClass' => 'Salvar classe',
			'investments.classCreated' => 'Classe criada',
			'investments.classUpdated' => 'Classe atualizada',
			'investments.subclassNameHint' => 'ex.: Apple',
			'investments.parentLabel' => 'Classe pai',
			'investments.parentPlaceholder' => 'Nenhuma — classe raiz',
			'investments.pickParentClass' => 'Escolher classe pai',
			'investments.parentPickerEmpty' => 'Crie uma classe raiz primeiro.',
			'investments.parentPickerNone' => 'Nenhuma (classe raiz)',
			'investments.subclassInheritsHint' => ({required Object parent}) => 'Subclasse herda ícone e cor de ${parent}.',
			'investments.subclassOf' => ({required Object parent}) => 'Subclasse de ${parent}',
			'investments.subclassRowSubtitle' => ({required Object percent}) => '${percent} da classe',
			'investments.addSubclass' => 'Adicionar subclasse',
			'investments.classRowNoSubclasses' => 'Sem subclasses ainda — toque para criar.',
			'investments.classDetailTitle' => 'Classe',
			'investments.detailSubclassesSection' => 'Subclasses',
			'investments.detailTargetAmount' => ({required Object amount}) => 'Meta: ${amount}',
			'investments.detailNoSubclassesTitle' => 'Crie sua primeira subclasse',
			'investments.detailNoSubclassesBody' => 'Subclasses são onde o dinheiro é realmente alocado (ex.: Apple, Tesla). A classe organiza o grupo.',
			'investments.subclassDetailLine' => ({required Object amount, required Object percent}) => '${amount} · ${percent} da classe',
			'investments.subclassSuggestionAdd' => ({required Object amount}) => 'Aporte ${amount} para chegar à meta sugerida',
			'investments.subclassSuggestionTrim' => ({required Object amount}) => 'Reduza ${amount} — está acima da meta sugerida',
			'investments.subclassSuggestionBalanced' => 'No alvo sugerido',
			'investments.subclassSuggestionNoTarget' => 'Defina um alvo % para ver sugestão',
			'investments.deleteClassTitle' => 'Excluir classe',
			'investments.deleteClassConfirm' => 'Holdings vinculados precisam ser reatribuídos ou removidos antes. Deseja prosseguir?',
			'investments.deleteClassSuccess' => 'Classe excluída',
			'investments.newHoldingTitle' => 'Nova alocação',
			'investments.editHoldingTitle' => 'Editar alocação',
			'investments.createHolding' => 'Criar alocação',
			'investments.saveHolding' => 'Salvar alocação',
			'investments.deleteHoldingTitle' => 'Excluir alocação',
			'investments.deleteHoldingConfirm' => 'Esta alocação será removida da composição. O saldo da conta não é afetado.',
			'investments.account' => 'Conta',
			'investments.assetClass' => 'Classe',
			'investments.amount' => 'Valor',
			'investments.notes' => 'Notas',
			'investments.notesHint' => 'Detalhes opcionais (ex.: CDB Banco Inter, vence 2028)',
			'investments.pickAccount' => 'Selecione uma conta',
			'investments.pickClass' => 'Selecione uma classe',
			'investments.pickerEmpty' => 'Nada para escolher ainda.',
			'investments.amountHelper' => ({required Object available}) => 'Disponível na conta: ${available}',
			'investments.amountOverflow' => ({required Object available}) => 'Acima do disponível (${available})',
			'investments.targetShort' => 'alvo',
			'investments.fabAddClass' => 'Nova classe',
			'investments.fabAddClassSubtitle' => 'Crie uma categoria de investimento (ex.: FIIs).',
			'investments.fabAddHolding' => 'Nova alocação',
			'investments.fabAddHoldingSubtitle' => 'Indique onde uma parte do saldo está investida.',
			'investments.fabAddHoldingNoAccount' => 'Crie uma conta de investimento primeiro.',
			'investments.fabAddHoldingNoClass' => 'Crie uma classe primeiro.',
			'investments.fabAddHoldingNoSubclass' => 'Crie uma subclasse antes de alocar — classes são apenas organizadoras.',
			_ => null,
		};
	}
}
