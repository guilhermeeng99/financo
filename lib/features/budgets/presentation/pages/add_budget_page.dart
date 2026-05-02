import 'dart:async';

import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:financo/features/budgets/presentation/cubit/budget_form_cubit.dart';
import 'package:financo/features/budgets/presentation/widgets/budget_category_picker_sheet.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key, this.existingBudget});

  final BudgetEntity? existingBudget;

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  /// Categories the user has already budgeted. Loaded once on init so the
  /// picker can hide them in create mode (one budget per category — spec
  /// rule 1). The form's own current `categoryId` is excluded from this
  /// set in edit mode so re-saving the same record doesn't fight itself.
  Set<String> _budgetedCategoryIds = const {};

  @override
  void initState() {
    super.initState();
    unawaited(_loadBudgetedCategoryIds());
  }

  Future<void> _loadBudgetedCategoryIds() async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';
    final result = await GetIt.I<GetBudgetsUseCase>()(userId: userId);
    if (!mounted) return;
    setState(() {
      _budgetedCategoryIds = result.fold(
        (_) => const {},
        (budgets) => budgets.map((b) => b.categoryId).toSet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => BudgetFormCubit(
        createBudget: GetIt.I<CreateBudgetUseCase>(),
        updateBudget: GetIt.I<UpdateBudgetUseCase>(),
        userId: userId,
        existingBudget: widget.existingBudget,
      ),
      child: _AddBudgetView(budgetedCategoryIds: _budgetedCategoryIds),
    );
  }
}

class _AddBudgetView extends StatefulWidget {
  const _AddBudgetView({required this.budgetedCategoryIds});

  final Set<String> budgetedCategoryIds;

  @override
  State<_AddBudgetView> createState() => _AddBudgetViewState();
}

class _AddBudgetViewState extends State<_AddBudgetView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<BudgetFormCubit>().state;
    if (state.amount > 0) {
      _amountController.text = BrlCurrencyInputFormatter.format(state.amount);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final cubit = context.read<BudgetFormCubit>();
    final state = cubit.state;
    // In edit mode, exclude only OTHER budgeted categories — the current
    // one stays selectable so the user sees their selection. In create
    // mode the entire budgeted set is excluded.
    final excluded = state.isEditing
        ? widget.budgetedCategoryIds
              .where((id) => id != state.categoryId)
              .toSet()
        : widget.budgetedCategoryIds;
    final picked = await showBudgetCategoryPicker(
      context: context,
      selectedId: state.categoryId,
      excludedIds: excluded,
    );
    if (picked != null) cubit.updateCategoryId(picked);
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      unawaited(context.read<BudgetFormCubit>().submit());
    }
  }

  void _onFormStateChanged(BuildContext context, BudgetFormState state) {
    if (state.status == BudgetFormStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isEditing
                ? t.budgets.budgetUpdated
                : t.budgets.budgetCreated,
          ),
        ),
      );
      context.pop(true);
    } else if (state.status == BudgetFormStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure?.message ?? t.general.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<BudgetFormCubit, BudgetFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          title: BlocBuilder<BudgetFormCubit, BudgetFormState>(
            builder: (context, state) => Text(
              state.isEditing ? t.budgets.editBudget : t.budgets.addBudget,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<BudgetFormCubit, BudgetFormState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hide the category picker in edit mode: categoryId is
                    // immutable post-creation per spec rule 3.
                    if (!state.isEditing) ...[
                      FinancoFormSection(
                        label: t.budgets.formCategorySection,
                        children: [
                          _CategoryRowField(
                            selectedId: state.categoryId,
                            onTap: _pickCategory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    FinancoFormSection(
                      label: t.budgets.formDetails,
                      children: [
                        FinancoCurrencyField(
                          controller: _amountController,
                          label: t.budgets.amount,
                          hintText: t.budgets.amountHint,
                          validator: Validators.amount,
                          onChanged: context
                              .read<BudgetFormCubit>()
                              .updateAmount,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<BudgetFormCubit, BudgetFormState>(
          builder: (context, state) => FinancoSubmitBar(
            label: state.isEditing ? t.general.update : t.general.create,
            isLoading: state.status == BudgetFormStatus.submitting,
            isEnabled: state.isValid,
            onSubmit: _onSubmit,
          ),
        ),
      ),
    );
  }
}

class _CategoryRowField extends StatelessWidget {
  const _CategoryRowField({
    required this.selectedId,
    required this.onTap,
  });

  final String? selectedId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categories = context
        .watch<CategoriesCubit>()
        .state
        .categoriesOrEmpty
        .where((c) => c.type == CategoryType.expense && c.canBeParent)
        .toList();
    final selected = selectedId == null
        ? null
        : categories.where((c) => c.id == selectedId).firstOrNull;
    final isMissing = selectedId != null && selected == null;
    return FinancoPickerField(
      label: t.budgets.category,
      value: selected?.name,
      placeholder: isMissing
          ? t.budgets.categoryRequired
          : t.budgets.categoryHint,
      isError: isMissing,
      onTap: onTap,
    );
  }
}
