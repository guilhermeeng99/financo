import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/utils/category_display_order.dart';
import 'package:financo/features/categories/presentation/widgets/categories_csv_import_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
        actions: [
          IconButton(
            tooltip: t.categories.importCsv,
            onPressed: () => showCategoriesCsvImportDialog(context),
            icon: const Icon(Icons.upload_file),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.categories.incomeType),
            Tab(text: t.categories.expenseType),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories_fab',
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
          if (state is CategoriesLoaded || state is CategoriesImported) {
            final categories = state is CategoriesLoaded
                ? state.categories
                : (state as CategoriesImported).categories;
            if (categories.isEmpty) {
              return EmptyState(
                icon: FontAwesomeIcons.tags,
                message: t.categories.empty,
              );
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _CategoryList(
                  categories: organizeCategoriesForDisplay(
                    categories
                        .where((c) => c.type == CategoryType.income)
                        .toList(),
                  ),
                ),
                _CategoryList(
                  categories: organizeCategoriesForDisplay(
                    categories
                        .where((c) => c.type == CategoryType.expense)
                        .toList(),
                  ),
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
  const _CategoryList({required this.categories});

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final colors = context.appColors;
        final parent = category.parentId == null
            ? null
            : categories.where((c) => c.id == category.parentId).firstOrNull;
        final typeLabel = category.isSubcategory
            ? '${parent?.name ?? t.categories.parentCategory} '
                  '• ${t.categories.subcategoryLabel}'
            : (category.type == CategoryType.income
                  ? t.categories.incomeType
                  : t.categories.expenseType);

        return Padding(
          padding: EdgeInsets.only(left: category.isSubcategory ? 20 : 0),
          child: Card(
            child: InkWell(
              onTap: () async {
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
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(category.color),
                      child: Icon(
                        IconData(
                          category.icon,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.isSubcategory
                                ? '↳ ${category.name}'
                                : category.name,
                            style: context.textTheme.titleSmall,
                          ),
                          Text(
                            typeLabel,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 14,
                      color: colors.onBackgroundLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
