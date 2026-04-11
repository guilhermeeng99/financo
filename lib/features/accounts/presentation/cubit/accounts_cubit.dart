import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit({
    required GetAccountsUseCase getAccounts,
    required String userId,
  }) : _getAccounts = getAccounts,
       _userId = userId,
       super(const AccountsInitial());

  final GetAccountsUseCase _getAccounts;
  final String _userId;

  Future<void> loadAccounts({bool forceRefresh = false}) async {
    if (state is AccountsLoaded && !forceRefresh) return;
    emit(const AccountsLoading());

    final result = await _getAccounts(
      userId: _userId,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => emit(AccountsError(failure)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }
}

sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

final class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

final class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

final class AccountsLoaded extends AccountsState {
  const AccountsLoaded(this.accounts);

  final List<AccountEntity> accounts;

  @override
  List<Object> get props => [accounts];
}

final class AccountsError extends AccountsState {
  const AccountsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
