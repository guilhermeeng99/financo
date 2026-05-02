import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

sealed class MasterPanelState extends Equatable {
  const MasterPanelState();

  @override
  List<Object?> get props => [];
}

final class MasterPanelInitial extends MasterPanelState {
  const MasterPanelInitial();
}

final class MasterPanelLoading extends MasterPanelState {
  const MasterPanelLoading();
}

final class MasterPanelLoaded extends MasterPanelState {
  const MasterPanelLoaded({
    required this.users,
    required this.allowedEmails,
    this.busy = false,
  });

  final List<UserEntity> users;
  final List<AllowedEmailEntity> allowedEmails;

  /// True while a mutation (add / remove / delete user) is in flight,
  /// so the UI can disable buttons without throwing the whole list away.
  final bool busy;

  MasterPanelLoaded copyWith({
    List<UserEntity>? users,
    List<AllowedEmailEntity>? allowedEmails,
    bool? busy,
  }) {
    return MasterPanelLoaded(
      users: users ?? this.users,
      allowedEmails: allowedEmails ?? this.allowedEmails,
      busy: busy ?? this.busy,
    );
  }

  @override
  List<Object?> get props => [users, allowedEmails, busy];
}

final class MasterPanelError extends MasterPanelState {
  const MasterPanelError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
