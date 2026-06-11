import 'package:equatable/equatable.dart';

enum CategoryType { income, expense }

/// Drives the 50/30/20 dashboard card — see
/// docs/specs/fifty_thirty_twenty.md. Only meaningful on `expense` categories;
/// `null` means the user hasn't classified the category yet, which the
/// overview surfaces as "unclassified" (it does not fall back to a
/// parent's bucket — see rule 20 of docs/specs/categories.md).
enum CategoryBucket { needs, wants }

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.userId,
    this.parentId,
    this.bucket,
    this.countsIn50_30_20 = true,
  });

  final String id;
  final String? userId;
  final String name;
  final int icon;
  final int color;
  final CategoryType type;
  final String? parentId;
  final CategoryBucket? bucket;

  /// Only meaningful on **income** categories. When `true` (the default),
  /// transactions on this category feed the 50/30/20 base income
  /// ("100%"). Set to `false` to exclude one-off or non-recurring
  /// receipts (insurance reimbursements, gifts, sold goods) so the
  /// dashboard percentages reflect only the user's recurring income.
  ///
  /// Expense categories ignore this flag — the value is irrelevant.
  /// Legacy categories without the field default to `true` so existing
  /// data keeps its prior behaviour. Name keeps the "50/30/20" branding
  /// for grep-ability with the rule's UI strings + spec.
  final bool countsIn50_30_20;

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
    CategoryBucket? bucket,
    bool clearBucket = false,
    bool? countsIn50_30_20,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      bucket: clearBucket ? null : (bucket ?? this.bucket),
      countsIn50_30_20: countsIn50_30_20 ?? this.countsIn50_30_20,
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
    bucket,
    countsIn50_30_20,
  ];
}

extension CategoryEntityDisplay on CategoryEntity {
  /// Resolves the icon and color every category surface should render.
  ///
  /// Subcategories inherit their parent appearance so category families
  /// stay visually consistent even if legacy child rows still carry
  /// different stored values. [allCategories] is the resolved list used
  /// by the current screen; orphaned children fall back to their own
  /// stored appearance.
  ///
  /// Example:
  /// ```dart
  /// final appearance = child.displayAppearance(categories);
  /// Icon(materialIconFor(appearance.icon), color: Color(appearance.color));
  /// ```
  ({int icon, int color}) displayAppearance(
    Iterable<CategoryEntity> allCategories,
  ) {
    final parentId = this.parentId;
    if (parentId == null) return (icon: icon, color: color);
    for (final category in allCategories) {
      if (category.id == parentId) {
        return (icon: category.icon, color: category.color);
      }
    }
    return (icon: icon, color: color);
  }

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
