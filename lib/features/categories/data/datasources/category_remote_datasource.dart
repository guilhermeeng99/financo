import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/categories/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({required String userId});
  Future<CategoryModel> createCategory(CategoryModel model);
  Future<CategoryModel> updateCategory(CategoryModel model);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('categories');

  @override
  Future<List<CategoryModel>> getCategories({required String userId}) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .get();

      return snapshot.docs.map(CategoryModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch categories.');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return CategoryModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create category.');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return CategoryModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update category.');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete category.');
    }
  }
}
