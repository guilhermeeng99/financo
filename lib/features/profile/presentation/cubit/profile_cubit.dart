import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfileUseCase getProfile,
    required String userId,
  }) : _getProfile = getProfile,
       _userId = userId,
       super(const ProfileInitial());

  final GetProfileUseCase _getProfile;
  final String _userId;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (state is ProfileLoaded && !forceRefresh) return;
    emit(const ProfileLoading());

    final result = await _getProfile(_userId);
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
