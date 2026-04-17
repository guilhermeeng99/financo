import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required CreateTransactionUseCase createTransaction,
    required UpdateTransactionUseCase updateTransaction,
    required CreateTransferUseCase createTransfer,
    required String userId,
    TransactionEntity? existingTransaction,
  }) : _createTransaction = createTransaction,
       _updateTransaction = updateTransaction,
       _createTransfer = createTransfer,
       super(
         TransactionFormState.initial(
           userId: userId,
           existing: existingTransaction,
         ),
       );

  final CreateTransactionUseCase _createTransaction;
  final UpdateTransactionUseCase _updateTransaction;
  final CreateTransferUseCase _createTransfer;

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

  void updateDestinationAccountId(String id) =>
      emit(state.copyWith(destinationAccountId: id));

  void updateNotes(String value) => emit(state.copyWith(notes: value));

  void setTransferMode({required bool enabled}) =>
      emit(state.copyWith(isTransfer: enabled));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    if (state.isTransfer && !state.isEditing) {
      await _submitTransfer();
    } else {
      await _submitTransaction();
    }
  }

  Future<void> _submitTransaction() async {
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
      linkedTransactionId: state.linkedTransactionId,
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

  Future<void> _submitTransfer() async {
    final now = DateTime.now();
    final expense = TransactionEntity(
      id: '',
      userId: state.userId,
      accountId: state.accountId,
      categoryId: '',
      type: TransactionType.expense,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      createdAt: now,
      updatedAt: now,
    );
    final income = TransactionEntity(
      id: '',
      userId: state.userId,
      accountId: state.destinationAccountId,
      categoryId: '',
      type: TransactionType.income,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      createdAt: now,
      updatedAt: now,
    );

    (await _createTransfer(expense: expense, income: income)).fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.failure, failure: failure),
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
    required this.isTransfer,
    this.destinationAccountId = '',
    this.existingId,
    this.linkedTransactionId,
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
      isTransfer: existing?.isTransfer ?? false,
      existingId: existing?.id,
      linkedTransactionId: existing?.linkedTransactionId,
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
  final bool isTransfer;
  final String destinationAccountId;
  final String? existingId;
  final String? linkedTransactionId;
  final Failure? failure;

  bool get isEditing => existingId != null;

  bool get _isDateValid {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return !date.isAfter(endOfToday);
  }

  bool get isValid {
    if (amount <= 0 || !_isDateValid || accountId.isEmpty) return false;

    if (isTransfer) {
      return destinationAccountId.isNotEmpty &&
          accountId != destinationAccountId;
    }

    return categoryId.isNotEmpty;
  }

  TransactionFormState copyWith({
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    String? accountId,
    String? categoryId,
    String? destinationAccountId,
    String? notes,
    FormStatus? status,
    bool? isTransfer,
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
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      isTransfer: isTransfer ?? this.isTransfer,
      existingId: existingId,
      linkedTransactionId: linkedTransactionId,
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
    destinationAccountId,
    notes,
    status,
    isTransfer,
    existingId,
    linkedTransactionId,
    failure,
  ];
}
