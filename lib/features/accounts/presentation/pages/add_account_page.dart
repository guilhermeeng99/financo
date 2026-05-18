import 'dart:async';

import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/account_form_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/bank_picker_field.dart';
import 'package:financo/features/accounts/presentation/widgets/day_picker_sheet.dart';
import 'package:financo/features/accounts/presentation/widgets/linked_account_picker_sheet.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AddAccountPage extends StatelessWidget {
  const AddAccountPage({super.key, this.existingAccount});

  final AccountEntity? existingAccount;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => AccountFormCubit(
        createAccount: GetIt.I<CreateAccountUseCase>(),
        updateAccount: GetIt.I<UpdateAccountUseCase>(),
        userId: userId,
        existingAccount: existingAccount,
      ),
      child: const _AddAccountView(),
    );
  }
}

class _AddAccountView extends StatefulWidget {
  const _AddAccountView();

  @override
  State<_AddAccountView> createState() => _AddAccountViewState();
}

class _AddAccountViewState extends State<_AddAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _creditLimitController = TextEditingController();

  /// Display name for the linked checking account. Held in local state
  /// (not the cubit) because this page is mounted on the root navigator,
  /// outside the shell's `AccountsCubit` scope, so we can't resolve names
  /// from cached state. Populated by the picker on selection and, in edit
  /// mode, by an async lookup against `GetAccountsUseCase`.
  String? _linkedAccountName;

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountFormCubit>().state;
    if (state.isEditing) {
      _nameController.text = state.name;
      _balanceController.text = state.balance.toStringAsFixed(2);
      if (state.creditLimit > 0) {
        _creditLimitController.text = state.creditLimit.toStringAsFixed(2);
      }
      if (state.linkedAccountId.isNotEmpty) {
        unawaited(_loadLinkedAccountName(state.userId, state.linkedAccountId));
      }
    }
  }

  Future<void> _loadLinkedAccountName(String userId, String linkedId) async {
    final result = await GetIt.I<GetAccountsUseCase>()(userId: userId);
    if (!mounted) return;
    final match = result
        .fold<List<AccountEntity>>((_) => const [], (all) => all)
        .where((a) => a.id == linkedId)
        .firstOrNull;
    if (match == null) return;
    setState(() => _linkedAccountName = match.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String accountId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.general.delete),
        content: Text(t.accounts.deleteConfirm),
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
    if (confirmed != true || !mounted) return;

    final getTransactions = GetIt.I<GetTransactionsUseCase>();
    final deleteTransaction = GetIt.I<DeleteTransactionUseCase>();
    final deleteAccount = GetIt.I<DeleteAccountUseCase>();

    final txResult = await getTransactions(
      userId: userId,
      accountId: accountId,
    );
    await txResult.fold(
      (_) async {},
      (transactions) async {
        await Future.wait(
          transactions.map((tx) => deleteTransaction(tx.id)),
        );
      },
    );

    await deleteAccount(accountId);
    if (mounted) context.pop(true);
  }

  Future<void> _pickClosingDay() async {
    final cubit = context.read<AccountFormCubit>();
    final picked = await showDayPickerSheet(
      context: context,
      selected: cubit.state.closingDay,
      title: t.accounts.pickClosingDay,
    );
    if (picked != null) cubit.updateClosingDay(picked);
  }

  Future<void> _pickDueDay() async {
    final cubit = context.read<AccountFormCubit>();
    final picked = await showDayPickerSheet(
      context: context,
      selected: cubit.state.dueDay,
      title: t.accounts.pickDueDay,
    );
    if (picked != null) cubit.updateDueDay(picked);
  }

  Future<void> _pickLinkedAccount() async {
    final cubit = context.read<AccountFormCubit>();
    final state = cubit.state;
    final picked = await showLinkedAccountPicker(
      context: context,
      userId: state.userId,
      selectedId: state.linkedAccountId.isEmpty ? null : state.linkedAccountId,
    );
    if (picked == null) return;
    cubit.updateLinkedAccountId(picked.id);
    setState(() => _linkedAccountName = picked.name);
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      unawaited(context.read<AccountFormCubit>().submit());
    }
  }

  void _onFormStateChanged(BuildContext context, AccountFormState state) {
    if (state.status == FormStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isEditing
                ? t.accounts.accountUpdated
                : t.accounts.accountCreated,
          ),
        ),
      );
      context.pop(true);
    } else if (state.status == FormStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure?.message ?? t.general.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<AccountFormCubit, AccountFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<AccountFormCubit, AccountFormState>(
              builder: (context, state) {
                final cubit = context.read<AccountFormCubit>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FinancoFormSection(
                      label: t.accounts.formSectionType,
                      children: [
                        FinancoPillToggle<AccountType>(
                          selected: state.type,
                          // Only locks when the original type was
                          // creditCard — checking ↔ investment is a
                          // free swap (same balance sign, no
                          // credit-card-only fields), enabling users
                          // who set up a "checking" to track an
                          // investment account to migrate later.
                          disabled: !state.canChangeType,
                          onChanged: cubit.updateType,
                          options: [
                            FinancoPillToggleOption(
                              value: AccountType.checking,
                              label: t.accounts.checkingShort,
                              icon: FontAwesomeIcons.buildingColumns,
                            ),
                            // creditCard pill stays available only on
                            // create — flipping checking/investment
                            // into credit on an existing account
                            // would invalidate the sign convention
                            // and the credit-card-only fields.
                            if (!state.isEditing)
                              FinancoPillToggleOption(
                                value: AccountType.creditCard,
                                label: t.accounts.creditCard,
                                icon: FontAwesomeIcons.creditCard,
                              ),
                            FinancoPillToggleOption(
                              value: AccountType.investment,
                              label: t.accounts.investmentShort,
                              icon: FontAwesomeIcons.piggyBank,
                            ),
                          ],
                        ),
                        if (state.type == AccountType.investment) ...[
                          const SizedBox(height: 12),
                          _InvestmentHint(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.accounts.formSectionDetails,
                      children: [
                        FinancoTextField(
                          controller: _nameController,
                          label: t.accounts.name,
                          hintText: t.accounts.nameHint,
                          validator: Validators.requiredField,
                          onChanged: cubit.updateName,
                        ),
                        const SizedBox(height: 12),
                        BankPickerField(
                          selected: state.bank,
                          onChanged: cubit.updateBank,
                        ),
                        const SizedBox(height: 12),
                        FinancoTextField(
                          controller: _balanceController,
                          label: t.accounts.balanceLabel,
                          hintText: t.accounts.balanceHint,
                          // signed: true so accounts that start in
                          // overdraft (negative balance) can be entered
                          // on mobile — desktop already accepts `-` from
                          // the physical keyboard.
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                          onChanged: cubit.updateBalance,
                        ),
                      ],
                    ),
                    if (state.type == AccountType.creditCard) ...[
                      const SizedBox(height: 20),
                      FinancoFormSection(
                        label: t.accounts.formSectionCreditCard,
                        children: [
                          _RowSelector(
                            label: t.accounts.linkedAccount,
                            value: state.linkedAccountId.isEmpty
                                ? null
                                : _linkedAccountName,
                            placeholder: t.accounts.pickLinkedAccount,
                            icon: FontAwesomeIcons.link,
                            onTap: _pickLinkedAccount,
                          ),
                          const SizedBox(height: 12),
                          FinancoTextField(
                            controller: _creditLimitController,
                            label: t.accounts.creditLimitLabel,
                            hintText: t.accounts.creditLimitHint,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            onChanged: cubit.updateCreditLimit,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _RowSelector(
                                  label: t.accounts.closingDay,
                                  value: '${state.closingDay}',
                                  placeholder: t.accounts.pickClosingDay,
                                  icon: FontAwesomeIcons.calendarDay,
                                  onTap: _pickClosingDay,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RowSelector(
                                  label: t.accounts.dueDay,
                                  value: '${state.dueDay}',
                                  placeholder: t.accounts.pickDueDay,
                                  icon: FontAwesomeIcons.calendarCheck,
                                  onTap: _pickDueDay,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<AccountFormCubit, AccountFormState>(
          builder: (context, state) => FinancoSubmitBar(
            label: state.isEditing ? t.general.update : t.general.create,
            isLoading: state.status == FormStatus.submitting,
            isEnabled: state.isValid,
            onSubmit: _onSubmit,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      title: BlocBuilder<AccountFormCubit, AccountFormState>(
        builder: (context, state) => Text(
          state.isEditing ? t.accounts.editAccount : t.accounts.addAccount,
          style: context.textTheme.titleMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        BlocBuilder<AccountFormCubit, AccountFormState>(
          builder: (context, state) {
            if (!state.isEditing) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _AppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                onPressed: () => unawaited(
                  _confirmDelete(state.existingId!, state.userId),
                ),
                tooltip: t.general.delete,
              ),
            );
          },
        ),
      ],
    );
  }

}

class _RowSelector extends StatelessWidget {
  const _RowSelector({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = value != null && value!.isNotEmpty;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              FaIcon(icon, size: 14, color: colors.onBackgroundLight),
              const SizedBox(width: 10),
              Expanded(
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
                      hasValue ? value! : placeholder,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: hasValue
                            ? colors.onBackground
                            : colors.onBackgroundLight,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 11,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline tip rendered under the type pill when the user picks
/// "Investment". Investment accounts opt the user into the 50/30/20 card
/// (transfers from checking to here count as savings), and the disclaimer
/// makes it explicit that we don't track market yield.
class _InvestmentHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.income.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(FontAwesomeIcons.piggyBank, size: 14, color: colors.income),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.accounts.investmentDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.accounts.investmentYieldDisclaimer,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onBackgroundLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final FaIconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

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
