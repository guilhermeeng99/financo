import 'dart:async';

import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/account_form_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
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
        accountRepository: GetIt.I<AccountRepository>(),
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
  final _bankController = TextEditingController();
  final _balanceController = TextEditingController();
  final _creditLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountFormCubit>().state;
    if (state.isEditing) {
      _nameController.text = state.name;
      _bankController.text = state.bank;
      _balanceController.text = state.balance.toString();
      _creditLimitController.text = state.creditLimit.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
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
          context.pop();
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
                          icon: FaIcon(FontAwesomeIcons.buildingColumns),
                        ),
                        ButtonSegment(
                          value: AccountType.creditCard,
                          label: Text(t.accounts.creditCard),
                          icon: FaIcon(FontAwesomeIcons.creditCard),
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
                    FinancoTextField(
                      controller: _bankController,
                      label: t.accounts.bank,
                      hintText: t.accounts.bankHint,
                      onChanged: context.read<AccountFormCubit>().updateBank,
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
