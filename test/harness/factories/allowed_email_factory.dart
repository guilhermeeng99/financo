import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';

class AllowedEmailFactory {
  const AllowedEmailFactory._();

  static AllowedEmailEntity entry({
    String email = 'friend@example.com',
    DateTime? addedAt,
    String? note,
  }) {
    return AllowedEmailEntity(
      email: email,
      addedAt: addedAt ?? DateTime(2026, 5),
      note: note,
    );
  }
}
