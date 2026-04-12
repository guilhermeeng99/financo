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
  }) : _signIn = signInUseCase,
       _signInWithGoogle = signInWithGoogleUseCase,
       _signUp = signUpUseCase,
       _signOut = signOutUseCase,
       _getCurrentUser = getCurrentUser,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final SignInUseCase _signIn;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;

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
    await _signOut();
    emit(const Unauthenticated());
  }
}
