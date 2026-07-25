import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension CurrentUserContextX on BuildContext {
  /// The signed-in user's id, or `''` when unauthenticated.
  ///
  /// Reads [AuthBloc]'s current state without subscribing — page-scoped forms
  /// and one-off loads resolve the id once, at the point of use. Centralizes
  /// the `authState is Authenticated ? authState.user.id : ''` check that was
  /// repeated across every form/page.
  ///
  /// Example:
  /// ```dart
  /// final result = await getInstitutions(userId: context.currentUserId);
  /// ```
  String get currentUserId {
    final state = read<AuthBloc>().state;
    return state is Authenticated ? state.user.id : '';
  }
}
