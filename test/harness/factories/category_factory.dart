import 'package:financo/features/categories/domain/entities/category_entity.dart';

class CategoryFactory {
  const CategoryFactory._();

  static CategoryEntity expense({
    String id = 'cat-expense-1',
    String? userId = 'user-1',
    String name = 'Food',
    int icon = 58746,
    int color = 4294198070,
    CategoryBucket? bucket,
  }) {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      type: CategoryType.expense,
      bucket: bucket,
    );
  }

  static CategoryEntity income({
    String id = 'cat-income-1',
    String? userId = 'user-1',
    String name = 'Salary',
    int icon = 59472,
    int color = 4283215696,
    bool countsIn50_30_20 = true,
  }) {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      type: CategoryType.income,
      countsIn50_30_20: countsIn50_30_20,
    );
  }

  static CategoryEntity subcategory({
    String id = 'cat-sub-1',
    String? userId = 'user-1',
    String name = 'Restaurants',
    int icon = 58746,
    int color = 4294198070,
    CategoryType type = CategoryType.expense,
    String parentId = 'cat-expense-1',
  }) {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      type: type,
      parentId: parentId,
    );
  }

  static List<CategoryEntity> list() {
    return [
      expense(),
      expense(
        id: 'cat-expense-2',
        name: 'Transport',
        icon: 58715,
        color: 4294940672,
      ),
      income(),
      income(
        id: 'cat-income-2',
        name: 'Freelance',
        icon: 58261,
        color: 4278228616,
      ),
    ];
  }
}
