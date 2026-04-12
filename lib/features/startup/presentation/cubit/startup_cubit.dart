import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:financo/core/sync/sync_service.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit({
    required AuthBloc authBloc,
    required SyncService syncService,
  }) : _authBloc = authBloc,
       _syncService = syncService,
       super(const StartupInitial()) {
    _authSubscription = _authBloc.stream.listen(_onAuthStateChanged);
  }

  final AuthBloc _authBloc;
  final SyncService _syncService;
  late final StreamSubscription<dynamic> _authSubscription;

  void initialize() {
    emit(
      const StartupLoading(
        step: 'Checking authentication...',
        progress: 0,
      ),
    );

    if (_authBloc.state is Authenticated) {
      unawaited(_onAuthStateChanged(_authBloc.state));
    } else if (_authBloc.state is Unauthenticated) {
      emit(const StartupUnauthenticated());
    }
    // Otherwise wait for auth stream.
  }

  Future<void> _onAuthStateChanged(dynamic authState) async {
    if (authState is Authenticated) {
      emit(
        const StartupLoading(
          step: 'Syncing data...',
          progress: 0.3,
        ),
      );
      try {
        await _syncService.fullSync(
          userId: authState.user.id,
          user: authState.user,
        );
        emit(StartupAuthenticated(userId: authState.user.id));
      } on Exception catch (e) {
        emit(StartupError(e.toString()));
      }
    } else if (authState is Unauthenticated) {
      emit(const StartupUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription.cancel());
    return super.close();
  }
}

sealed class StartupState extends Equatable {
  const StartupState();

  @override
  List<Object?> get props => [];
}

final class StartupInitial extends StartupState {
  const StartupInitial();
}

final class StartupLoading extends StartupState {
  const StartupLoading({
    required this.step,
    required this.progress,
  });

  final String step;
  final double progress;

  @override
  List<Object> get props => [step, progress];
}

final class StartupAuthenticated extends StartupState {
  const StartupAuthenticated({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class StartupUnauthenticated extends StartupState {
  const StartupUnauthenticated();
}

final class StartupError extends StartupState {
  const StartupError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
