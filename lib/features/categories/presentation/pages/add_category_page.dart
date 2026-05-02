import 'dart:async';

import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:financo/features/categories/presentation/widgets/category_color_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_icon_picker.dart';
import 'package:financo/features/categories/presentation/widgets/parent_category_picker_sheet.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key, this.existingCategory});

  final CategoryEntity? existingCategory;

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late final Future<int> _categoryCountFuture;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is Authenticated ? authState.user.id : '';
    _categoryCountFuture = _fetchCategoryCount();
  }

  Future<int> _fetchCategoryCount() async {
    final result = await GetIt.I<GetCategoriesUseCase>()(userId: _userId);
    return result.fold((_) => 0, (categories) => categories.length);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FutureBuilder<int>(
      future: _categoryCountFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return BlocProvider(
          create: (_) => CategoryFormCubit(
            createCategory: GetIt.I<CreateCategoryUseCase>(),
            updateCategory: GetIt.I<UpdateCategoryUseCase>(),
            userId: _userId,
            existingCategory: widget.existingCategory,
            existingCategoryCount: snapshot.data!,
          ),
          child: const _AddCategoryView(),
        );
      },
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
  List<CategoryEntity> _rootCategories = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<CategoryFormCubit>().state;
    if (state.isEditing) _nameController.text = state.name;
    unawaited(_loadRootCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRootCategories() async {
    final cubitState = context.read<CategoryFormCubit>().state;
    final result = await GetIt.I<GetCategoriesUseCase>()(
      userId: cubitState.userId,
    );
    if (!mounted) return;
    setState(() {
      _rootCategories = result.fold(
        (_) => <CategoryEntity>[],
        (cats) => cats.where((c) => c.canBeParent).toList(),
      );
    });
  }

  Future<void> _confirmDelete(String categoryId) async {
    final getCategories = GetIt.I<GetCategoriesUseCase>();
    final deleteCategory = GetIt.I<DeleteCategoryUseCase>();
    final transactionRepo = GetIt.I<TransactionRepository>();
    final cubitState = context.read<CategoryFormCubit>().state;

    final categoriesResult = await getCategories(userId: cubitState.userId);
    if (!mounted) return;

    final others = categoriesResult.fold(
      (_) => <CategoryEntity>[],
      (cats) => cats.where((c) => c.id != categoryId).toList(),
    );

    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.categories.cannotDeleteLast)),
      );
      return;
    }

    String? targetId = others.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(t.general.delete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.categories.reassignPrompt),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
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
            ],
          ),
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
      ),
    );

    if (confirmed == true && targetId != null && mounted) {
      await transactionRepo.reassignTransactions(
        fromCategoryId: categoryId,
        toCategoryId: targetId!,
      );
      await _deleteBudgetsForCategory(
        userId: cubitState.userId,
        categoryId: categoryId,
      );
      await deleteCategory(categoryId);
      if (mounted) context.pop(true);
    }
  }

  /// Cascade-delete every budget that referenced [categoryId]. Failures
  /// are intentionally swallowed: the category deletion is the user's
  /// primary intent, and orphan budgets are tolerated by the overview
  /// pipeline (see specs/budgets.md rule 8).
  Future<void> _deleteBudgetsForCategory({
    required String userId,
    required String categoryId,
  }) async {
    final getBudgets = GetIt.I<GetBudgetsUseCase>();
    final deleteBudget = GetIt.I<DeleteBudgetUseCase>();
    final budgetsResult = await getBudgets(userId: userId);
    final budgets = budgetsResult.fold<List<BudgetEntity>>(
      (_) => const [],
      (list) => list,
    );
    for (final b in budgets) {
      if (b.categoryId == categoryId) {
        await deleteBudget(b.id);
      }
    }
  }

  Future<void> _pickParent() async {
    final cubit = context.read<CategoryFormCubit>();
    final state = cubit.state;
    final candidates = _rootCategories
        .where((c) => c.type == state.type)
        .toList();
    final picked = await showParentCategoryPicker(
      context: context,
      options: candidates,
      selectedId: state.parentId,
    );
    if (picked == null) return;
    cubit.updateParentId(picked.isEmpty ? null : picked);
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      unawaited(context.read<CategoryFormCubit>().submit());
    }
  }

  void _onFormStateChanged(BuildContext context, CategoryFormState state) {
    if (state.status == FormStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isEditing
                ? t.categories.categoryUpdated
                : t.categories.categoryCreated,
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
                        if (!state.isEditing) ...[
                          const SizedBox(height: 12),
                          _ParentRow(
                            selectedName: _resolveParentName(state.parentId),
                            onTap: _pickParent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.categories.formSectionAppearance,
                      children: [
                        _PreviewTile(
                          name: state.name.isEmpty
                              ? t.categories.nameHint
                              : state.name,
                          icon: state.icon,
                          color: state.color,
                        ),
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
              child: _AppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                tooltip: t.general.delete,
                onPressed: () =>
                    unawaited(_confirmDelete(state.existingId!)),
              ),
            );
          },
        ),
      ],
    );
  }

  String? _resolveParentName(String? parentId) {
    if (parentId == null) return null;
    final match = _rootCategories
        .where((c) => c.id == parentId)
        .firstOrNull;
    return match?.name;
  }
}

class _ParentRow extends StatelessWidget {
  const _ParentRow({required this.selectedName, required this.onTap});

  final String? selectedName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = selectedName != null;
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
              FaIcon(
                FontAwesomeIcons.folderTree,
                size: 14,
                color: colors.onBackgroundLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.categories.parentCategory,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? selectedName! : t.categories.noParentChosen,
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

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final int icon;
  final int color;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.18),
            tint.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                IconData(icon, fontFamily: 'MaterialIcons'),
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    required this.tooltip,
    required this.onPressed,
  });

  final FaIconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

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
