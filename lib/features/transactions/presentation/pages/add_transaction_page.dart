import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_category_avatar.dart';
import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_date_field.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
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
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
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
import 'package:financo/features/transactions/presentation/widgets/transaction_account_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_category_picker_sheet.dart';
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
    this.prefillFromBill,
  });

  final TransactionEntity? existingTransaction;

  /// In create mode, pre-selects this account so users coming from an
  /// account-statement page don't have to re-pick the account they're
  /// already viewing. Ignored when editing (the existing accountId wins).
  final String? prefillAccountId;

  /// When non-null, the page is being used to *settle a bill*: prefill
  /// description/amount/type/category from the bill, lock the type
  /// toggle, and dispatch `BillMatchAccepted` after the transaction is
  /// successfully saved (so the bill links to the new tx + advances the
  /// monthly chain via `linkBillToExistingTransaction`).
  final BillEntity? prefillFromBill;

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
      child: _AddTransactionView(prefillFromBill: prefillFromBill),
    );
  }
}

class _AddTransactionView extends StatefulWidget {
  const _AddTransactionView({this.prefillFromBill});

  final BillEntity? prefillFromBill;

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
    // Prefill from a pending bill the user is settling. Account stays
    // empty on purpose — the user is the one who knows where the money
    // moved from/to. Date keeps the cubit default (today).
    final bill = widget.prefillFromBill;
    if (bill != null) {
      _descriptionController.text = bill.description;
      _amountController.text = BrlCurrencyInputFormatter.format(bill.amount);
      cubit
        ..updateDescription(bill.description)
        // Feed the cubit the same formatted string the field shows, so the
        // form never round-trips money through a raw double.toString().
        ..updateAmount(_amountController.text)
        ..updateType(
          bill.isReceivable ? TransactionType.income : TransactionType.expense,
        );
      final categoryId = bill.categoryId;
      if (categoryId != null) cubit.updateCategoryId(categoryId);
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
        ? await _pickSequenceScope(deleting: true)
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizedFailure(failure))),
        );
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

  Future<TransactionSequenceScope?> _pickSequenceScope({
    required bool deleting,
  }) {
    return showDialog<TransactionSequenceScope>(
      context: context,
      builder: (ctx) => FinancoDialog(
        icon: deleting ? FontAwesomeIcons.trashCan : FontAwesomeIcons.pen,
        iconColor: deleting ? ctx.appColors.error : ctx.appColors.primary,
        title: deleting
            ? t.transactions.sequenceDeleteTitle
            : t.transactions.sequenceEditTitle,
        message: deleting
            ? t.transactions.sequenceDeleteMessage
            : t.transactions.sequenceEditMessage,
        actions: [
          FinancoDialogAction(
            label: t.general.cancel,
            onPressed: () => Navigator.pop(ctx),
          ),
          FinancoDialogAction(
            label: deleting
                ? t.transactions.sequenceDeleteOnlyThis
                : t.transactions.sequenceEditOnlyThis,
            kind: deleting
                ? FinancoDialogActionKind.destructive
                : FinancoDialogActionKind.secondary,
            onPressed: () =>
                Navigator.pop(ctx, TransactionSequenceScope.onlyThis),
          ),
          FinancoDialogAction(
            label: deleting
                ? t.transactions.sequenceDeleteThisAndFollowing
                : t.transactions.sequenceEditThisAndFollowing,
            kind: deleting
                ? FinancoDialogActionKind.destructive
                : FinancoDialogActionKind.primary,
            onPressed: () => Navigator.pop(
              ctx,
              TransactionSequenceScope.thisAndFollowing,
            ),
          ),
        ],
      ),
    );
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
    final allowsFutureDate =
        !cubit.state.isTransfer &&
        cubit.state.settlementStatus == TransactionSettlementStatus.pending;
    // `lastDate` must always be ≥ `initialDate` or `showDatePicker`
    // hits an assertion and the tap silently no-ops. Transactions
    // with future dates (imported, or created when "now" was later)
    // would otherwise get stuck — keep "today" as the typical upper
    // bound but expand to the existing date if it's already in the
    // future. The cubit's `isValid` still rejects future dates on
    // submit, so the constraint isn't lost.
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
        final picked = await _pickSequenceScope(deleting: false);
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
      // When this page was opened to settle a bill, auto-link the bill
      // to the freshly-created transaction. Same code path the match
      // suggestion sheet uses — the bloc then advances the monthly
      // chain and refreshes the bills list.
      final bill = widget.prefillFromBill;
      final txId = state.savedTransactionId;
      if (bill != null && txId != null) {
        context.read<BillsBloc>().add(
          BillMatchAccepted(billId: bill.id, transactionId: txId),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bill != null
                ? (bill.isReceivable ? t.bills.billReceived : t.bills.billPaid)
                : state.isTransfer && !state.isEditing
                ? t.transactions.transferCreated
                : state.settlementStatus == TransactionSettlementStatus.pending
                ? t.transactions.transactionScheduled
                : state.isEditing
                ? t.transactions.transactionUpdated
                : t.transactions.transactionCreated,
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(state.failure))),
      );
    }
  }

  Future<void> _pickNumber({
    required String title,
    required int min,
    required int max,
    required int selected,
    required ValueChanged<int> onPicked,
  }) async {
    final value = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.appColors.surface,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                title,
                style: ctx.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: max - min + 1,
                itemBuilder: (context, index) {
                  final option = min + index;
                  return ListTile(
                    selected: option == selected,
                    title: Text('$option'),
                    trailing: option == selected
                        ? const FaIcon(FontAwesomeIcons.check, size: 16)
                        : null,
                    onTap: () => Navigator.pop(ctx, option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
                          // Lock the toggle when settling a bill —
                          // switching to Transfer (or flipping
                          // income↔expense) would invalidate the bill
                          // link the page is about to dispatch.
                          disabled:
                              state.isEditing || widget.prefillFromBill != null,
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
                                // edit / bill-settle, where the amount is
                                // prefilled and autofocus would prepend digits
                                // to the existing value.
                                autofocus:
                                    kIsWeb &&
                                    !state.isEditing &&
                                    widget.prefillFromBill == null,
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
                        if (!state.isTransfer &&
                            widget.prefillFromBill == null) ...[
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
                            _RecurrenceSettingsRow(
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
                // "Save and add another" only makes sense for fresh
                // create flows. In edit mode there's no "next one" to
                // queue up; in bill-settlement mode the page is single-
                // shot because it dispatches `BillMatchAccepted` and
                // the cubit lacks a fresh bill to link the next save to.
                final canContinue =
                    !state.isEditing && widget.prefillFromBill == null;
                return FinancoSubmitBar(
                  label: state.isEditing ? t.general.update : t.general.save,
                  isLoading: state.status == FormStatus.submitting,
                  isEnabled: state.isValid,
                  leading: state.isTransfer
                      ? null
                      : _SettlementActionButton(state: state, cubit: cubit),
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
        builder: (context, state) {
          final bill = widget.prefillFromBill;
          final label = state.isEditing
              ? t.transactions.editTransaction
              : bill != null
              ? (bill.isReceivable
                    ? t.transactions.confirmReceiptTitle
                    : t.transactions.confirmPaymentTitle)
              : t.transactions.addTransaction;
          return Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      actions: [
        BlocBuilder<TransactionFormCubit, TransactionFormState>(
          builder: (context, state) {
            if (!state.isEditing) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FinancoAppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                tooltip: t.general.delete,
                onPressed: () => unawaited(_confirmDelete(state.existingId!)),
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

class _RecurrenceSettingsRow extends StatelessWidget {
  const _RecurrenceSettingsRow({
    required this.state,
    required this.onPickInterval,
    required this.onPickInstallments,
  });

  final TransactionFormState state;
  final VoidCallback onPickInterval;
  final VoidCallback onPickInstallments;

  @override
  Widget build(BuildContext context) {
    final periodicity = _StaticValueField(
      label: t.transactions.periodicity,
      value: t.transactions.periodicityMonthly,
    );
    final variableField = state.recurrence == TransactionRecurrence.installment
        ? _NumberPickerField(
            label: t.transactions.installmentCount,
            value: '${state.installmentCount}',
            onTap: onPickInstallments,
          )
        : _NumberPickerField(
            label: t.transactions.recurrenceIntervalMonths,
            value: '${state.recurrenceIntervalMonths}',
            onTap: onPickInterval,
          );

    if (context.screenSize.width < 520) {
      return Column(
        children: [
          periodicity,
          const SizedBox(height: 12),
          variableField,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: periodicity),
        const SizedBox(width: 12),
        Expanded(child: variableField),
      ],
    );
  }
}

class _StaticValueField extends StatelessWidget {
  const _StaticValueField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberPickerField extends StatelessWidget {
  const _NumberPickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinancoPickerField(
      label: label,
      value: value,
      placeholder: value,
      leading: FaIcon(
        FontAwesomeIcons.hashtag,
        size: 13,
        color: context.appColors.onBackgroundLight,
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
    final categories = context.watch<CategoriesCubit>().state.categoriesOrEmpty;
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

class _SettlementActionButton extends StatelessWidget {
  const _SettlementActionButton({
    required this.state,
    required this.cubit,
  });

  final TransactionFormState state;
  final TransactionFormCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = state.settlementStatus == TransactionSettlementStatus.paid;
    final isSubmitting = state.status == FormStatus.submitting;
    final paidLabel = state.type == TransactionType.income
        ? t.transactions.receivedNow
        : t.transactions.paidNow;
    final nextStatus = isPaid
        ? TransactionSettlementStatus.pending
        : TransactionSettlementStatus.paid;
    final tooltip = isPaid ? paidLabel : t.transactions.leavePending;
    final foreground = isPaid ? Colors.white : colors.onBackgroundLight;
    final background = isPaid
        ? colors.income
        : colors.surfaceVariant.withValues(alpha: 0.9);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: isPaid,
        label: tooltip,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: isSubmitting
                ? null
                : () => cubit.updateSettlementStatus(nextStatus),
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: FaIcon(
                isPaid ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
                size: 18,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
