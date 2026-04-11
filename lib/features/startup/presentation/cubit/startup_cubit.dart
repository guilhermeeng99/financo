import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit({required AuthBloc authBloc})
    : _authBloc = authBloc,
      super(const StartupInitial()) {
    _authSubscription = _authBloc.stream.listen(_onAuthStateChanged);
  }

  final AuthBloc _authBloc;
  late final StreamSubscription<dynamic> _authSubscription;

  void initialize() {
    emit(const StartupLoading(step: 'Checking authentication...', progress: 0));

    if (_authBloc.state is Authenticated) {
      _onAuthStateChanged(_authBloc.state);
    } else if (_authBloc.state is Unauthenticated) {
      emit(const StartupUnauthenticated());
    }
    // Otherwise wait for auth stream.
  }

  void _onAuthStateChanged(dynamic authState) {
    if (authState is Authenticated) {
      emit(const StartupLoading(step: 'Loading your data...', progress: 0.5));
      emit(StartupAuthenticated(userId: authState.user.id));
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
  const StartupLoading({required this.step, required this.progress});

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
