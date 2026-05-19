import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_holding_usecase.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_holding_usecase.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetHoldingFormCubit extends Cubit<AssetHoldingFormState> {
  AssetHoldingFormCubit({
    required CreateAssetHoldingUseCase createAssetHolding,
    required UpdateAssetHoldingUseCase updateAssetHolding,
    required String userId,
    required double availableForAccount,
    AssetHoldingEntity? existingHolding,
    String? presetAccountId,
    String? presetClassId,
  }) : _create = createAssetHolding,
       _update = updateAssetHolding,
       super(
         AssetHoldingFormState.initial(
           userId: userId,
           existing: existingHolding,
           presetAccountId: presetAccountId,
           presetClassId: presetClassId,
           availableForAccount: availableForAccount,
         ),
       );

  final CreateAssetHoldingUseCase _create;
  final UpdateAssetHoldingUseCase _update;

  void updateAccount(String accountId, {required double newAvailable}) {
    emit(
      state.copyWith(
        accountId: accountId,
        availableForAccount: newAvailable,
      ),
    );
  }

  void updateAssetClass(String classId) =>
      emit(state.copyWith(assetClassId: classId));

  void updateAmount(double amount) =>
      emit(state.copyWith(amount: amount < 0 ? 0 : amount));

  void updateNotes(String value) =>
      emit(state.copyWith(notes: value, clearNotes: value.isEmpty));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final entity = AssetHoldingEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      accountId: state.accountId,
      assetClassId: state.assetClassId,
      amount: state.amount,
      notes: state.notes,
      updatedAt: DateTime.now(),
    );

    (state.isEditing
            ? await _update(entity)
            : await _create(entity))
        .fold(
          (failure) => emit(
            state.copyWith(status: FormStatus.failure, failure: failure),
          ),
          (_) => emit(state.copyWith(status: FormStatus.success)),
        );
  }
}

class AssetHoldingFormState extends Equatable {
  const AssetHoldingFormState({
    required this.userId,
    required this.accountId,
    required this.assetClassId,
    required this.amount,
    required this.availableForAccount,
    required this.status,
    this.notes,
    this.existingId,
    this.failure,
  });

  factory AssetHoldingFormState.initial({
    required String userId,
    required double availableForAccount,
    AssetHoldingEntity? existing,
    String? presetAccountId,
    String? presetClassId,
  }) {
    return AssetHoldingFormState(
      userId: userId,
      accountId: existing?.accountId ?? presetAccountId ?? '',
      assetClassId: existing?.assetClassId ?? presetClassId ?? '',
      amount: existing?.amount ?? 0,
      notes: existing?.notes,
      availableForAccount: availableForAccount,
      status: FormStatus.initial,
      existingId: existing?.id,
    );
  }

  final String userId;
  final String accountId;
  final String assetClassId;
  final double amount;
  final String? notes;

  /// Remaining unallocated balance on the selected account (excludes
  /// this holding's current amount when editing). Recomputed by the
  /// page every time the account picker changes.
  final double availableForAccount;

  final FormStatus status;
  final String? existingId;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isValid =>
      accountId.isNotEmpty &&
      assetClassId.isNotEmpty &&
      amount >= 0 &&
      amount <= availableForAccount + 0.005;

  AssetHoldingFormState copyWith({
    String? accountId,
    String? assetClassId,
    double? amount,
    String? notes,
    bool clearNotes = false,
    double? availableForAccount,
    FormStatus? status,
    Failure? failure,
  }) {
    return AssetHoldingFormState(
      userId: userId,
      accountId: accountId ?? this.accountId,
      assetClassId: assetClassId ?? this.assetClassId,
      amount: amount ?? this.amount,
      notes: clearNotes ? null : (notes ?? this.notes),
      availableForAccount: availableForAccount ?? this.availableForAccount,
      status: status ?? this.status,
      existingId: existingId,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    accountId,
    assetClassId,
    amount,
    notes,
    availableForAccount,
    status,
    existingId,
    failure,
  ];
}
