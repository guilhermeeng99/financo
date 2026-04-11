import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountFormCubit extends Cubit<AccountFormState> {
  AccountFormCubit({
    required CreateAccountUseCase createAccount,
    required AccountRepository accountRepository,
    required String userId,
    AccountEntity? existingAccount,
  }) : _createAccount = createAccount,
       _accountRepo = accountRepository,
       super(
         AccountFormState.initial(
           userId: userId,
           existing: existingAccount,
         ),
       );

  final CreateAccountUseCase _createAccount;
  final AccountRepository _accountRepo;

  void updateName(String value) => emit(state.copyWith(name: value));

  void updateType(AccountType type) => emit(state.copyWith(type: type));

  void updateBalance(String value) {
    final balance = double.tryParse(value) ?? 0;
    emit(state.copyWith(balance: balance));
  }

  void updateCreditLimit(String value) {
    final limit = double.tryParse(value) ?? 0;
    emit(state.copyWith(creditLimit: limit));
  }

  void updateClosingDay(int day) => emit(state.copyWith(closingDay: day));

  void updateDueDay(int day) => emit(state.copyWith(dueDay: day));

  void updateBank(String value) => emit(state.copyWith(bank: value));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final account = AccountEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      name: state.name,
      type: state.type,
      bank: state.bank,
      balance: state.balance,
      creditLimit: state.type == AccountType.creditCard
          ? state.creditLimit
          : null,
      closingDay: state.type == AccountType.creditCard
          ? state.closingDay
          : null,
      dueDay: state.type == AccountType.creditCard ? state.dueDay : null,
      isActive: true,
      createdAt: DateTime.now(),
    );

    (state.isEditing
            ? await _accountRepo.updateAccount(account)
            : await _createAccount(account))
        .fold(
          (failure) => emit(
            state.copyWith(
              status: FormStatus.failure,
              failure: failure,
            ),
          ),
          (_) => emit(state.copyWith(status: FormStatus.success)),
        );
  }
}

class AccountFormState extends Equatable {
  const AccountFormState({
    required this.userId,
    required this.name,
    required this.type,
    required this.bank,
    required this.balance,
    required this.creditLimit,
    required this.closingDay,
    required this.dueDay,
    required this.status,
    this.existingId,
    this.failure,
  });

  factory AccountFormState.initial({
    required String userId,
    AccountEntity? existing,
  }) {
    return AccountFormState(
      userId: userId,
      name: existing?.name ?? '',
      type: existing?.type ?? AccountType.checking,
      bank: existing?.bank ?? '',
      balance: existing?.balance ?? 0,
      creditLimit: existing?.creditLimit ?? 0,
      closingDay: existing?.closingDay ?? 1,
      dueDay: existing?.dueDay ?? 10,
      status: FormStatus.initial,
      existingId: existing?.id,
    );
  }

  final String userId;
  final String name;
  final AccountType type;
  final String bank;
  final double balance;
  final double creditLimit;
  final int closingDay;
  final int dueDay;
  final FormStatus status;
  final String? existingId;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isValid => name.isNotEmpty;

  AccountFormState copyWith({
    String? name,
    AccountType? type,
    String? bank,
    double? balance,
    double? creditLimit,
    int? closingDay,
    int? dueDay,
    FormStatus? status,
    Failure? failure,
  }) {
    return AccountFormState(
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      status: status ?? this.status,
      existingId: existingId,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    type,
    bank,
    balance,
    creditLimit,
    closingDay,
    dueDay,
    status,
    existingId,
    failure,
  ];
}
