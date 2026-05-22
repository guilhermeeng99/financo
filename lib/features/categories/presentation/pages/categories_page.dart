import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/categories/presentation/utils/category_display_order.dart';
import 'package:financo/features/categories/presentation/widgets/categories_csv_import_dialog.dart';
import 'package:financo/features/categories/presentation/widgets/categories_empty_state.dart';
import 'package:financo/features/categories/presentation/widgets/category_tile.dart';
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

class _CategoriesPageState extends State<CategoriesPage> {
  CategoryType _filter = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    unawaited(context.read<CategoriesCubit>().loadCategories());
  }

  Future<void> _openAdd() async {
    final result = await context.push(AppRoutes.addCategory);
    if (result == true && mounted) {
      unawaited(
        context.read<CategoriesCubit>().loadCategories(forceRefresh: true),
      );
    }
  }

  Future<void> _openEdit(CategoryEntity category) async {
    final result = await context.push(
      AppRoutes.editCategory,
      extra: category,
    );
    if (result == true && mounted) {
      unawaited(
        context.read<CategoriesCubit>().loadCategories(forceRefresh: true),
      );
    }
  }

  Future<void> _openImport() => showCategoriesCsvImportDialog(context);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.categories.title,
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 4),
            child: FinancoAppBarIconButton(
              icon: FontAwesomeIcons.fileArrowUp,
              tooltip: t.categories.importCsv,
              color: colors.primary,
              onPressed: () => unawaited(_openImport()),
            ),
          ),
        ],
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'categories_fab',
          onPressed: _openAdd,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesImporting) {
            return const LoadingShimmer();
          }
          if (state is CategoriesError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () => context.read<CategoriesCubit>().loadCategories(
                forceRefresh: true,
              ),
            );
          }
          final categories = switch (state) {
            CategoriesLoaded(:final categories) => categories,
            CategoriesImported(:final categories) => categories,
            _ => const <CategoryEntity>[],
          };
          if (categories.isEmpty) {
            return CategoriesEmptyState(onAddPressed: _openAdd);
          }
          return _CategoriesBody(
            categories: categories,
            filter: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
            onTapCategory: _openEdit,
          );
        },
      ),
    );
  }
}

class _CategoriesBody extends StatelessWidget {
  const _CategoriesBody({
    required this.categories,
    required this.filter,
    required this.onFilterChanged,
    required this.onTapCategory,
  });

  final List<CategoryEntity> categories;
  final CategoryType filter;
  final ValueChanged<CategoryType> onFilterChanged;
  final void Function(CategoryEntity) onTapCategory;

  @override
  Widget build(BuildContext context) {
    final incomeCount = categories
        .where((c) => c.type == CategoryType.income)
        .length;
    final expenseCount = categories
        .where((c) => c.type == CategoryType.expense)
        .length;
    final filtered = organizeCategoriesForDisplay(
      categories.where((c) => c.type == filter).toList(),
    );

    final byId = {for (final c in categories) c.id: c};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FinancoPillToggle<CategoryType>(
            selected: filter,
            onChanged: onFilterChanged,
            options: [
              FinancoPillToggleOption(
                value: CategoryType.expense,
                label: '${t.categories.expenseType} ($expenseCount)',
                icon: FontAwesomeIcons.arrowUp,
              ),
              FinancoPillToggleOption(
                value: CategoryType.income,
                label: '${t.categories.incomeType} ($incomeCount)',
                icon: FontAwesomeIcons.arrowDown,
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _NoFilterResults()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final parent = c.parentId == null ? null : byId[c.parentId];
                    return CategoryTile(
                      category: c,
                      parent: parent,
                      parentName: parent?.name,
                      onTap: () => onTapCategory(c),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NoFilterResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          t.general.noResults,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
