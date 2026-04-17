import 'package:financo/features/categories/domain/entities/category_entity.dart';

class CategoryFactory {
  const CategoryFactory._();

  static CategoryEntity expense({
    String id = 'cat-expense-1',
    String? userId = 'user-1',
    String name = 'Food',
    int icon = 58746,
    int color = 4294198070,
  }) {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      type: CategoryType.expense,
    );
  }

  static CategoryEntity income({
    String id = 'cat-income-1',
    String? userId = 'user-1',
    String name = 'Salary',
    int icon = 59472,
    int color = 4283215696,
  }) {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      type: CategoryType.income,
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
