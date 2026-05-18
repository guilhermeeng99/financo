import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_targets_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/update_fifty_thirty_twenty_targets_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the user's active 50/30/20 target split for the session and
/// owns updates to it. Session-scoped (created by the shell route with a
/// resolved `userId`, lives for the duration of the shell), mirroring
/// the other per-user cubits like `BudgetsCubit`.
///
/// Other components (the dashboard bloc, the detail page) read targets
/// from here and re-render when the cubit emits a new state. The compute
/// pipeline reads `state.targets` whenever it needs to bucket spend
/// against the user's preference — the classic 50/30/20 is the fallback
/// only when the cubit hasn't loaded yet.
class FiftyThirtyTwentyTargetsCubit
    extends Cubit<FiftyThirtyTwentyTargetsState> {
  FiftyThirtyTwentyTargetsCubit({
    required GetFiftyThirtyTwentyTargetsUseCase getTargets,
    required UpdateFiftyThirtyTwentyTargetsUseCase updateTargets,
    required String userId,
  }) : _getTargets = getTargets,
       _updateTargets = updateTargets,
       _userId = userId,
       super(const FiftyThirtyTwentyTargetsState.initial());

  final GetFiftyThirtyTwentyTargetsUseCase _getTargets;
  final UpdateFiftyThirtyTwentyTargetsUseCase _updateTargets;
  final String _userId;

  Future<void> loadTargets() async {
    if (state.status == FiftyThirtyTwentyTargetsStatus.ready &&
        state.failure == null) {
      // Already loaded — no-op so dashboard mount doesn't spam the
      // profile repo on every visit.
      return;
    }
    emit(state.copyWith(status: FiftyThirtyTwentyTargetsStatus.loading));
    final result = await _getTargets(_userId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          failure: failure,
        ),
      ),
      (targets) => emit(
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: targets,
        ),
      ),
    );
  }

  /// Submits a new split. Optimistically swaps `state.targets` only on
  /// success — keeping a stale value mid-save means the dashboard never
  /// shows a transient invalid number to the user.
  Future<void> submitTargets(FiftyThirtyTwentyTargets next) async {
    emit(state.copyWith(status: FiftyThirtyTwentyTargetsStatus.saving));
    final result = await _updateTargets(userId: _userId, targets: next);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          failure: failure,
        ),
      ),
      (saved) => emit(
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: saved,
        ),
      ),
    );
  }
}

enum FiftyThirtyTwentyTargetsStatus { initial, loading, ready, saving }

class FiftyThirtyTwentyTargetsState extends Equatable {
  const FiftyThirtyTwentyTargetsState({
    required this.status,
    required this.targets,
    this.failure,
  });

  const FiftyThirtyTwentyTargetsState.initial()
    : status = FiftyThirtyTwentyTargetsStatus.initial,
      targets = FiftyThirtyTwentyTargets.classic,
      failure = null;

  final FiftyThirtyTwentyTargetsStatus status;

  /// Currently active targets. Defaults to the classic 50/30/20 until
  /// the first load completes — safe to read at any time.
  final FiftyThirtyTwentyTargets targets;

  /// Set when the last load/save failed. Cleared on the next successful
  /// op. Kept on the state (not emitted as a one-shot) so the targets
  /// editor can show an inline error message after a failed submit
  /// without needing a separate listener.
  final Failure? failure;

  FiftyThirtyTwentyTargetsState copyWith({
    FiftyThirtyTwentyTargetsStatus? status,
    FiftyThirtyTwentyTargets? targets,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return FiftyThirtyTwentyTargetsState(
      status: status ?? this.status,
      targets: targets ?? this.targets,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, targets, failure];
}
