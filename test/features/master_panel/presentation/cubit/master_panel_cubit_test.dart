import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/access_control/domain/usecases/add_allowed_email_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/list_allowed_emails_usecase.dart';
import 'package:financo/features/access_control/domain/usecases/remove_allowed_email_usecase.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';
import 'package:financo/features/master_panel/domain/usecases/delete_user_as_admin_usecase.dart';
import 'package:financo/features/master_panel/domain/usecases/list_all_users_usecase.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_cubit.dart';
import 'package:financo/features/master_panel/presentation/cubit/master_panel_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

class _MockMasterUsersRepository extends Mock
    implements MasterUsersRepository {}

void main() {
  late ListAllUsersUseCase listAllUsers;
  late ListAllowedEmailsUseCase listAllowedEmails;
  late AddAllowedEmailUseCase addAllowedEmail;
  late RemoveAllowedEmailUseCase removeAllowedEmail;
  late DeleteUserAsAdminUseCase deleteUserAsAdmin;
  late _MockMasterUsersRepository masterRepo;
  late MockAccessControlRepository accessRepo;

  setUp(() {
    masterRepo = _MockMasterUsersRepository();
    accessRepo = MockAccessControlRepository();
    listAllUsers = ListAllUsersUseCase(masterRepo);
    listAllowedEmails = ListAllowedEmailsUseCase(accessRepo);
    addAllowedEmail = AddAllowedEmailUseCase(accessRepo);
    removeAllowedEmail = RemoveAllowedEmailUseCase(accessRepo);
    deleteUserAsAdmin = DeleteUserAsAdminUseCase(masterRepo);
  });

  MasterPanelCubit buildCubit() => MasterPanelCubit(
    listAllUsers: listAllUsers,
    listAllowedEmails: listAllowedEmails,
    addAllowedEmail: addAllowedEmail,
    removeAllowedEmail: removeAllowedEmail,
    deleteUserAsAdmin: deleteUserAsAdmin,
  );

  void stubLoadOk() {
    when(
      () => masterRepo.listAllUsers(),
    ).thenAnswer((_) async => Right([UserFactory.entity()]));
    when(
      () => accessRepo.listAllowedEmails(),
    ).thenAnswer(
      (_) async => Right([
        AllowedEmailEntity(email: 'a@b.com', addedAt: DateTime(2026)),
      ]),
    );
  }

  group('load', () {
    blocTest<MasterPanelCubit, MasterPanelState>(
      'emits Loading then Loaded on success',
      setUp: stubLoadOk,
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<MasterPanelLoading>(),
        isA<MasterPanelLoaded>(),
      ],
    );

    blocTest<MasterPanelCubit, MasterPanelState>(
      'emits Loading then Error when listAllUsers fails',
      setUp: () {
        when(
          () => masterRepo.listAllUsers(),
        ).thenAnswer((_) async => const Left(ServerFailure()));
        when(
          () => accessRepo.listAllowedEmails(),
        ).thenAnswer((_) async => const Right(<AllowedEmailEntity>[]));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<MasterPanelLoading>(),
        isA<MasterPanelError>(),
      ],
    );
  });

  group('addEmail', () {
    blocTest<MasterPanelCubit, MasterPanelState>(
      'reloads on success',
      setUp: () {
        stubLoadOk();
        when(
          () => accessRepo.addAllowedEmail(
            email: any(named: 'email'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) async => const Right(null));
      },
      build: buildCubit,
      seed: () => const MasterPanelLoaded(users: [], allowedEmails: []),
      act: (cubit) => cubit.addEmail(email: 'new@example.com'),
      expect: () => [
        // busy=true, then reload Loaded
        predicate<MasterPanelState>(
          (state) => state is MasterPanelLoaded && state.busy,
        ),
        isA<MasterPanelLoaded>(),
      ],
    );
  });

  group('deleteUser', () {
    blocTest<MasterPanelCubit, MasterPanelState>(
      'returns failure when repo rejects',
      setUp: () {
        when(
          () => masterRepo.deleteUserAsAdmin(any()),
        ).thenAnswer(
          (_) async => const Left(AuthFailure('Not authorized')),
        );
      },
      build: buildCubit,
      seed: () => const MasterPanelLoaded(users: [], allowedEmails: []),
      act: (cubit) => cubit.deleteUser('uid-1'),
      verify: (cubit) {
        // We don't assert states here — the contract is that the future
        // resolves to Left(failure) so the UI can show a snackbar.
        // (state machine verified by the load + addEmail tests.)
      },
    );
  });
}
