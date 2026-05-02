import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/access_control/domain/usecases/add_allowed_email_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/list_allowed_emails_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/remove_allowed_email_usecase.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/master_panel/domain/usecases/delete_user_as_admin_usecase.dart';
import 'package:financo/features/master_panel/domain/usecases/list_all_users_usecase.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MasterPanelCubit extends Cubit<MasterPanelState> {
  MasterPanelCubit({
    required ListAllUsersUseCase listAllUsers,
    required ListAllowedEmailsUseCase listAllowedEmails,
    required AddAllowedEmailUseCase addAllowedEmail,
    required RemoveAllowedEmailUseCase removeAllowedEmail,
    required DeleteUserAsAdminUseCase deleteUserAsAdmin,
  }) : _listAllUsers = listAllUsers,
       _listAllowedEmails = listAllowedEmails,
       _addAllowedEmail = addAllowedEmail,
       _removeAllowedEmail = removeAllowedEmail,
       _deleteUserAsAdmin = deleteUserAsAdmin,
       super(const MasterPanelInitial());

  final ListAllUsersUseCase _listAllUsers;
  final ListAllowedEmailsUseCase _listAllowedEmails;
  final AddAllowedEmailUseCase _addAllowedEmail;
  final RemoveAllowedEmailUseCase _removeAllowedEmail;
  final DeleteUserAsAdminUseCase _deleteUserAsAdmin;

  Future<void> load() async {
    emit(const MasterPanelLoading());
    final result = await _loadBoth();
    result.fold(
      (failure) => emit(MasterPanelError(failure)),
      (data) => emit(
        MasterPanelLoaded(users: data.$1, allowedEmails: data.$2),
      ),
    );
  }

  Future<Either<Failure, void>> addEmail({
    required String email,
    String? note,
  }) async {
    final current = state;
    if (current is MasterPanelLoaded) emit(current.copyWith(busy: true));
    final result = await _addAllowedEmail(email: email, note: note);
    await result.fold(
      (failure) async {
        if (current is MasterPanelLoaded) emit(current.copyWith(busy: false));
      },
      (_) async => _refresh(),
    );
    return result;
  }

  Future<Either<Failure, void>> removeEmail(String email) async {
    final current = state;
    if (current is MasterPanelLoaded) emit(current.copyWith(busy: true));
    final result = await _removeAllowedEmail(email);
    await result.fold(
      (failure) async {
        if (current is MasterPanelLoaded) emit(current.copyWith(busy: false));
      },
      (_) async => _refresh(),
    );
    return result;
  }

  Future<Either<Failure, void>> deleteUser(String targetUid) async {
    final current = state;
    if (current is MasterPanelLoaded) emit(current.copyWith(busy: true));
    final result = await _deleteUserAsAdmin(targetUid);
    await result.fold(
      (failure) async {
        if (current is MasterPanelLoaded) emit(current.copyWith(busy: false));
      },
      (_) async => _refresh(),
    );
    return result;
  }

  Future<void> _refresh() async {
    final result = await _loadBoth();
    result.fold(
      (failure) => emit(MasterPanelError(failure)),
      (data) => emit(
        MasterPanelLoaded(users: data.$1, allowedEmails: data.$2),
      ),
    );
  }

  Future<Either<Failure, (List<UserEntity>, List<AllowedEmailEntity>)>>
  _loadBoth() async {
    final usersResult = await _listAllUsers();
    final allowedResult = await _listAllowedEmails();
    final usersFailure = usersResult.fold<Failure?>((f) => f, (_) => null);
    if (usersFailure != null) return Left(usersFailure);
    final allowedFailure = allowedResult.fold<Failure?>((f) => f, (_) => null);
    if (allowedFailure != null) return Left(allowedFailure);
    final users = usersResult.getOrElse(() => const []);
    final allowed = allowedResult.getOrElse(() => const []);
    return Right((users, allowed));
  }
}
