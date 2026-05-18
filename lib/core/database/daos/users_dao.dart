import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/users_table.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';

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
          fiftyThirtyTwentyNeeds: Value(
            user.fiftyThirtyTwentyTargets?.needs,
          ),
          fiftyThirtyTwentyWants: Value(
            user.fiftyThirtyTwentyTargets?.wants,
          ),
          fiftyThirtyTwentySavings: Value(
            user.fiftyThirtyTwentyTargets?.savings,
          ),
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
    fiftyThirtyTwentyTargets: _parseTargets(
      needs: row.fiftyThirtyTwentyNeeds,
      wants: row.fiftyThirtyTwentyWants,
      savings: row.fiftyThirtyTwentySavings,
    ),
  );

  /// Returns `null` when all three columns are null (the user never
  /// customised the split). Falls back to a classic value per-component
  /// for the rare partial-row case so we never emit an invalid object.
  FiftyThirtyTwentyTargets? _parseTargets({
    required double? needs,
    required double? wants,
    required double? savings,
  }) {
    if (needs == null && wants == null && savings == null) return null;
    return FiftyThirtyTwentyTargets(
      needs: needs ?? FiftyThirtyTwentyTargets.classic.needs,
      wants: wants ?? FiftyThirtyTwentyTargets.classic.wants,
      savings: savings ?? FiftyThirtyTwentyTargets.classic.savings,
    );
  }
}
