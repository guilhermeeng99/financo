import 'dart:async';

import 'package:financo/core/notifications/notification_service.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:financo/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUser,
    NotificationService? notificationService,
  }) : _signIn = signInUseCase,
       _signInWithGoogle = signInWithGoogleUseCase,
       _signUp = signUpUseCase,
       _signOut = signOutUseCase,
       _getCurrentUser = getCurrentUser,
       _notifications = notificationService,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);

    _authSubscription = _getCurrentUser.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final SignInUseCase _signIn;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignUpUseCase _signUp;
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
      (failure) => emit(const Unauthenticated()),
      (user) => user != null
          ? emit(Authenticated(user))
          : emit(const Unauthenticated()),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signIn(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUp(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
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
      emit(const Unauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
