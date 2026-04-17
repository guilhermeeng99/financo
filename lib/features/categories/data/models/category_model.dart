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
    super.userId,
    super.parentId,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    return CategoryModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory CategoryModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return CategoryModel(
      id: id,
      userId: data['userId'] as String?,
      name: data['name'] as String,
      icon: data['icon'] as int,
      color: data['color'] as int,
      type: _parseCategoryType(data['type'] as String),
      parentId: data['parentId'] as String?,
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
      parentId: entity.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      if (parentId != null) 'parentId': parentId,
    };
  }
}
