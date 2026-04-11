import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required CreateTransactionUseCase createTransaction,
    required UpdateTransactionUseCase updateTransaction,
    required String userId,
    TransactionEntity? existingTransaction,
  }) : _createTransaction = createTransaction,
       _updateTransaction = updateTransaction,
       super(
         TransactionFormState.initial(
           userId: userId,
           existing: existingTransaction,
         ),
       );

  final CreateTransactionUseCase _createTransaction;
  final UpdateTransactionUseCase _updateTransaction;

  void updateType(TransactionType type) => emit(state.copyWith(type: type));

  void updateAmount(String value) {
    final amount = double.tryParse(value) ?? 0;
    emit(state.copyWith(amount: amount));
  }

  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));

  void updateAccountId(String id) => emit(state.copyWith(accountId: id));

  void updateCategoryId(String id) => emit(state.copyWith(categoryId: id));

  void updateNotes(String value) => emit(state.copyWith(notes: value));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final transaction = TransactionEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      accountId: state.accountId,
      categoryId: state.categoryId,
      type: state.type,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      isReconciled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    (state.isEditing
            ? await _updateTransaction(transaction)
            : await _createTransaction(transaction))
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

enum FormStatus { initial, submitting, success, failure }

class TransactionFormState extends Equatable {
  const TransactionFormState({
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.accountId,
    required this.categoryId,
    required this.notes,
    required this.status,
    this.existingId,
    this.failure,
  });

  factory TransactionFormState.initial({
    required String userId,
    TransactionEntity? existing,
  }) {
    return TransactionFormState(
      userId: userId,
      type: existing?.type ?? TransactionType.expense,
      amount: existing?.amount ?? 0,
      description: existing?.description ?? '',
      date: existing?.date ?? DateTime.now(),
      accountId: existing?.accountId ?? '',
      categoryId: existing?.categoryId ?? '',
      notes: existing?.notes ?? '',
      status: FormStatus.initial,
      existingId: existing?.id,
    );
  }

  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final String accountId;
  final String categoryId;
  final String notes;
  final FormStatus status;
  final String? existingId;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isValid =>
      description.isNotEmpty &&
      amount > 0 &&
      accountId.isNotEmpty &&
      categoryId.isNotEmpty;

  TransactionFormState copyWith({
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    String? accountId,
    String? categoryId,
    String? notes,
    FormStatus? status,
    Failure? failure,
  }) {
    return TransactionFormState(
      userId: userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      existingId: existingId,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    type,
    amount,
    description,
    date,
    accountId,
    categoryId,
    notes,
    status,
    existingId,
    failure,
  ];
}
