import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required FirebaseFirestore firestore,
    required UsersDao usersDao,
  }) : _firestore = firestore,
       _usersDao = usersDao;

  final FirebaseFirestore _firestore;
  final UsersDao _usersDao;

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    try {
      final local = await _usersDao.getUser(userId);
      if (local != null) return Right(local);
      final doc = await _firestore.collection('users').doc(userId).get();
      final user = UserModel.fromFirestore(doc);
      await _usersDao.upsertUser(user);
      return Right(user);
    } on Exception {
      return const Left(
        ServerFailure('Failed to fetch profile.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UserEntity user,
  ) async {
    try {
      final model = UserModel.fromEntity(user);
      await _firestore.collection('users').doc(user.id).update(model.toJson());
      await _usersDao.upsertUser(user);
      return Right(user);
    } on Exception {
      return const Left(
        ServerFailure('Failed to update profile.'),
      );
    }
  }
}
