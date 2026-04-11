import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';

CategoryType _parseCategoryType(String value) {
  for (final t in CategoryType.values) {
    if (t.name == value) return t;
  }
  return CategoryType.expense;
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    required super.isDefault,
    required super.sortOrder,
    super.userId,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      userId: data['userId'] as String?,
      name: data['name'] as String,
      icon: data['icon'] as int,
      color: data['color'] as int,
      type: _parseCategoryType(data['type'] as String),
      isDefault: data['isDefault'] as bool,
      sortOrder: data['sortOrder'] as int,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      type: entity.type,
      isDefault: entity.isDefault,
      sortOrder: entity.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
    };
  }
}
