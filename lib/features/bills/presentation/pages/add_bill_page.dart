import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
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
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/create_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_scoped_usecase.dart';
import 'package:financo/features/bills/presentation/cubit/bill_form_cubit.dart';
import 'package:financo/features/bills/presentation/widgets/bill_category_picker_sheet.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AddBillPage extends StatelessWidget {
  const AddBillPage({super.key, this.existingBill});

  final BillEntity? existingBill;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => BillFormCubit(
        createBill: GetIt.I<CreateBillUseCase>(),
        updateBillScoped: GetIt.I<UpdateBillScopedUseCase>(),
        userId: userId,
        existingBill: existingBill,
      ),
      child: const _AddBillView(),
    );
  }
}

class _AddBillView extends StatefulWidget {
  const _AddBillView();

  @override
  State<_AddBillView> createState() => _AddBillViewState();
}

class _AddBillViewState extends State<_AddBillView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<BillFormCubit>().state;
    _descriptionController.text = state.description;
    if (state.amount > 0) {
      // Pre-format so the field opens already as "2.000,00" in BR
      // style — the formatter only runs on user keystrokes, not on
      // controller.text assignments.
      _amountController.text = BrlCurrencyInputFormatter.format(state.amount);
    }
    _notesController.text = state.notes;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String billId) async {
    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.general.delete,
      message: t.bills.deleteConfirm,
      confirmLabel: t.general.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final deleteBill = GetIt.I<DeleteBillUseCase>();
    final result = await deleteBill(billId);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(failure))),
      ),
      (_) => context.pop(true),
    );
  }

  Future<void> _pickDate() async {
    final cubit = context.read<BillFormCubit>();
    final state = cubit.state;
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) cubit.updateDueDate(picked);
  }

  Future<void> _pickCategory() async {
    final cubit = context.read<BillFormCubit>();
    final state = cubit.state;
    final picked = await showBillCategoryPicker(
      context: context,
      billType: state.type,
      selectedId: state.categoryId,
    );
    if (picked != null) cubit.updateCategoryId(picked);
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<BillFormCubit>();
    final state = cubit.state;
    // Scope dialog only matters for editing a monthly bill — new bills
    // and one-shots have nothing to propagate.
    final shouldAskScope =
        state.isEditing && state.recurrence == BillRecurrence.monthly;
    final scope = shouldAskScope
        ? await _askEditScope()
        : BillEditScope.onlyThis;
    if (scope == null) return; // user dismissed the dialog
    await cubit.submit(scope: scope);
  }

  Future<BillEditScope?> _askEditScope() {
    return showDialog<BillEditScope>(
      context: context,
      builder: (ctx) => FinancoDialog(
        icon: FontAwesomeIcons.calendarCheck,
        title: t.bills.editScopeTitle,
        message: t.bills.editScopeDescription,
        actions: [
          FinancoDialogAction(
            label: t.bills.editScopeOnlyThis,
            onPressed: () => Navigator.pop(ctx, BillEditScope.onlyThis),
          ),
          FinancoDialogAction(
            label: t.bills.editScopeAlsoSubsequents,
            kind: FinancoDialogActionKind.primary,
            onPressed: () => Navigator.pop(ctx, BillEditScope.alsoSubsequents),
          ),
        ],
      ),
    );
  }

  void _onFormStateChanged(BuildContext context, BillFormState state) {
    if (state.status == BillFormStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isEditing ? t.bills.billUpdated : t.bills.billCreated,
          ),
        ),
      );
      context.pop(true);
    } else if (state.status == BillFormStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(state.failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<BillFormCubit, BillFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(),
        body: BlocBuilder<BillFormCubit, BillFormState>(
          builder: (context, state) {
            if (state.isEditing && state.isPaid) return _PaidBillBanner();
            return _FormBody(
              formKey: _formKey,
              descriptionController: _descriptionController,
              amountController: _amountController,
              notesController: _notesController,
              onPickDate: _pickDate,
              onPickCategory: _pickCategory,
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<BillFormCubit, BillFormState>(
          builder: (context, state) {
            if (state.isEditing && state.isPaid) {
              return const SizedBox.shrink();
            }
            return FinancoSubmitBar(
              label: state.isEditing ? t.general.update : t.general.create,
              isLoading: state.status == BillFormStatus.submitting,
              isEnabled: state.isValid,
              onSubmit: () => unawaited(_onSubmit()),
            );
          },
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
      title: BlocBuilder<BillFormCubit, BillFormState>(
        builder: (context, state) => Text(
          state.isEditing ? t.bills.editBill : t.bills.addBill,
          style: context.textTheme.titleMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        BlocBuilder<BillFormCubit, BillFormState>(
          builder: (context, state) {
            if (!state.isEditing) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FinancoAppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                onPressed: () => _confirmDelete(state.existingId!),
                tooltip: t.general.delete,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.formKey,
    required this.descriptionController,
    required this.amountController,
    required this.notesController,
    required this.onPickDate,
    required this.onPickCategory,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final VoidCallback onPickDate;
  final VoidCallback onPickCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: formKey,
        child: BlocBuilder<BillFormCubit, BillFormState>(
          builder: (context, state) {
            final cubit = context.read<BillFormCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FinancoFormSection(
                  label: t.bills.type,
                  children: [
                    FinancoPillToggle<BillType>(
                      selected: state.type,
                      disabled: state.isEditing,
                      onChanged: cubit.updateType,
                      options: [
                        FinancoPillToggleOption(
                          value: BillType.payable,
                          label: t.bills.typePayable,
                          icon: FontAwesomeIcons.arrowUp,
                        ),
                        FinancoPillToggleOption(
                          value: BillType.receivable,
                          label: t.bills.typeReceivable,
                          icon: FontAwesomeIcons.arrowDown,
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
                      controller: descriptionController,
                      label: t.bills.description,
                      hintText: t.bills.descriptionHint,
                      onChanged: cubit.updateDescription,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FinancoCurrencyField(
                            controller: amountController,
                            label: t.bills.amountLabel,
                            hintText: '0,00',
                            validator: Validators.amount,
                            onChanged: cubit.updateAmount,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FinancoDateField(
                            label: t.bills.dueDate,
                            value: state.dueDate,
                            onTap: onPickDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FinancoFormSection(
                  label: t.bills.formClassification,
                  children: [
                    _CategoryRowField(
                      billType: state.type,
                      selectedId: state.categoryId,
                      onTap: onPickCategory,
                    ),
                    const SizedBox(height: 16),
                    FinancoPillToggle<BillRecurrence>(
                      selected: state.recurrence,
                      disabled: state.isEditing,
                      onChanged: cubit.updateRecurrence,
                      options: [
                        FinancoPillToggleOption(
                          value: BillRecurrence.oneShot,
                          label: t.bills.oneShot,
                        ),
                        FinancoPillToggleOption(
                          value: BillRecurrence.monthly,
                          label: t.bills.monthly,
                          icon: FontAwesomeIcons.arrowsRotate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: notesController,
                      label: t.bills.notes,
                      hintText: t.bills.notesHint,
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
    );
  }
}

class _CategoryRowField extends StatelessWidget {
  const _CategoryRowField({
    required this.billType,
    required this.selectedId,
    required this.onTap,
  });

  final BillType billType;
  final String? selectedId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final wantedType = billType == BillType.receivable
        ? CategoryType.income
        : CategoryType.expense;
    final categories = context
        .watch<CategoriesCubit>()
        .state
        .categoriesOrEmpty
        .where((c) => c.type == wantedType)
        .toList();
    final selected = selectedId == null
        ? null
        : categories.where((c) => c.id == selectedId).firstOrNull;
    final isMissing = selectedId != null && selected == null;
    return FinancoPickerField(
      label: t.bills.category,
      // Subcategories render as "Parent › Child" (e.g. "Moradia ›
      // Aluguel"). The `allCategories` list is the type-filtered one
      // here, but the parent of an expense subcategory is itself an
      // expense category, so the lookup still resolves.
      value: selected?.displayPath(categories),
      placeholder: isMissing ? t.bills.categoryRequired : t.bills.pickCategory,
      isError: isMissing,
      leading: selected == null
          ? null
          : FinancoCategoryAvatar(category: selected),
      onTap: onTap,
    );
  }
}

class _PaidBillBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.circleCheck,
                  size: 36,
                  color: colors.success,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.bills.cannotEditPaid,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
