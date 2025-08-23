import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/index.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_model.dart';
import 'package:financo/screens/main_flow/screens/categories/widgets/categories_item_menu_actions.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CWFloatingActionButton(
        tooltipMessage: context.t.new_category,
        onTap: categoriesModel.onTapFloatingActionButton,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 60, right: 60),
        child: Column(
          children: [
            Obx(() {
              return Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(context.t.show_only_active_categories),
                  Switch(
                    value: categoriesBloc.showOnlyActiveCategories.value,
                    onChanged: (_) =>
                        categoriesModel.onTapShowOnlyActiveCategories(),
                  ),
                ],
              );
            }),
            Expanded(
              child: Obx(() {
                final categoriesWithSubcategories =
                    categoriesBloc.categoriesWithSubcategories;

                return SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 35,
                    children: [
                      ...categoriesWithSubcategories.entries.map(
                        (entry) => Expanded(
                          child: _CategoriesTypeArea(
                            categoryType: entry.key,
                            categoriesWithSubcategories: entry.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesTypeArea extends StatelessWidget {
  const _CategoriesTypeArea({
    required this.categoryType,
    required this.categoriesWithSubcategories,
  });

  final CategoryType categoryType;
  final Map<CategoryData, List<CategoryData>> categoriesWithSubcategories;

  @override
  Widget build(BuildContext context) {
    final title = categoryType.title(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Column(
          spacing: 15,
          children: [
            ...categoriesWithSubcategories.entries.map(
              (entry) => _CategoryAndSubcategories(
                mainCategory: entry.key,
                subcategories: entry.value,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryAndSubcategories extends StatelessWidget {
  const _CategoryAndSubcategories({
    required this.mainCategory,
    required this.subcategories,
  });

  final CategoryData mainCategory;
  final List<CategoryData> subcategories;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        _CategoryItem(mainCategory, isMainCategory: true),
        if (subcategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              spacing: 8,
              children: subcategories
                  .map(
                    (subcategory) =>
                        _CategoryItem(subcategory, isMainCategory: false),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem(this.category, {required this.isMainCategory});

  final CategoryData category;
  final bool isMainCategory;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: category.isActive ? 1 : 0.5,
      child: CWCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (!isMainCategory) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.subdirectory_arrow_right,
                    size: 16,
                    color: Theme.of(context).customColors.secondaryTextColor,
                  ),
                ),
              ],
              Expanded(
                child: Text(
                  category.name,
                  style: isMainCategory
                      ? null
                      : TextStyle(
                          color: Theme.of(
                            context,
                          ).customColors.secondaryTextColor,
                        ),
                ),
              ),
              CWPopupMenuButton<CategoryData, CategoryMenuAction>(
                item: category,
                actions: CategoryMenuAction.values,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
