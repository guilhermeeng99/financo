import 'package:equatable/equatable.dart';

enum CategoryType { income, expense }

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.sortOrder,
    this.userId,
  });

  final String id;
  final String? userId;
  final String name;
  final int icon;
  final int color;
  final CategoryType type;
  final bool isDefault;
  final int sortOrder;

  CategoryEntity copyWith({
    String? id,
    String? userId,
    String? name,
    int? icon,
    int? color,
    CategoryType? type,
    bool? isDefault,
    int? sortOrder,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
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
    isDefault,
    sortOrder,
  ];
}
