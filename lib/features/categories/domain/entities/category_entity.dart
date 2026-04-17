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
