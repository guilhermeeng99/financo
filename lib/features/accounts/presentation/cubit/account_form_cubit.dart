import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountFormCubit extends Cubit<AccountFormState> {
  AccountFormCubit({
    required CreateAccountUseCase createAccount,
    required UpdateAccountUseCase updateAccount,
    required String userId,
    AccountEntity? existingAccount,
  }) : _createAccount = createAccount,
       _updateAccount = updateAccount,
       super(
         AccountFormState.initial(
           userId: userId,
           existing: existingAccount,
         ),
       );

  final CreateAccountUseCase _createAccount;
  final UpdateAccountUseCase _updateAccount;

  void updateName(String value) => emit(state.copyWith(name: value));

  void updateType(AccountType type) => emit(state.copyWith(type: type));

  void updateBalance(String value) {
    // Accept both "-431,72" (BR) and "-431.72" (EN) — `double.tryParse`
    // alone rejects the comma decimal and the user's edit silently
    // becomes 0.
    final balance = parseDecimalAmount(value) ?? 0;
    emit(state.copyWith(balance: balance));
  }

  void updateCreditLimit(String value) {
    final limit = parseDecimalAmount(value) ?? 0;
    emit(state.copyWith(creditLimit: limit));
  }

  void updateClosingDay(int day) => emit(state.copyWith(closingDay: day));

  void updateDueDay(int day) => emit(state.copyWith(dueDay: day));

  void updateBank(BankType value) => emit(state.copyWith(bank: value));

  void updateLinkedAccountId(String value) =>
      emit(state.copyWith(linkedAccountId: value));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final account = AccountEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      name: state.name,
      type: state.type,
      bank: state.bank,
      initialBalance: state.balance,
      creditLimit: state.type == AccountType.creditCard
          ? state.creditLimit
          : null,
      closingDay: state.type == AccountType.creditCard
          ? state.closingDay
          : null,
      dueDay: state.type == AccountType.creditCard ? state.dueDay : null,
      linkedAccountId: state.type == AccountType.creditCard
          ? state.linkedAccountId
          : null,
      // Preserve original creation time on edit — overwriting with `now`
      // would rewrite the account's "added on" timestamp in Firestore
      // every time the user tweaks a field.
      createdAt: state.originalCreatedAt ?? DateTime.now(),
    );

    (state.isEditing
            ? await _updateAccount(account)
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
    required this.linkedAccountId,
    required this.status,
    this.existingId,
    this.originalCreatedAt,
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
      bank: existing?.bank ?? BankType.nubank,
      balance: existing?.initialBalance ?? 0,
      creditLimit: existing?.creditLimit ?? 0,
      closingDay: existing?.closingDay ?? 1,
      dueDay: existing?.dueDay ?? 10,
      linkedAccountId: existing?.linkedAccountId ?? '',
      status: FormStatus.initial,
      existingId: existing?.id,
      originalCreatedAt: existing?.createdAt,
    );
  }

  final String userId;
  final String name;
  final AccountType type;
  final BankType bank;
  final double balance;
  final double creditLimit;
  final int closingDay;
  final int dueDay;
  final String linkedAccountId;
  final FormStatus status;
  final String? existingId;

  /// Captured at form open time on edit so `submit` can preserve the
  /// account's original `createdAt`. `null` in create mode — submit
  /// falls back to `DateTime.now()`.
  final DateTime? originalCreatedAt;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isValid =>
      name.isNotEmpty &&
      (type != AccountType.creditCard || linkedAccountId.isNotEmpty);

  /// Type is locked once an account exists: flipping it would
  /// invalidate credit-card-only fields and the sign convention applied
  /// to every persisted transaction. The free checking ↔ investment
  /// swap that existed transiently to migrate legacy accounts was
  /// removed once the affected users had finished migrating.
  bool get canChangeType => !isEditing;

  AccountFormState copyWith({
    String? name,
    AccountType? type,
    BankType? bank,
    double? balance,
    double? creditLimit,
    int? closingDay,
    int? dueDay,
    String? linkedAccountId,
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
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      status: status ?? this.status,
      existingId: existingId,
      originalCreatedAt: originalCreatedAt,
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
    linkedAccountId,
    status,
    existingId,
    originalCreatedAt,
    failure,
  ];
}
