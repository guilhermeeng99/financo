import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    unawaited(context.read<CategoriesCubit>().loadCategories());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.categories.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.general.all),
            Tab(text: t.categories.incomeType),
            Tab(text: t.categories.expenseType),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(AppRoutes.addCategory);
          if (result == true && context.mounted) {
            unawaited(
              context.read<CategoriesCubit>().loadCategories(
                forceRefresh: true,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) return const LoadingShimmer();
          if (state is CategoriesError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context.read<CategoriesCubit>().loadCategories(
                forceRefresh: true,
              ),
            );
          }
          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return EmptyState(
                icon: FontAwesomeIcons.tags,
                message: t.categories.empty,
              );
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _CategoryList(
                  categories: state.categories,
                  allCategories: state.categories,
                ),
                _CategoryList(
                  categories: state.categories
                      .where(
                        (c) => c.type == CategoryType.income,
                      )
                      .toList(),
                  allCategories: state.categories,
                ),
                _CategoryList(
                  categories: state.categories
                      .where(
                        (c) => c.type == CategoryType.expense,
                      )
                      .toList(),
                  allCategories: state.categories,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.allCategories,
  });

  final List<CategoryEntity> categories;
  final List<CategoryEntity> allCategories;

  Future<void> _deleteCategory(
    BuildContext context,
    CategoryEntity category,
  ) async {
    final otherCategories = allCategories
        .where((c) => c.id != category.id)
        .toList();
    if (otherCategories.isEmpty) return;

    String? targetCategoryId = otherCategories.first.id;

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
                initialValue: targetCategoryId,
                items: otherCategories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setDialogState(() => targetCategoryId = v),
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

    if (confirmed == true && targetCategoryId != null && context.mounted) {
      final transactionRepo = GetIt.I<TransactionRepository>();
      final categoryRepo = GetIt.I<CategoryRepository>();
      await transactionRepo.reassignTransactions(
        fromCategoryId: category.id,
        toCategoryId: targetCategoryId!,
      );
      await categoryRepo.deleteCategory(category.id);
      if (context.mounted) {
        unawaited(
          context.read<CategoriesCubit>().loadCategories(forceRefresh: true),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(category.color),
            child: Icon(
              IconData(category.icon, fontFamily: 'MaterialIcons'),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(category.name),
          subtitle: Text(category.type.name),
          trailing: category.isDefault
              ? Chip(
                  label: Text(t.general.defaultLabel),
                  labelStyle: context.textTheme.labelSmall,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final result = await context.push(
                          AppRoutes.editCategory,
                          extra: category,
                        );
                        if (result == true && context.mounted) {
                          unawaited(
                            context.read<CategoriesCubit>().loadCategories(
                              forceRefresh: true,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteCategory(context, category),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
