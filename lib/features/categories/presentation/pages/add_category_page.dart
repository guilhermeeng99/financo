import 'dart:async';

import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/category_form_cubit.dart';
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
    return FutureBuilder<int>(
      future: _categoryCountFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
    if (state.isEditing) {
      _nameController.text = state.name;
    }
    unawaited(_loadRootCategories());
  }

  Future<void> _loadRootCategories() async {
    final getCategories = GetIt.I<GetCategoriesUseCase>();
    final cubitState = context.read<CategoryFormCubit>().state;
    final result = await getCategories(userId: cubitState.userId);
    if (mounted) {
      setState(() {
        _rootCategories = result.fold(
          (_) => [],
          (cats) => cats.where((c) => c.canBeParent).toList(),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String categoryId) async {
    final getCategories = GetIt.I<GetCategoriesUseCase>();
    final deleteCategory = GetIt.I<DeleteCategoryUseCase>();
    final transactionRepo = GetIt.I<TransactionRepository>();
    final cubitState = context.read<CategoryFormCubit>().state;
    final userId = cubitState.userId;

    final categoriesResult = await getCategories(userId: userId);
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
              child: Text(t.general.delete),
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
      await deleteCategory(categoryId);
      if (mounted) context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryFormCubit, CategoryFormState>(
      listener: (context, state) {
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
            SnackBar(
              content: Text(
                state.failure?.message ?? t.general.error,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<CategoryFormCubit, CategoryFormState>(
            builder: (context, state) => Text(
              state.isEditing
                  ? t.categories.editCategory
                  : t.categories.addCategory,
            ),
          ),
          actions: [
            BlocBuilder<CategoryFormCubit, CategoryFormState>(
              builder: (context, state) {
                if (!state.isEditing) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.trash,
                    size: 18,
                  ),
                  onPressed: () => _confirmDelete(
                    state.existingId!,
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
            child: BlocBuilder<CategoryFormCubit, CategoryFormState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<CategoryType>(
                      segments: [
                        ButtonSegment(
                          value: CategoryType.expense,
                          label: Text(t.categories.expenseType),
                        ),
                        ButtonSegment(
                          value: CategoryType.income,
                          label: Text(t.categories.incomeType),
                        ),
                      ],
                      selected: {state.type},
                      onSelectionChanged:
                          state.isEditing || state.parentId != null
                          ? null
                          : (selected) => context
                                .read<CategoryFormCubit>()
                                .updateType(selected.first),
                    ),
                    if (!state.isEditing) ...[
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        initialValue: state.parentId,
                        decoration: InputDecoration(
                          labelText: t.categories.parentCategory,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            child: Text(t.categories.noParent),
                          ),
                          ..._rootCategories
                              .where((c) => c.type == state.type)
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                        ],
                        onChanged: (value) => context
                            .read<CategoryFormCubit>()
                            .updateParentId(value),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FinancoTextField(
                      controller: _nameController,
                      label: t.categories.name,
                      hintText: t.categories.nameHint,
                      validator: Validators.requiredField,
                      onChanged: context.read<CategoryFormCubit>().updateName,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.categories.selectIcon,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _IconSelector(
                      selectedIcon: state.icon,
                      selectedColor: state.color,
                      onChanged: context.read<CategoryFormCubit>().updateIcon,
                    ),
                    const SizedBox(height: 32),
                    FinancoButton(
                      label: state.isEditing
                          ? t.general.update
                          : t.general.create,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          unawaited(
                            context.read<CategoryFormCubit>().submit(),
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

const _availableIcons = <int, String>{
  59470: 'account_balance',
  59473: 'account_balance_wallet',
  58332: 'shopping_cart',
  58746: 'restaurant',
  58715: 'directions_car',
  58288: 'home',
  59545: 'fitness_center',
  58714: 'local_hospital',
  59494: 'school',
  58726: 'flight',
  58261: 'work',
  59560: 'pets',
  58818: 'local_cafe',
  58835: 'local_grocery_store',
  59690: 'sports_bar',
  59502: 'self_improvement',
  58404: 'card_giftcard',
  59472: 'attach_money',
  58286: 'headset',
  58947: 'movie',
  58810: 'local_bar',
  58694: 'beach_access',
  58168: 'phone_android',
  58123: 'wifi',
  58736: 'local_gas_station',
  58889: 'menu_book',
  58392: 'build',
  59411: 'savings',
  58682: 'child_care',
  59588: 'brush',
};

class _IconSelector extends StatelessWidget {
  const _IconSelector({
    required this.selectedIcon,
    required this.selectedColor,
    required this.onChanged,
  });

  final int selectedIcon;
  final int selectedColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableIcons.keys.map((iconCode) {
        final isSelected = iconCode == selectedIcon;
        return GestureDetector(
          onTap: () => onChanged(iconCode),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: isSelected
                ? Color(selectedColor)
                : context.colorScheme.surfaceContainerHighest,
            child: Icon(
              IconData(iconCode, fontFamily: 'MaterialIcons'),
              color: isSelected
                  ? Colors.white
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }
}
