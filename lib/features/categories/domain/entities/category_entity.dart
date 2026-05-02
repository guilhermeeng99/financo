import 'package:equatable/equatable.dart';

enum CategoryType { income, expense }

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.userId,
    this.parentId,
  });

  final String id;
  final String? userId;
  final String name;
  final int icon;
  final int color;
  final CategoryType type;
  final String? parentId;

  bool get canBeParent => parentId == null;
  bool get isSubcategory => parentId != null;

  CategoryEntity copyWith({
    String? id,
    String? userId,
    String? name,
    int? icon,
    int? color,
    CategoryType? type,
    String? parentId,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    icon,
    color,
    type,
    parentId,
  ];
}

extension CategoryEntityDisplay on CategoryEntity {
  /// Human-readable path to this category. Returns `name` for root
  /// categories and `Parent › Child` for subcategories — the project's
  /// standard breadcrumb format.
  ///
  /// [allCategories] is the resolved list (typically
  /// `CategoriesCubit.state.categoriesOrEmpty`). If the parent isn't in
  /// the list (orphan), falls back to `name` so the UI never shows a
  /// dangling separator.
  String displayPath(Iterable<CategoryEntity> allCategories) {
    if (parentId == null) return name;
    for (final c in allCategories) {
      if (c.id == parentId) return '${c.name} › $name';
    }
    return name;
  }
}
