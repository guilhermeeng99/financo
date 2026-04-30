import 'dart:async';

import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/create_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_usecase.dart';
import 'package:financo/features/bills/presentation/cubit/bill_form_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/utils/category_display_order.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
        updateBill: GetIt.I<UpdateBillUseCase>(),
        userId: userId,
        existingBill: existingBill,
      ),
      child: _AddBillView(existingBill: existingBill),
    );
  }
}

class _AddBillView extends StatefulWidget {
  const _AddBillView({this.existingBill});

  final BillEntity? existingBill;

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
      _amountController.text = state.amount.toStringAsFixed(2);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.general.delete),
        content: Text(t.bills.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.general.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleteBill = GetIt.I<DeleteBillUseCase>();
    final result = await deleteBill(billId);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillFormCubit, BillFormState>(
      listener: (context, state) {
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
            SnackBar(
              content: Text(state.failure?.message ?? t.general.error),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<BillFormCubit, BillFormState>(
            builder: (context, state) => Text(
              state.isEditing ? t.bills.editBill : t.bills.addBill,
            ),
          ),
          actions: [
            BlocBuilder<BillFormCubit, BillFormState>(
              builder: (context, state) {
                if (!state.isEditing) return const SizedBox.shrink();
                return IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trash, size: 18),
                  onPressed: () => _confirmDelete(state.existingId!),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<BillFormCubit, BillFormState>(
              builder: (context, state) {
                final cubit = context.read<BillFormCubit>();
                if (state.isEditing && state.isPaid) {
                  return _PaidBillBanner();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<BillType>(
                      segments: [
                        ButtonSegment(
                          value: BillType.payable,
                          label: Text(t.bills.typePayable),
                          icon: const FaIcon(
                            FontAwesomeIcons.arrowUp,
                            size: 14,
                          ),
                        ),
                        ButtonSegment(
                          value: BillType.receivable,
                          label: Text(t.bills.typeReceivable),
                          icon: const FaIcon(
                            FontAwesomeIcons.arrowDown,
                            size: 14,
                          ),
                        ),
                      ],
                      selected: {state.type},
                      onSelectionChanged: state.isEditing
                          ? null
                          : (s) => cubit.updateType(s.first),
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: _descriptionController,
                      label: t.bills.description,
                      hintText: t.bills.descriptionHint,
                      validator: Validators.requiredField,
                      onChanged: cubit.updateDescription,
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: _amountController,
                      label: t.bills.amountLabel,
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: Validators.amount,
                      onChanged: cubit.updateAmount,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: t.bills.dueDate,
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(state.dueDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<BillRecurrence>(
                      segments: [
                        ButtonSegment(
                          value: BillRecurrence.oneShot,
                          label: Text(t.bills.oneShot),
                        ),
                        ButtonSegment(
                          value: BillRecurrence.monthly,
                          label: Text(t.bills.monthly),
                        ),
                      ],
                      selected: {state.recurrence},
                      onSelectionChanged: state.isEditing
                          ? null
                          : (s) => cubit.updateRecurrence(s.first),
                    ),
                    const SizedBox(height: 16),
                    _CategoryDropdown(
                      selectedId: state.categoryId,
                      billType: state.type,
                      onChanged: cubit.updateCategoryId,
                    ),
                    const SizedBox(height: 16),
                    FinancoTextField(
                      controller: _notesController,
                      label: t.bills.notes,
                      hintText: t.bills.notesHint,
                      maxLines: 3,
                      onChanged: cubit.updateNotes,
                    ),
                    const SizedBox(height: 32),
                    FinancoButton(
                      label: state.isEditing
                          ? t.general.update
                          : t.general.create,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          unawaited(cubit.submit());
                        }
                      },
                      isLoading: state.status == BillFormStatus.submitting,
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

class _PaidBillBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.circleCheck,
              size: 64,
              color: context.appColors.income,
            ),
            const SizedBox(height: 16),
            Text(
              t.bills.cannotEditPaid,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.selectedId,
    required this.billType,
    required this.onChanged,
  });

  final String? selectedId;
  final BillType billType;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoriesCubit>().state;
    final wantedType = billType == BillType.receivable
        ? CategoryType.income
        : CategoryType.expense;
    final categories = state is CategoriesLoaded
        ? organizeCategoriesForDisplay(
            state.categories.where((c) => c.type == wantedType).toList(),
          )
        : <CategoryEntity>[];

    // Reset selection when current category doesn't belong to the wanted type.
    final hasMatch = selectedId != null &&
        categories.any((c) => c.id == selectedId);
    final effectiveSelectedId = hasMatch ? selectedId : null;

    return DropdownButtonFormField<String?>(
      initialValue: effectiveSelectedId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: t.bills.category,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null ? t.bills.categoryRequired : null,
      items: categories
          .map(
            (c) => DropdownMenuItem<String?>(
              value: c.id,
              child: _CategoryDropdownItem(category: c),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _CategoryDropdownItem extends StatelessWidget {
  const _CategoryDropdownItem({required this.category});

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (!category.isSubcategory) {
      return Text(category.name, overflow: TextOverflow.ellipsis);
    }
    // Subcategories get an indent + arrow icon so the parent/child hierarchy
    // is obvious in the dropdown (mirrors the Categories list page).
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.arrowTurnDown,
            size: 12,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(category.name, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
