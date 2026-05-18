import 'package:equatable/equatable.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
    this.fiftyThirtyTwentyTargets,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  /// User-customised 50/30/20 split. `null` means the user never edited
  /// the targets — callers should fall back to
  /// [FiftyThirtyTwentyTargets.classic] in that case (single source of
  /// truth for the default lives on the value object, not here).
  final FiftyThirtyTwentyTargets? fiftyThirtyTwentyTargets;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    FiftyThirtyTwentyTargets? fiftyThirtyTwentyTargets,
    bool clearFiftyThirtyTwentyTargets = false,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      fiftyThirtyTwentyTargets: clearFiftyThirtyTwentyTargets
          ? null
          : (fiftyThirtyTwentyTargets ?? this.fiftyThirtyTwentyTargets),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    photoUrl,
    createdAt,
    fiftyThirtyTwentyTargets,
  ];
}
