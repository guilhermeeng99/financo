import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/constants/access_control.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/access_control/data/models/allowed_email_model.dart';

abstract class AccessControlRemoteDataSource {
  Future<bool> isEmailAllowed(String email);
  Future<List<AllowedEmailModel>> listAllowedEmails();
  Future<void> addAllowedEmail({required String email, String? note});
  Future<void> removeAllowedEmail(String email);
}

class AccessControlRemoteDataSourceImpl
    implements AccessControlRemoteDataSource {
  AccessControlRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(kAllowedEmailsCollection);

  @override
  Future<bool> isEmailAllowed(String email) async {
    try {
      final normalized = normalizeEmail(email);
      if (isMasterEmail(normalized)) return true;
      final doc = await _collection.doc(normalized).get();
      return doc.exists;
    } on Exception catch (e) {
      throw ServerException('Failed to check allowlist: $e');
    }
  }

  @override
  Future<List<AllowedEmailModel>> listAllowedEmails() async {
    try {
      final query = await _collection
          .orderBy('addedAt', descending: true)
          .get();
      return query.docs.map(AllowedEmailModel.fromFirestore).toList();
    } on Exception catch (e) {
      throw ServerException('Failed to list allowlist: $e');
    }
  }

  @override
  Future<void> addAllowedEmail({required String email, String? note}) async {
    try {
      final normalized = normalizeEmail(email);
      await _collection.doc(normalized).set({
        'addedAt': FieldValue.serverTimestamp(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      });
    } on Exception catch (e) {
      throw ServerException('Failed to add allowed email: $e');
    }
  }

  @override
  Future<void> removeAllowedEmail(String email) async {
    try {
      final normalized = normalizeEmail(email);
      await _collection.doc(normalized).delete();
    } on Exception catch (e) {
      throw ServerException('Failed to remove allowed email: $e');
    }
  }
}
