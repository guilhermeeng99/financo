import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_with_reassignment_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:financo/features/categories/presentation/widgets/category_bucket_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_color_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_icon_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_income_counts_toggle.dart';
import 'package:financo/features/categories/presentation/widgets/category_preview_tile.dart';
import 'package:financo/features/categories/presentation/widgets/parent_category_field.dart';
import 'package:financo/features/categories/presentation/widgets/parent_category_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AddCategoryPage extends StatelessWidget {
  const AddCategoryPage({super.key, this.existingCategory});

  final CategoryEntity? existingCategory;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) {
        final cubit = CategoryFormCubit(
          createCategory: GetIt.I<CreateCategoryUseCase>(),
          updateCategory: GetIt.I<UpdateCategoryUseCase>(),
          getCategories: GetIt.I<GetCategoriesUseCase>(),
          getBudgets: GetIt.I<GetBudgetsUseCase>(),
          userId: userId,
          existingCategory: existingCategory,
        );
        unawaited(cubit.loadFormData());
        return cubit;
      },
      child: const _AddCategoryView(),
    );
  }
}

class _AddCategoryView extends StatefulWidget {
  const _AddCategoryView();

  @override
  State<_AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<_AddCategoryView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<CategoryFormCubit>().state;
    if (state.isEditing) _nameController.text = state.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String categoryId) async {
    final cubitState = context.read<CategoryFormCubit>().state;

    // Reassignment targets come from the form-open snapshot — safe, since
    // CRUD on this user's data is single-threaded while the form is open.
    final others = cubitState.allCategories
        .where((c) => c.id != categoryId)
        .toList();

    if (others.isEmpty) {
      context.showSnack(t.categories.cannotDeleteLast);
      return;
    }

    String? targetId = others.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => FinancoDialog(
          icon: FontAwesomeIcons.trashCan,
          iconColor: ctx.appColors.error,
          title: t.general.delete,
          message: t.categories.reassignPrompt,
          content: DropdownButtonFormField<String>(
            initialValue: targetId,
            items: others
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ),
                )
                .toList(),
            onChanged: (v) => setDialogState(() => targetId = v),
          ),
          actions: [
            FinancoDialogAction(
              label: t.general.cancel,
              onPressed: () => Navigator.pop(ctx, false),
            ),
            FinancoDialogAction(
              label: t.general.delete,
              kind: FinancoDialogActionKind.destructive,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || targetId == null || !mounted) return;

    final result = await GetIt.I<DeleteCategoryWithReassignmentUseCase>()(
      userId: cubitState.userId,
      fromCategoryId: categoryId,
      toCategoryId: targetId!,
    );
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context.pop(true),
    );
  }

  Future<void> _pickParent() async {
    final cubit = context.read<CategoryFormCubit>();
    final state = cubit.state;
    // Same-type filter (rule 15). Also exclude self when editing
    // so the category can't become its own parent.
    final candidates = state.rootCategories
        .where((c) => c.type == state.type && c.id != state.existingId)
        .toList();
    final picked = await showParentCategoryPicker(
      context: context,
      options: candidates,
      selectedId: state.parentId,
    );
    if (picked == null) return;
    if (picked.isEmpty) {
      cubit.updateParentId(null);
      return;
    }
    final parent = state.rootCategories
        .where((c) => c.id == picked)
        .firstOrNull;
    cubit.updateParentId(picked, parent: parent);
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      unawaited(context.read<CategoryFormCubit>().submit());
    }
  }

  void _onFormStateChanged(BuildContext context, CategoryFormState state) {
    if (state.status == FormStatus.success) {
      context
        ..showSnack(
          state.isEditing
              ? t.categories.categoryUpdated
              : t.categories.categoryCreated,
        )
        ..pop(true);
    } else if (state.status == FormStatus.failure) {
      context.showSnack(localizedFailure(state.failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Hold the form until the cubit has loaded the user's categories —
    // the default color (palette index) and parent options depend on them.
    final isLoading = context.select<CategoryFormCubit, bool>(
      (cubit) => cubit.state.isLoadingCategories,
    );
    if (isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return BlocListener<CategoryFormCubit, CategoryFormState>(
      listener: _onFormStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: BlocBuilder<CategoryFormCubit, CategoryFormState>(
              builder: (context, state) {
                final cubit = context.read<CategoryFormCubit>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FinancoFormSection(
                      label: t.categories.formSectionType,
                      children: [
                        FinancoPillToggle<CategoryType>(
                          selected: state.type,
                          disabled: state.isEditing || state.parentId != null,
                          onChanged: cubit.updateType,
                          options: [
                            FinancoPillToggleOption(
                              value: CategoryType.expense,
                              label: t.categories.expenseType,
                              icon: FontAwesomeIcons.arrowUp,
                            ),
                            FinancoPillToggleOption(
                              value: CategoryType.income,
                              label: t.categories.incomeType,
                              icon: FontAwesomeIcons.arrowDown,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.categories.formSectionDetails,
                      children: [
                        FinancoTextField(
                          controller: _nameController,
                          label: t.categories.name,
                          hintText: t.categories.nameHint,
                          validator: Validators.requiredField,
                          onChanged: cubit.updateName,
                        ),
                        // Parent picker now editable on existing
                        // categories too — drives re-parent, promote
                        // (pick "Nenhuma") and demote (pick a root).
                        // Demote guardrails (hasChildren / hasBudget)
                        // are enforced at submit time in the cubit.
                        const SizedBox(height: 12),
                        ParentCategoryField(
                          selectedName: _resolveParentName(state),
                          onTap: _pickParent,
                        ),
                      ],
                    ),
                    // 50/30/20 only applies to root expense categories.
                    // Subcategories inherit their parent's bucket
                    // (docs/specs/categories.md rule 20), so the picker is
                    // hidden when a parent is set.
                    if (state.type == CategoryType.expense &&
                        state.parentId == null) ...[
                      const SizedBox(height: 20),
                      FinancoFormSection(
                        label: t.categories.formSectionBucket,
                        children: [
                          Text(
                            t.categories.bucketHint,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onBackgroundLight,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CategoryBucketPicker(
                            selected: state.bucket,
                            onChanged: cubit.updateBucket,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.categories.bucketHelp,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Only root income categories expose the flag —
                    // subcategories inherit from the parent (rule 22),
                    // mirroring how expense subcategories inherit the
                    // bucket. Keeps the form symmetric.
                    if (state.type == CategoryType.income &&
                        state.parentId == null) ...[
                      const SizedBox(height: 20),
                      FinancoFormSection(
                        label: t.categories.formSectionBucket,
                        children: [
                          CategoryIncomeCountsToggle(
                            value: state.countsIn50_30_20,
                            onChanged: (v) =>
                                cubit.updateCountsIn50_30_20(value: v),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.categories.incomeCountsHint,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.categories.formSectionAppearance,
                      children: [
                        CategoryPreviewTile(
                          name: state.name.isEmpty
                              ? t.categories.nameHint
                              : state.name,
                          icon: state.icon,
                          color: state.color,
                        ),
                        // Subcategories inherit icon + color from the
                        // parent so the hierarchy reads as a single
                        // visual family in the list — hide the pickers
                        // and surface a hint instead of letting the
                        // user pick values that will be overwritten on
                        // the next parent change.
                        if (state.parentId == null) ...[
                          const SizedBox(height: 16),
                          Text(
                            t.categories.selectColor.toUpperCase(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.onBackgroundLight,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CategoryColorPicker(
                            selected: state.color,
                            onChanged: cubit.updateColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.categories.selectIcon.toUpperCase(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.onBackgroundLight,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CategoryIconPickerLauncher(
                            selectedIcon: state.icon,
                            color: state.color,
                            onChanged: cubit.updateIcon,
                          ),
                        ] else ...[
                          const SizedBox(height: 10),
                          Text(
                            t.categories.subcategoryAppearanceInherited,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<CategoryFormCubit, CategoryFormState>(
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
      title: BlocBuilder<CategoryFormCubit, CategoryFormState>(
        builder: (context, state) => Text(
          state.isEditing
              ? t.categories.editCategory
              : t.categories.addCategory,
          style: context.textTheme.titleMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        BlocBuilder<CategoryFormCubit, CategoryFormState>(
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

  String? _resolveParentName(CategoryFormState state) {
    final parentId = state.parentId;
    if (parentId == null) return null;
    final match = state.rootCategories
        .where((c) => c.id == parentId)
        .firstOrNull;
    return match?.name;
  }
}
