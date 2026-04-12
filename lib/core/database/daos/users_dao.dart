import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/users_table.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [LocalUsers])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.attachedDatabase);

  Future<void> upsertUser(UserEntity user) =>
      into(localUsers).insertOnConflictUpdate(
        LocalUsersCompanion.insert(
          id: user.id,
          name: user.name,
          email: user.email,
          photoUrl: Value(user.photoUrl),
          createdAt: user.createdAt,
        ),
      );

  Future<UserEntity?> getUser(String id) async {
    final row = await (select(
      localUsers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteAllUsers() => delete(localUsers).go();

  UserEntity _toEntity(LocalUser row) => UserEntity(
    id: row.id,
    name: row.name,
    email: row.email,
    photoUrl: row.photoUrl,
    createdAt: row.createdAt,
  );
}
