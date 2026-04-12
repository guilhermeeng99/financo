import 'dart:async';

import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/account_form_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
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

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountFormCubit>().state;
    if (state.isEditing) {
      _nameController.text = state.name;
      _balanceController.text = state.balance.toString();
      _creditLimitController.text = state.creditLimit.toString();
    }
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
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final getTransactions = GetIt.I<GetTransactionsUseCase>();
    final deleteTransaction = GetIt.I<DeleteTransactionUseCase>();
    final deleteAccount = GetIt.I<DeleteAccountUseCase>();

    // Delete all transactions belonging to this account
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
    if (mounted) {
      context.read<DashboardBloc>().add(
        const DashboardRefreshRequested(),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountFormCubit, AccountFormState>(
      listener: (context, state) {
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
            SnackBar(
              content: Text(state.failure?.message ?? 'An error occurred'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AccountFormCubit, AccountFormState>(
            builder: (context, state) => Text(
              state.isEditing ? t.accounts.editAccount : t.accounts.addAccount,
            ),
          ),
          actions: [
            BlocBuilder<AccountFormCubit, AccountFormState>(
              builder: (context, state) {
                if (!state.isEditing) return const SizedBox.shrink();
                return IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trash, size: 18),
                  onPressed: () => unawaited(
                    _confirmDelete(state.existingId!, state.userId),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<AccountFormCubit, AccountFormState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<AccountType>(
                      segments: [
                        ButtonSegment(
                          value: AccountType.checking,
                          label: Text(t.accounts.checkingShort),
                          icon: const FaIcon(FontAwesomeIcons.buildingColumns),
                        ),
                        ButtonSegment(
                          value: AccountType.creditCard,
                          label: Text(t.accounts.creditCard),
                          icon: const FaIcon(FontAwesomeIcons.creditCard),
                        ),
                      ],
                      selected: {state.type},
                      onSelectionChanged: (selected) => context
                          .read<AccountFormCubit>()
                          .updateType(selected.first),
                    ),
                    const SizedBox(height: 24),
                    FinancoTextField(
                      controller: _nameController,
                      label: t.accounts.name,
                      hintText: t.accounts.nameHint,
                      validator: Validators.requiredField,
                      onChanged: context.read<AccountFormCubit>().updateName,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<BankType>(
                      segments: [
                        const ButtonSegment(
                          value: BankType.nubank,
                          label: Text('Nubank'),
                          icon: FaIcon(
                            FontAwesomeIcons.buildingColumns,
                          ),
                        ),
                        ButtonSegment(
                          value: BankType.others,
                          label: Text(t.accounts.bankOthers),
                          icon: const FaIcon(FontAwesomeIcons.wallet),
                        ),
                      ],
                      selected: {state.bank},
                      onSelectionChanged: (selected) => context
                          .read<AccountFormCubit>()
                          .updateBank(selected.first),
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: _balanceController,
                      label: t.accounts.balanceLabel,
                      hintText: t.accounts.balanceHint,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: context.read<AccountFormCubit>().updateBalance,
                    ),
                    if (state.type == AccountType.creditCard) ...[
                      const SizedBox(height: 16),
                      _LinkedAccountDropdown(
                        selectedId: state.linkedAccountId,
                        userId: state.userId,
                        onChanged: context
                            .read<AccountFormCubit>()
                            .updateLinkedAccountId,
                      ),
                      const SizedBox(height: 16),
                      FinancoTextField(
                        controller: _creditLimitController,
                        label: t.accounts.creditLimitLabel,
                        hintText: t.accounts.creditLimitHint,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: context
                            .read<AccountFormCubit>()
                            .updateCreditLimit,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: state.closingDay,
                              decoration: InputDecoration(
                                labelText: t.accounts.closingDay,
                              ),
                              items: List.generate(
                                28,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('${i + 1}'),
                                ),
                              ),
                              onChanged: (v) {
                                if (v != null) {
                                  context
                                      .read<AccountFormCubit>()
                                      .updateClosingDay(v);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: state.dueDay,
                              decoration: InputDecoration(
                                labelText: t.accounts.dueDay,
                              ),
                              items: List.generate(
                                28,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('${i + 1}'),
                                ),
                              ),
                              onChanged: (v) {
                                if (v != null) {
                                  context.read<AccountFormCubit>().updateDueDay(
                                    v,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    FinancoButton(
                      label: state.isEditing
                          ? t.general.update
                          : t.general.create,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          unawaited(
                            context.read<AccountFormCubit>().submit(),
                          );
                        }
                      },
                      isLoading: state.status == FormStatus.submitting,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkedAccountDropdown extends StatefulWidget {
  const _LinkedAccountDropdown({
    required this.selectedId,
    required this.userId,
    required this.onChanged,
  });

  final String selectedId;
  final String userId;
  final ValueChanged<String> onChanged;

  @override
  State<_LinkedAccountDropdown> createState() => _LinkedAccountDropdownState();
}

class _LinkedAccountDropdownState extends State<_LinkedAccountDropdown> {
  List<AccountEntity>? _accounts;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCheckingAccounts());
  }

  Future<void> _loadCheckingAccounts() async {
    final result = await GetIt.I<GetAccountsUseCase>()(
      userId: widget.userId,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (accounts) {
        final checking = accounts
            .where((a) => a.type == AccountType.checking)
            .toList();
        setState(() {
          _accounts = checking;
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();
    return DropdownButtonFormField<String>(
      initialValue: widget.selectedId.isNotEmpty ? widget.selectedId : null,
      decoration: InputDecoration(
        labelText: t.accounts.linkedAccount,
      ),
      items: (_accounts ?? [])
          .map(
            (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) widget.onChanged(value);
      },
      validator: (v) => v == null ? t.validators.selectAccount : null,
    );
  }
}
