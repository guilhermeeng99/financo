import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/usecases/get_institutions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped list of the user's custody institutions. Created by the shell
/// route; the institutions page refreshes it on mount. Mutations (create/
/// update/delete) are done by the form via the use cases, then `load` is called
/// again. See `docs/specs/institutions.md`.
class InstitutionsCubit extends Cubit<InstitutionsState> {
  InstitutionsCubit({
    required GetInstitutionsUseCase getInstitutions,
    required String userId,
  }) : _getInstitutions = getInstitutions,
       _userId = userId,
       super(const InstitutionsInitial());

  final GetInstitutionsUseCase _getInstitutions;
  final String _userId;

  Future<void> load({bool forceRefresh = false}) async {
    if (forceRefresh || state is! InstitutionsLoaded) {
      emit(const InstitutionsLoading());
    }
    final result = await _getInstitutions(
      userId: _userId,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(InstitutionsError(failure)),
      (institutions) => emit(InstitutionsLoaded(institutions)),
    );
  }
}

sealed class InstitutionsState extends Equatable {
  const InstitutionsState();

  @override
  List<Object?> get props => [];
}

final class InstitutionsInitial extends InstitutionsState {
  const InstitutionsInitial();
}

final class InstitutionsLoading extends InstitutionsState {
  const InstitutionsLoading();
}

final class InstitutionsLoaded extends InstitutionsState {
  const InstitutionsLoaded(this.institutions);

  final List<Institution> institutions;

  @override
  List<Object?> get props => [institutions];
}

final class InstitutionsError extends InstitutionsState {
  const InstitutionsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
