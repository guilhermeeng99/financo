import 'package:equatable/equatable.dart';

class AllowedEmailEntity extends Equatable {
  const AllowedEmailEntity({
    required this.email,
    required this.addedAt,
    this.note,
  });

  final String email;
  final DateTime addedAt;
  final String? note;

  AllowedEmailEntity copyWith({
    String? email,
    DateTime? addedAt,
    String? note,
  }) {
    return AllowedEmailEntity(
      email: email ?? this.email,
      addedAt: addedAt ?? this.addedAt,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [email, addedAt, note];
}
