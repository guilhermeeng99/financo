import 'dart:async';

import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                _CategoryList(categories: state.categories),
                _CategoryList(
                  categories: state.categories
                      .where(
                        (c) =>
                            c.type == CategoryType.income ||
                            c.type == CategoryType.both,
                      )
                      .toList(),
                ),
                _CategoryList(
                  categories: state.categories
                      .where(
                        (c) =>
                            c.type == CategoryType.expense ||
                            c.type == CategoryType.both,
                      )
                      .toList(),
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
              : null,
        );
      },
    );
  }
}
