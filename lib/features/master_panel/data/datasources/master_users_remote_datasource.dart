import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/auth/data/models/user_model.dart';

abstract class MasterUsersRemoteDataSource {
  Future<List<UserModel>> listAllUsers();
  Future<void> deleteUserAsAdmin(String targetUid);
}

class MasterUsersRemoteDataSourceImpl implements MasterUsersRemoteDataSource {
  MasterUsersRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  }) : _firestore = firestore,
       _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Future<List<UserModel>> listAllUsers() async {
    try {
      final query = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs.map(UserModel.fromFirestore).toList();
    } on Exception catch (e) {
      throw ServerException('Failed to list users: $e');
    }
  }

  @override
  Future<void> deleteUserAsAdmin(String targetUid) async {
    try {
      final callable = _functions.httpsCallable('deleteUserAsAdmin');
      await callable.call<dynamic>({'targetUid': targetUid});
    } on FirebaseFunctionsException catch (e) {
      // Map permission errors so the repository can surface AuthFailure
      // distinctly from generic ServerFailure.
      if (e.code == 'unauthenticated' || e.code == 'permission-denied') {
        throw AuthException(e.message ?? 'Not authorized.');
      }
      throw ServerException(e.message ?? 'Delete user failed.');
    } on Exception catch (e) {
      throw ServerException('Delete user failed: $e');
    }
  }
}
