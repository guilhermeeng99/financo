import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);
  Future<void> updateProfile(UserEntity user);

  /// Deletes every document owned by [userId] across the user-scoped
  /// Firestore collections. Used by the "clear account data" flow.
  Future<void> wipeUserData(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Every top-level collection scoped by `userId`. Keep this list in sync
  /// with the Firestore schema (CLAUDE.md → Firebase — Firestore Collections).
  /// Forgetting one here leaves orphan rows behind on account wipe.
  static const _userScopedCollections = <String>[
    'bills',
    'transactions',
    'chat_messages',
    'categories',
    'accounts',
    'budgets',
  ];

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to fetch profile.');
    }
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      await _firestore.collection('users').doc(user.id).update(model.toJson());
    } on Exception {
      throw const ServerException('Failed to update profile.');
    }
  }

  @override
  Future<void> wipeUserData(String userId) async {
    try {
      for (final collection in _userScopedCollections) {
        await _deleteCollectionDocs(collection, userId);
      }
    } on Exception {
      throw const ServerException('Failed to clear account data.');
    }
  }

  Future<void> _deleteCollectionDocs(String collection, String userId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
