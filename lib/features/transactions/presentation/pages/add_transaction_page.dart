import 'dart:async';

import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key, this.existingTransaction});

  final TransactionEntity? existingTransaction;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => TransactionFormCubit(
        createTransaction: GetIt.I<CreateTransactionUseCase>(),
        updateTransaction: GetIt.I<UpdateTransactionUseCase>(),
        userId: userId,
        existingTransaction: existingTransaction,
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
      _amountController.text = state.amount > 0 ? state.amount.toString() : '';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionFormCubit, TransactionFormState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isEditing
                    ? t.transactions.transactionUpdated
                    : t.transactions.transactionCreated,
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
          title: BlocBuilder<TransactionFormCubit, TransactionFormState>(
            builder: (context, state) => Text(
              state.isEditing
                  ? t.transactions.editTransaction
                  : t.transactions.addTransaction,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<TransactionType>(
                      segments: [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(t.transactions.expense),
                          icon: FaIcon(FontAwesomeIcons.arrowDown),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(t.transactions.income),
                          icon: FaIcon(FontAwesomeIcons.arrowUp),
                        ),
                      ],
                      selected: {state.type},
                      onSelectionChanged: (selected) => context
                          .read<TransactionFormCubit>()
                          .updateType(selected.first),
                    ),
                    const SizedBox(height: 24),
                    FinancoTextField(
                      controller: _descriptionController,
                      label: t.transactions.description,
                      hintText: t.transactions.descriptionHint,
                      validator: Validators.requiredField,
                      onChanged: context
                          .read<TransactionFormCubit>()
                          .updateDescription,
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: _amountController,
                      label: t.transactions.amountLabel,
                      hintText: t.transactions.amountHint,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: Validators.amount,
                      onChanged: context
                          .read<TransactionFormCubit>()
                          .updateAmount,
                    ),
                    const SizedBox(height: 16),
                    _AccountDropdown(
                      selectedId: state.accountId,
                      onChanged: context
                          .read<TransactionFormCubit>()
                          .updateAccountId,
                    ),
                    const SizedBox(height: 16),
                    _CategoryDropdown(
                      selectedId: state.categoryId,
                      transactionType: state.type,
                      onChanged: context
                          .read<TransactionFormCubit>()
                          .updateCategoryId,
                    ),
                    const SizedBox(height: 16),
                    _DatePicker(
                      date: state.date,
                      onChanged: context
                          .read<TransactionFormCubit>()
                          .updateDate,
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: _notesController,
                      label: t.transactions.notesOptional,
                      hintText: t.transactions.notesHint,
                      maxLines: 3,
                      onChanged: context
                          .read<TransactionFormCubit>()
                          .updateNotes,
                    ),
                    const SizedBox(height: 32),
                    FinancoButton(
                      label: state.isEditing
                          ? t.general.update
                          : t.general.save,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          unawaited(
                            context.read<TransactionFormCubit>().submit(),
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

class _AccountDropdown extends StatelessWidget {
  const _AccountDropdown({
    required this.selectedId,
    required this.onChanged,
  });

  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        if (state is! AccountsLoaded) {
          return const LinearProgressIndicator();
        }
        return DropdownButtonFormField<String>(
          initialValue: selectedId.isNotEmpty ? selectedId : null,
          decoration: InputDecoration(labelText: t.transactions.account),
          items: state.accounts
              .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          validator: (v) => v == null ? t.validators.selectAccount : null,
        );
      },
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.selectedId,
    required this.transactionType,
    required this.onChanged,
  });

  final String selectedId;
  final TransactionType transactionType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is! CategoriesLoaded) {
          return const LinearProgressIndicator();
        }
        final filtered = state.categories
            .where(
              (c) =>
                  c.type.name == transactionType.name || c.type.name == 'both',
            )
            .toList();
        return DropdownButtonFormField<String>(
          initialValue: selectedId.isNotEmpty ? selectedId : null,
          decoration: InputDecoration(labelText: t.transactions.category),
          items: filtered
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          validator: (v) => v == null ? t.validators.selectCategory : null,
        );
      },
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.date,
    required this.onChanged,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: t.transactions.date,
          suffixIcon: FaIcon(FontAwesomeIcons.calendar),
        ),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: context.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
