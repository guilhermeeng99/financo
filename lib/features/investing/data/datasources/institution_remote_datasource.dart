import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/database/firestore_crud_data_source.dart';
import 'package:financo/features/investing/data/models/institution_model.dart';

abstract class InstitutionRemoteDataSource {
  Future<List<InstitutionModel>> getInstitutions({required String userId});
  Future<InstitutionModel> createInstitution(InstitutionModel model);
  Future<InstitutionModel> updateInstitution(InstitutionModel model);
  Future<void> deleteInstitution(String id);
}

class InstitutionRemoteDataSourceImpl
    extends FirestoreCrudDataSource<InstitutionModel>
    implements InstitutionRemoteDataSource {
  InstitutionRemoteDataSourceImpl({required super.firestore});

  @override
  String get collectionName => 'institutions';

  @override
  String get entityLabel => 'institution';

  @override
  InstitutionModel fromFirestore(DocumentSnapshot<Object?> doc) =>
      InstitutionModel.fromFirestore(doc);

  @override
  Map<String, dynamic> toJson(InstitutionModel model) => model.toJson();

  @override
  String idOf(InstitutionModel model) => model.id;

  @override
  Future<List<InstitutionModel>> getInstitutions({required String userId}) =>
      fetchAllForUser(userId);

  @override
  Future<InstitutionModel> createInstitution(InstitutionModel model) =>
      create(model);

  @override
  Future<InstitutionModel> updateInstitution(InstitutionModel model) =>
      update(model);

  @override
  Future<void> deleteInstitution(String id) => deleteById(id);
}
