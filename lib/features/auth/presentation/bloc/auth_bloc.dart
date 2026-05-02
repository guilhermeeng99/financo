import 'dart:async';

import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/notifications/notification_service.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUser,
    NotificationService? notificationService,
  }) : _signInWithGoogle = signInWithGoogleUseCase,
       _signOut = signOutUseCase,
       _getCurrentUser = getCurrentUser,
       _notifications = notificationService,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);

    _authSubscription = _getCurrentUser.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;
  final NotificationService? _notifications;
  StreamSubscription<UserEntity?>? _authSubscription;
  String? _lastKnownUserId;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUser();
    result.fold(
      (failure) {
        if (failure is AccessDeniedFailure) {
          emit(AccessDenied(failure.email));
        } else {
          emit(const Unauthenticated());
        }
      },
      (user) => user != null
          ? emit(Authenticated(user))
          : emit(const Unauthenticated()),
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) {
        if (failure is AccessDeniedFailure) {
          emit(AccessDenied(failure.email));
        } else {
          emit(AuthError(failure));
        }
      },
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _signOut();
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const Unauthenticated()),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(Authenticated(user));
      // Persist FCM token under the new user. Idempotent — safe on repeated
      // auth state notifications.
      if (_notifications != null) {
        unawaited(_notifications.saveToken(user.id));
      }
      _lastKnownUserId = user.id;
    } else {
      // On sign-out, drop the FCM token tied to the previous user so they
      // stop receiving pushes after logging out.
      final previous = _lastKnownUserId;
      if (previous != null && _notifications != null) {
        unawaited(_notifications.removeTokenOnSignOut(previous));
      }
      _lastKnownUserId = null;
      // Don't clobber an AccessDenied state with Unauthenticated — the
      // restricted page must remain visible until the user explicitly
      // taps "back".
      if (state is! AccessDenied) {
        emit(const Unauthenticated());
      }
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
