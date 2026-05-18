import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    super.photoUrl,
    super.fiftyThirtyTwentyTargets,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fiftyThirtyTwentyTargets: _parseTargets(data['fiftyThirtyTwentyTargets']),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      fiftyThirtyTwentyTargets: entity.fiftyThirtyTwentyTargets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      if (fiftyThirtyTwentyTargets != null)
        'fiftyThirtyTwentyTargets': {
          'needs': fiftyThirtyTwentyTargets!.needs,
          'wants': fiftyThirtyTwentyTargets!.wants,
          'savings': fiftyThirtyTwentyTargets!.savings,
        },
    };
  }

  /// Reads the embedded targets map. Defensive against partial writes —
  /// any missing field defaults to the classic split's component so the
  /// returned object always passes [FiftyThirtyTwentyTargets.isValid] in
  /// the happy path. Returns `null` when the field is entirely absent
  /// (the "user never customised" state).
  static FiftyThirtyTwentyTargets? _parseTargets(Object? raw) {
    if (raw is! Map) return null;
    final needs = (raw['needs'] as num?)?.toDouble();
    final wants = (raw['wants'] as num?)?.toDouble();
    final savings = (raw['savings'] as num?)?.toDouble();
    if (needs == null && wants == null && savings == null) return null;
    return FiftyThirtyTwentyTargets(
      needs: needs ?? FiftyThirtyTwentyTargets.classic.needs,
      wants: wants ?? FiftyThirtyTwentyTargets.classic.wants,
      savings: savings ?? FiftyThirtyTwentyTargets.classic.savings,
    );
  }
}
