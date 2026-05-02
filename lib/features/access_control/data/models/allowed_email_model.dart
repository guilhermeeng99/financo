import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';

class AllowedEmailModel extends AllowedEmailEntity {
  const AllowedEmailModel({
    required super.email,
    required super.addedAt,
    super.note,
  });

  factory AllowedEmailModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    final addedAt = data['addedAt'];
    return AllowedEmailModel(
      email: doc.id,
      addedAt: addedAt is Timestamp ? addedAt.toDate() : DateTime.now(),
      note: data['note'] as String?,
    );
  }

  factory AllowedEmailModel.fromEntity(AllowedEmailEntity entity) {
    return AllowedEmailModel(
      email: entity.email,
      addedAt: entity.addedAt,
      note: entity.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'addedAt': Timestamp.fromDate(addedAt),
    if (note != null) 'note': note,
  };
}
