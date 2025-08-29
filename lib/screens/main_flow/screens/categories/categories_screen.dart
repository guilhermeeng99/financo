import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_model.dart';
import 'package:financo/screens/main_flow/screens/categories/widgets/categories_item_menu_actions.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const _FloatingActionButton(),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 60, right: 60),
        child: Column(
          children: [
            const _TopButtons(),
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

class _TopButtons extends StatelessWidget {
  const _TopButtons();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            context.t.categories.show_only_active,
            style: const TextStyle(fontSize: 18),
          ),
          Switch(
            value: categoriesBloc.showOnlyActiveCategories.value,
            onChanged: (_) => categoriesModel.onTapShowOnlyActiveCategories(),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                categoriesModelExcel.onTapDownloadUserCategories(context),
            icon: Icon(
              Icons.download,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            label: Text(
              context.t.categories.export_categories,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 18,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      );
    });
  }
}

class _FloatingActionButton extends HookWidget {
  const _FloatingActionButton();

  @override
  Widget build(BuildContext context) {
    final showSecondButton = useState(false);

    return MouseRegion(
      onEnter: (_) => showSecondButton.value = true,
      onExit: (_) => showSecondButton.value = false,
      child: Container(
        width: 80,
        height: 170,
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: CWFloatingActionButton(
                tooltipMessage: context.t.categories.new_category,
                onTap: categoriesModel.onTapFloatingActionButton,
              ),
            ),
            if (showSecondButton.value)
              Positioned(
                bottom: 70,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showSecondButton.value ? 1.0 : 0.0,
                  child: CWFloatingActionButton(
                    icon: Icons.upload,
                    size: 40,
                    tooltipMessage: context.t.categories.import_categories,
                    onTap: categoriesModel.onTapImportPopUp,
                  ),
                ),
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

  final FinancialType categoryType;
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.subdirectory_arrow_right, size: 16),
                ),
              ],
              Expanded(child: Text(category.name)),
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
