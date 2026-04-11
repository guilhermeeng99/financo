import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/cache/app_data_cache.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required FirebaseFirestore firestore,
    required AppDataCache cache,
  }) : _firestore = firestore,
       _cache = cache;

  final FirebaseFirestore _firestore;
  final AppDataCache _cache;

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    try {
      if (_cache.currentUser != null) return Right(_cache.currentUser!);
      final doc = await _firestore.collection('users').doc(userId).get();
      final user = UserModel.fromFirestore(doc);
      _cache.currentUser = user;
      return Right(user);
    } on Exception {
      return const Left(ServerFailure('Failed to fetch profile.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      await _firestore.collection('users').doc(user.id).update(model.toJson());
      _cache.currentUser = user;
      return Right(user);
    } on Exception {
      return const Left(ServerFailure('Failed to update profile.'));
    }
  }
}
