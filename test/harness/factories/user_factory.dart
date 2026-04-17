import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

class UserFactory {
  const UserFactory._();

  static UserEntity entity({
    String id = 'user-1',
    String name = 'Test User',
    String email = 'test@example.com',
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static UserModel model({
    String id = 'user-1',
    String name = 'Test User',
    String email = 'test@example.com',
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static List<UserEntity> list() {
    return [
      entity(),
      entity(
        id: 'user-2',
        name: 'Another User',
        email: 'another@example.com',
      ),
    ];
  }
}
