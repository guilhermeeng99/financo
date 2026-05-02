import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_category_avatar.dart';
import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_date_field.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_account_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_category_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

enum _Mode { expense, income, transfer }

_Mode _modeFromState(TransactionFormState state) {
  if (state.isTransfer) return _Mode.transfer;
  if (state.type == TransactionType.income) return _Mode.income;
  return _Mode.expense;
}

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({
    super.key,
    this.existingTransaction,
    this.prefillAccountId,
  });

  final TransactionEntity? existingTransaction;

  /// In create mode, pre-selects this account so users coming from an
  /// account-statement page don't have to re-pick the account they're
  /// already viewing. Ignored when editing (the existing accountId wins).
  final String? prefillAccountId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => TransactionFormCubit(
        createTransaction: GetIt.I<CreateTransactionUseCase>(),
        updateTransaction: GetIt.I<UpdateTransactionUseCase>(),
        createTransfer: GetIt.I<CreateTransferUseCase>(),
        userId: userId,
        existingTransaction: existingTransaction,
        prefillAccountId: prefillAccountId,
      ),
      child: const _AddTransactionView(),
    );
  }
}

class _AddTransactionView extends StatefulWidget {
  const _AddTransactionView();

  @override
  State<_AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<_AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<TransactionFormCubit>().state;
    if (state.isEditing) {
      _descriptionController.text = state.description;
      _amountController.text = state.amount > 0
          ? BrlCurrencyInputFormatter.format(state.amount)
          : '';
      _notesController.text = state.notes;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.transactions.deleteTransaction),
        content: Text(t.transactions.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.general.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<TransactionsBloc>().add(TransactionDeleteRequested(id));
      _navigateBack();
    }
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _pickDate() async {
    final cubit = context.read<TransactionFormCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) cubit.updateDate(picked);
  }

  Future<void> _pickAccount({
    required String label,
    required ValueChanged<String> onPicked,
    String? selectedId,
    String? excludeId,
  }) async {
    final picked = await showTransactionAccountPicker(
      context: context,
      title: label,
      selectedId: selectedId,
      excludeId: excludeId,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickCategory(TransactionType type, String? selectedId) async {
    final picked = await showTransactionCategoryPicker(
      context: context,
      transactionType: type,
      selectedId: selectedId,
    );
    if (picked != null && mounted) {
      context.read<TransactionFormCubit>().updateCategoryId(picked);
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      unawaited(context.read<TransactionFormCubit>().submit());
    }
  }

  void _onFormStateChanged(
    BuildContext context,
    TransactionFormState state,
  ) {
    if (state.status == FormStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isTransfer && !state.isEditing
                ? t.transactions.transferCreated
                : state.isEditing
                    ? t.transactions.transactionUpdated
                    : t.transactions.transactionCreated,
          ),
        ),
      );
      _navigateBack();
    } else if (state.status == FormStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure?.message ?? t.general.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<TransactionFormCubit, TransactionFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
              builder: (context, state) {
                final cubit = context.read<TransactionFormCubit>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FinancoFormSection(
                      label: t.transactions.type,
                      children: [
                        FinancoPillToggle<_Mode>(
                          selected: _modeFromState(state),
                          disabled: state.isEditing,
                          onChanged: (mode) {
                            if (mode == _Mode.transfer) {
                              cubit.setTransferMode(enabled: true);
                            } else {
                              cubit
                                ..setTransferMode(enabled: false)
                                ..updateType(
                                  mode == _Mode.income
                                      ? TransactionType.income
                                      : TransactionType.expense,
                                );
                            }
                          },
                          options: [
                            FinancoPillToggleOption(
                              value: _Mode.expense,
                              label: t.transactions.expense,
                              icon: FontAwesomeIcons.arrowUp,
                            ),
                            FinancoPillToggleOption(
                              value: _Mode.income,
                              label: t.transactions.income,
                              icon: FontAwesomeIcons.arrowDown,
                            ),
                            FinancoPillToggleOption(
                              value: _Mode.transfer,
                              label: t.transactions.transfer,
                              icon: FontAwesomeIcons.arrowRightArrowLeft,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.bills.formDetails,
                      children: [
                        FinancoTextField(
                          controller: _descriptionController,
                          label: t.transactions.description,
                          hintText: t.transactions.descriptionHint,
                          onChanged: cubit.updateDescription,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FinancoCurrencyField(
                                controller: _amountController,
                                label: t.transactions.amountLabel,
                                hintText: t.transactions.amountHint,
                                onChanged: cubit.updateAmount,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FinancoDateField(
                                label: t.transactions.date,
                                value: state.date,
                                onTap: _pickDate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.bills.formClassification,
                      children: state.isTransfer
                          ? _transferFields(cubit, state)
                          : _normalFields(cubit, state),
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.transactions.notes,
                      children: [
                        FinancoTextField(
                          controller: _notesController,
                          label: t.transactions.notesOptional,
                          hintText: t.transactions.notesHint,
                          maxLines: 3,
                          onChanged: cubit.updateNotes,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar:
            BlocBuilder<TransactionFormCubit, TransactionFormState>(
              builder: (context, state) => FinancoSubmitBar(
                label: state.isEditing ? t.general.update : t.general.save,
                isLoading: state.status == FormStatus.submitting,
                isEnabled: state.isValid,
                onSubmit: _onSubmit,
              ),
            ),
      ),
    );
  }

  List<Widget> _normalFields(
    TransactionFormCubit cubit,
    TransactionFormState state,
  ) {
    return [
      _AccountRow(
        label: t.transactions.account,
        selectedId: state.accountId,
        onTap: () => _pickAccount(
          label: t.transactions.account,
          selectedId: state.accountId,
          onPicked: cubit.updateAccountId,
        ),
      ),
      const SizedBox(height: 12),
      _CategoryRow(
        selectedId: state.categoryId,
        type: state.type,
        onTap: () => _pickCategory(state.type, state.categoryId),
      ),
    ];
  }

  List<Widget> _transferFields(
    TransactionFormCubit cubit,
    TransactionFormState state,
  ) {
    return [
      _AccountRow(
        label: t.transactions.sourceAccount,
        selectedId: state.accountId,
        onTap: () => _pickAccount(
          label: t.transactions.sourceAccount,
          selectedId: state.accountId,
          excludeId: state.destinationAccountId,
          onPicked: cubit.updateAccountId,
        ),
      ),
      const SizedBox(height: 12),
      _AccountRow(
        label: t.transactions.destinationAccount,
        selectedId: state.destinationAccountId,
        onTap: () => _pickAccount(
          label: t.transactions.destinationAccount,
          selectedId: state.destinationAccountId,
          excludeId: state.accountId,
          onPicked: cubit.updateDestinationAccountId,
        ),
      ),
    ];
  }

  PreferredSizeWidget _buildAppBar() {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      title: BlocBuilder<TransactionFormCubit, TransactionFormState>(
        builder: (context, state) => Text(
          state.isEditing
              ? t.transactions.editTransaction
              : t.transactions.addTransaction,
          style: context.textTheme.titleMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        BlocBuilder<TransactionFormCubit, TransactionFormState>(
          builder: (context, state) {
            if (!state.isEditing) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _AppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                tooltip: t.general.delete,
                onPressed: () =>
                    unawaited(_confirmDelete(state.existingId!)),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.selectedId,
    required this.onTap,
  });

  final String label;
  final String selectedId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = selectedId.isEmpty
        ? null
        : context
              .watch<AccountsCubit>()
              .state
              .accountsOrEmpty
              .where((a) => a.id == selectedId)
              .firstOrNull;
    return FinancoPickerField(
      label: label,
      value: selected?.name,
      placeholder: t.transactions.account,
      leading: FaIcon(
        selected?.type == AccountType.creditCard
            ? FontAwesomeIcons.creditCard
            : FontAwesomeIcons.buildingColumns,
        size: 14,
        color: colors.onBackgroundLight,
      ),
      onTap: onTap,
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.selectedId,
    required this.type,
    required this.onTap,
  });

  final String selectedId;
  final TransactionType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categories =
        context.watch<CategoriesCubit>().state.categoriesOrEmpty;
    final selected = selectedId.isEmpty
        ? null
        : categories.where((c) => c.id == selectedId).firstOrNull;
    return FinancoPickerField(
      label: t.transactions.category,
      // Subcategories render as "Parent › Child" so the user sees where
      // the bucket lives (e.g. "Moradia › Aluguel").
      value: selected?.displayPath(categories),
      placeholder: t.bills.pickCategory,
      leading: selected != null
          ? FinancoCategoryAvatar(category: selected, size: 28)
          : FaIcon(
              FontAwesomeIcons.tag,
              size: 14,
              color: colors.onBackgroundLight,
            ),
      onTap: onTap,
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final FaIconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: FaIcon(icon, size: 14, color: color)),
          ),
        ),
      ),
    );
  }
}
