import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_date_field.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/services/recurring_transaction_builder.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_sequence_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_sequence_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_account_field.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_account_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_category_field.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_category_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_form_app_bar.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_number_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_recurrence_settings_row.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_sequence_scope_dialog.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_settlement_action_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
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
        createTransactions: GetIt.I<CreateTransactionsUseCase>(),
        updateTransaction: GetIt.I<UpdateTransactionUseCase>(),
        updateTransactionSequence: GetIt.I<UpdateTransactionSequenceUseCase>(),
        createTransfer: GetIt.I<CreateTransferUseCase>(),
        getTransaction: GetIt.I<GetTransactionUseCase>(),
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
    final cubit = context.read<TransactionFormCubit>();
    final state = cubit.state;
    if (state.isEditing) {
      _descriptionController.text = state.description;
      _amountController.text = state.amount > 0
          ? BrlCurrencyInputFormatter.format(state.amount)
          : '';
      _notesController.text = state.notes;
      return;
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
    final cubit = context.read<TransactionFormCubit>();
    final original = cubit.state.originalTransaction;
    final scope = original != null && original.isRecurring
        ? await showTransactionSequenceScopeDialog(context, deleting: true)
        : await _confirmSingleDelete();
    if (scope == null || !mounted) return;

    // Await the actual delete *before* popping so callers that reload on
    // return (e.g. AccountStatementPage) don't refresh against stale data.
    // We invoke the use case directly here and then ask the global
    // TransactionsBloc to refresh its cache — dispatching only the bloc
    // event would be fire-and-forget and lose the await guarantee.
    final result = original != null && original.isRecurring
        ? await GetIt.I<DeleteTransactionSequenceUseCase>().call(
            transaction: original,
            scope: scope,
          )
        : await GetIt.I<DeleteTransactionUseCase>().call(id);
    if (!mounted) return;

    result.fold(
      (failure) {
        context.showSnack(localizedFailure(failure));
      },
      (_) {
        context.read<TransactionsBloc>().add(
          TransactionsLoadRequested(forceRefresh: true),
        );
        _navigateBack();
      },
    );
  }

  Future<TransactionSequenceScope?> _confirmSingleDelete() async {
    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.transactions.deleteTransaction,
      message: t.transactions.deleteConfirm,
      confirmLabel: t.general.delete,
      destructive: true,
    );
    return confirmed ? TransactionSequenceScope.onlyThis : null;
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
    final currentDate = cubit.state.date;
    final now = DateTime.now();
    final allowsFutureDate = !cubit.state.isTransfer;
    // `lastDate` must always be ≥ `initialDate` or `showDatePicker`
    // hits an assertion and the tap silently no-ops. Expense/income rows may
    // be scheduled in the future; the cubit automatically marks them pending.
    // Transfers stay bounded to today because they are always settled now.
    final lastDate = allowsFutureDate
        ? DateTime(now.year + 10, now.month, now.day)
        : currentDate.isAfter(now)
        ? currentDate
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: lastDate,
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
    unawaited(_submit(continueAfterSave: false));
  }

  Future<void> _submit({required bool continueAfterSave}) async {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<TransactionFormCubit>();
      final state = cubit.state;
      var scope = TransactionSequenceScope.onlyThis;
      if (state.isEditing && state.isSequenceMember && !state.isTransfer) {
        final picked = await showTransactionSequenceScopeDialog(
          context,
          deleting: false,
        );
        if (picked == null || !mounted) return;
        scope = picked;
      }
      unawaited(
        cubit.submit(
          continueAfterSave: continueAfterSave,
          sequenceScope: scope,
        ),
      );
    }
  }

  /// Save the current transaction *and* stay on the form with every
  /// field still populated, so the user can quickly file a series of
  /// similar entries (e.g. several grocery purchases from the same
  /// account/category) without re-typing the shared bits.
  void _onSubmitAndContinue() {
    unawaited(_submit(continueAfterSave: true));
  }

  void _onFormStateChanged(
    BuildContext context,
    TransactionFormState state,
  ) {
    if (state.status == FormStatus.success) {
      context.showSnack(
        state.isTransfer && !state.isEditing
            ? t.transactions.transferCreated
            : state.settlementStatus == TransactionSettlementStatus.pending
            ? t.transactions.transactionScheduled
            : state.isEditing
            ? t.transactions.transactionUpdated
            : t.transactions.transactionCreated,
      );
      // "Save and add another" branch — keep the user on the form with
      // every field preserved so they can edit the next entry without
      // re-typing the shared bits (account, category, date, etc.).
      // The cubit also needs its status reset, otherwise the next submit
      // wouldn't transition state and the listener wouldn't fire.
      if (state.continueAfterSave) {
        context.read<TransactionFormCubit>().prepareForNext();
        return;
      }
      _navigateBack();
    } else if (state.status == FormStatus.failure) {
      context.showSnack(localizedFailure(state.failure));
    }
  }

  Future<void> _pickNumber({
    required String title,
    required int min,
    required int max,
    required int selected,
    required ValueChanged<int> onPicked,
  }) async {
    final value = await showTransactionNumberPicker(
      context: context,
      title: title,
      min: min,
      max: max,
      selected: selected,
    );
    if (value != null) onPicked(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<TransactionFormCubit, TransactionFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: TransactionFormAppBar(
          onDelete: (id) => unawaited(_confirmDelete(id)),
        ),
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
                          // switching to Transfer (or flipping
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
                      label: t.payablesReceivables.formDetails,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FinancoCurrencyField(
                                controller: _amountController,
                                label: t.transactions.amountLabel,
                                hintText: t.transactions.amountHint,
                                onChanged: cubit.updateAmount,
                                // Web: land in the amount field ready to type
                                // the instant the form opens. Skipped for
                                // prefilled and autofocus would prepend digits
                                // to the existing value.
                                autofocus: kIsWeb && !state.isEditing,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FinancoDateField(
                                label:
                                    state.settlementStatus ==
                                        TransactionSettlementStatus.pending
                                    ? t.transactions.dueDate
                                    : t.transactions.date,
                                value: state.date,
                                onTap: _pickDate,
                              ),
                            ),
                          ],
                        ),
                        if (!state.isTransfer) ...[
                          const SizedBox(height: 12),
                          FinancoPillToggle<TransactionRecurrence>(
                            selected: state.recurrence,
                            disabled: state.isEditing,
                            onChanged: cubit.updateRecurrence,
                            options: [
                              FinancoPillToggleOption(
                                value: TransactionRecurrence.single,
                                label: t.transactions.recurrenceSingle,
                                icon: FontAwesomeIcons.circleDot,
                              ),
                              FinancoPillToggleOption(
                                value: TransactionRecurrence.installment,
                                label: t.transactions.recurrenceInstallment,
                                icon: FontAwesomeIcons.layerGroup,
                              ),
                              FinancoPillToggleOption(
                                value: TransactionRecurrence.fixed,
                                label: t.transactions.recurrenceFixed,
                                icon: FontAwesomeIcons.repeat,
                              ),
                            ],
                          ),
                          if (state.recurrence !=
                              TransactionRecurrence.single) ...[
                            const SizedBox(height: 12),
                            TransactionRecurrenceSettingsRow(
                              state: state,
                              onPickInterval: () => _pickNumber(
                                title: t.transactions.recurrenceIntervalMonths,
                                min: 1,
                                max: kMaxRecurringWindowMonths,
                                selected: state.recurrenceIntervalMonths,
                                onPicked: (value) => cubit
                                    .updateRecurrenceIntervalMonths('$value'),
                              ),
                              onPickInstallments: () => _pickNumber(
                                title: t.transactions.installmentCount,
                                min: 2,
                                max: maxInstallmentsForInterval(
                                  state.recurrenceIntervalMonths,
                                ),
                                selected: state.installmentCount,
                                onPicked: (value) =>
                                    cubit.updateInstallmentCount('$value'),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.payablesReceivables.formClassification,
                      children: state.isTransfer
                          ? _transferFields(cubit, state)
                          : _normalFields(cubit, state),
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.transactions.notes,
                      children: [
                        FinancoTextField(
                          controller: _descriptionController,
                          label: t.transactions.descriptionOptional,
                          hintText: t.transactions.descriptionHint,
                          onChanged: cubit.updateDescription,
                          subdued: true,
                        ),
                        const SizedBox(height: 12),
                        FinancoTextField(
                          controller: _notesController,
                          label: t.transactions.notesOptional,
                          hintText: t.transactions.notesHint,
                          maxLines: 3,
                          onChanged: cubit.updateNotes,
                          subdued: true,
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
              builder: (context, state) {
                final cubit = context.read<TransactionFormCubit>();
                final canContinue = !state.isEditing;
                return FinancoSubmitBar(
                  label: state.isEditing ? t.general.update : t.general.save,
                  isLoading: state.status == FormStatus.submitting,
                  isEnabled: state.isValid,
                  leading: state.isTransfer
                      ? null
                      : TransactionSettlementActionButton(
                          state: state,
                          cubit: cubit,
                        ),
                  onSubmit: _onSubmit,
                  onSecondarySubmit: canContinue ? _onSubmitAndContinue : null,
                  secondaryIcon: canContinue ? Icons.add : null,
                  secondaryTooltip: canContinue
                      ? t.transactions.saveAndAddAnother
                      : null,
                );
              },
            ),
      ),
    );
  }

  List<Widget> _normalFields(
    TransactionFormCubit cubit,
    TransactionFormState state,
  ) {
    return [
      TransactionAccountField(
        label: t.transactions.account,
        selectedId: state.accountId,
        onTap: () => _pickAccount(
          label: t.transactions.account,
          selectedId: state.accountId,
          onPicked: cubit.updateAccountId,
        ),
      ),
      const SizedBox(height: 12),
      TransactionCategoryField(
        selectedId: state.categoryId,
        onTap: () => _pickCategory(state.type, state.categoryId),
      ),
    ];
  }

  List<Widget> _transferFields(
    TransactionFormCubit cubit,
    TransactionFormState state,
  ) {
    return [
      TransactionAccountField(
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
      TransactionAccountField(
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

}
