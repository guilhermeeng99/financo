import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/models/institution_model.dart';

abstract class InstitutionRemoteDataSource {
  Future<List<InstitutionModel>> getInstitutions({required String userId});
  Future<InstitutionModel> createInstitution(InstitutionModel model);
  Future<InstitutionModel> updateInstitution(InstitutionModel model);
  Future<void> deleteInstitution(String id);
}

class InstitutionRemoteDataSourceImpl implements InstitutionRemoteDataSource {
  InstitutionRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('institutions');

  @override
  Future<List<InstitutionModel>> getInstitutions({
    required String userId,
  }) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(InstitutionModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch institutions.');
    }
  }

  @override
  Future<InstitutionModel> createInstitution(InstitutionModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return InstitutionModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create institution.');
    }
  }

  @override
  Future<InstitutionModel> updateInstitution(InstitutionModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return InstitutionModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update institution.');
    }
  }

  @override
  Future<void> deleteInstitution(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete institution.');
    }
  }
}
