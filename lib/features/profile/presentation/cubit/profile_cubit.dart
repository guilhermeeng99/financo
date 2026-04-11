import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository profileRepository,
    required String userId,
  }) : _profileRepo = profileRepository,
       _userId = userId,
       super(const ProfileInitial());

  final ProfileRepository _profileRepo;
  final String _userId;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (state is ProfileLoaded && !forceRefresh) return;
    emit(const ProfileLoading());

    final result = await _profileRepo.getProfile(_userId);
    result.fold(
      (failure) => emit(ProfileError(failure)),
      (user) => emit(ProfileLoaded(user)),
    );
  }
}

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final UserEntity user;

  @override
  List<Object> get props => [user];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
