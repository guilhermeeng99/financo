import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/create_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_scoped_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum BillFormStatus { initial, submitting, success, failure }

class BillFormCubit extends Cubit<BillFormState> {
  BillFormCubit({
    required CreateBillUseCase createBill,
    required UpdateBillScopedUseCase updateBillScoped,
    required String userId,
    BillEntity? existingBill,
  }) : _createBill = createBill,
       _updateBillScoped = updateBillScoped,
       super(BillFormState.initial(userId: userId, existing: existingBill));

  final CreateBillUseCase _createBill;
  final UpdateBillScopedUseCase _updateBillScoped;

  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void updateAmount(String value) {
    // Accept both BR (`421,95`) and EN (`421.95`) decimal styles. Negative
    // values flow through and are caught by validation (amount must be >
    // 0) — silently `.abs()`'ing them would mask user typos.
    final amount = parseDecimalAmount(value) ?? 0;
    emit(state.copyWith(amount: amount));
  }

  void updateDueDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(dueDate: dateOnly));
  }

  void updateRecurrence(BillRecurrence recurrence) {
    if (state.isEditing) return; // immutable after creation
    emit(state.copyWith(recurrence: recurrence));
  }

  void updateType(BillType type) {
    if (state.isEditing) return; // immutable after creation
    if (state.type == type) return;
    // Switching type invalidates any previously chosen category (which was
    // bound to the old category type).
    emit(state.copyWith(type: type, clearCategory: true));
  }

  void updateCategoryId(String? id) =>
      emit(state.copyWith(categoryId: id, clearCategory: id == null));

  void updateNotes(String value) => emit(state.copyWith(notes: value));

  /// Submits the form. For new bills `scope` is ignored; for edits on
  /// monthly bills the page is expected to ask the user first and pass
  /// the chosen scope. One-shot edits always behave as `onlyThis`.
  Future<void> submit({
    BillEditScope scope = BillEditScope.onlyThis,
  }) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: BillFormStatus.submitting));

    final now = DateTime.now();
    final bill = BillEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      type: state.type,
      description: state.description.trim(),
      amount: state.amount,
      dueDate: state.dueDate,
      status: state.existingStatus ?? BillStatus.pending,
      recurrence: state.recurrence,
      categoryId: state.categoryId,
      notes: state.notes.isEmpty ? null : state.notes,
      paidAt: state.existingPaidAt,
      paidTransactionId: state.existingPaidTransactionId,
      parentBillId: state.existingParentBillId,
      createdAt: state.existingCreatedAt ?? now,
      updatedAt: now,
    );

    (state.isEditing
            ? await _updateBillScoped(bill: bill, scope: scope)
            : await _createBill(bill))
        .fold(
          (failure) => emit(
            state.copyWith(
              status: BillFormStatus.failure,
              failure: failure,
            ),
          ),
          (_) => emit(state.copyWith(status: BillFormStatus.success)),
        );
  }
}

class BillFormState extends Equatable {
  const BillFormState({
    required this.userId,
    required this.type,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.recurrence,
    required this.notes,
    required this.status,
    this.categoryId,
    this.existingId,
    this.existingStatus,
    this.existingPaidAt,
    this.existingPaidTransactionId,
    this.existingParentBillId,
    this.existingCreatedAt,
    this.failure,
  });

  factory BillFormState.initial({
    required String userId,
    BillEntity? existing,
  }) {
    final today = DateTime.now();
    return BillFormState(
      userId: userId,
      type: existing?.type ?? BillType.payable,
      description: existing?.description ?? '',
      amount: existing?.amount ?? 0,
      dueDate:
          existing?.dueDate ?? DateTime(today.year, today.month, today.day),
      recurrence: existing?.recurrence ?? BillRecurrence.oneShot,
      notes: existing?.notes ?? '',
      categoryId: existing?.categoryId,
      status: BillFormStatus.initial,
      existingId: existing?.id,
      existingStatus: existing?.status,
      existingPaidAt: existing?.paidAt,
      existingPaidTransactionId: existing?.paidTransactionId,
      existingParentBillId: existing?.parentBillId,
      existingCreatedAt: existing?.createdAt,
    );
  }

  final String userId;
  final BillType type;
  final String description;
  final double amount;
  final DateTime dueDate;
  final BillRecurrence recurrence;
  final String? categoryId;
  final String notes;
  final BillFormStatus status;
  final String? existingId;
  final BillStatus? existingStatus;
  final DateTime? existingPaidAt;
  final String? existingPaidTransactionId;
  final String? existingParentBillId;
  final DateTime? existingCreatedAt;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isPaid => existingStatus == BillStatus.paid;

  bool get isValid {
    // Description is intentionally not validated — matches transactions
    // (the bills list / match sheet show a type-based fallback when
    // empty). See `docs/specs/bills.md` → Business Rules.
    if (amount <= 0) return false;
    if (categoryId == null) return false;
    if (isEditing && isPaid) return false;
    return true;
  }

  BillFormState copyWith({
    BillType? type,
    String? description,
    double? amount,
    DateTime? dueDate,
    BillRecurrence? recurrence,
    String? categoryId,
    bool clearCategory = false,
    String? notes,
    BillFormStatus? status,
    Failure? failure,
  }) {
    return BillFormState(
      userId: userId,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      notes: notes ?? this.notes,
      status: status ?? this.status,
      existingId: existingId,
      existingStatus: existingStatus,
      existingPaidAt: existingPaidAt,
      existingPaidTransactionId: existingPaidTransactionId,
      existingParentBillId: existingParentBillId,
      existingCreatedAt: existingCreatedAt,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    type,
    description,
    amount,
    dueDate,
    recurrence,
    categoryId,
    notes,
    status,
    existingId,
    existingStatus,
    existingPaidAt,
    existingPaidTransactionId,
    existingParentBillId,
    existingCreatedAt,
    failure,
  ];
}
