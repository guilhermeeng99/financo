import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_class_usecase.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_class_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Default icon for a freshly-created asset class — Material's
/// `savings` glyph, which the category picker also offers. The
/// picker stores code points from the `MaterialIcons` font, so the
/// default has to be a Material code point too (FontAwesome code
/// points render as the wrong glyph against the Material font).
final int _defaultIcon = Icons.savings.codePoint;

class AssetClassFormCubit extends Cubit<AssetClassFormState> {
  AssetClassFormCubit({
    required CreateAssetClassUseCase createAssetClass,
    required UpdateAssetClassUseCase updateAssetClass,
    required String userId,
    AssetClassEntity? existingAssetClass,
    int existingClassCount = 0,
    String? presetParentId,
    int? presetParentIcon,
    int? presetParentColor,
  }) : _create = createAssetClass,
       _update = updateAssetClass,
       super(
         AssetClassFormState.initial(
           userId: userId,
           existing: existingAssetClass,
           existingClassCount: existingClassCount,
           presetParentId: presetParentId,
           presetParentIcon: presetParentIcon,
           presetParentColor: presetParentColor,
         ),
       );

  final CreateAssetClassUseCase _create;
  final UpdateAssetClassUseCase _update;

  void updateName(String value) => emit(state.copyWith(name: value));

  /// Icon picker is hidden for subclasses (they inherit from the
  /// parent), so this only fires on root edits.
  void updateIcon(int icon) => emit(state.copyWith(icon: icon));

  void updateColor(int color) => emit(state.copyWith(color: color));

  void updateTargetPercent(double value) =>
      emit(state.copyWith(targetPercent: value.clamp(0, 100)));

  /// `parent == null` clears the parent (promote to root). Picking a
  /// parent mirrors its icon + color into the form so the user sees
  /// the inherited appearance before saving.
  void updateParent(AssetClassEntity? parent) {
    if (parent == null) {
      emit(state.copyWith(clearParentId: true));
      return;
    }
    emit(
      state.copyWith(
        parentId: parent.id,
        icon: parent.icon,
        color: parent.color,
      ),
    );
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormStatus.submitting));

    // Both roots and subclasses now carry a user-defined target. For
    // roots it is share of total portfolio; for subclasses it is
    // share of the parent class's allocation.
    final entity = AssetClassEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      name: state.name.trim(),
      icon: state.icon,
      color: state.color,
      targetPercent: state.targetPercent,
      parentId: state.parentId,
      createdAt: state.createdAt,
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

class AssetClassFormState extends Equatable {
  const AssetClassFormState({
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetPercent,
    required this.createdAt,
    required this.status,
    this.existingId,
    this.parentId,
    this.failure,
  });

  factory AssetClassFormState.initial({
    required String userId,
    AssetClassEntity? existing,
    int existingClassCount = 0,
    String? presetParentId,
    int? presetParentIcon,
    int? presetParentColor,
  }) {
    final resolvedParentId = existing?.parentId ?? presetParentId;
    return AssetClassFormState(
      userId: userId,
      name: existing?.name ?? '',
      // When pre-creating a subclass, the page passes the parent's
      // icon/color so the form mirrors the parent immediately.
      icon: existing?.icon ?? presetParentIcon ?? _defaultIcon,
      color: existing?.color ??
          presetParentColor ??
          CategoryColors.forIndex(existingClassCount),
      targetPercent: existing?.targetPercent ?? 0,
      createdAt: existing?.createdAt ?? DateTime.now(),
      status: FormStatus.initial,
      existingId: existing?.id,
      parentId: resolvedParentId,
    );
  }

  final String userId;
  final String name;
  final int icon;
  final int color;
  final double targetPercent;
  final DateTime createdAt;
  final FormStatus status;
  final String? existingId;
  final String? parentId;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isSubclass => parentId != null;
  bool get isValid {
    if (name.trim().isEmpty) return false;
    return targetPercent >= 0 && targetPercent <= 100;
  }

  AssetClassFormState copyWith({
    String? name,
    int? icon,
    int? color,
    double? targetPercent,
    String? parentId,
    bool clearParentId = false,
    FormStatus? status,
    Failure? failure,
  }) {
    return AssetClassFormState(
      userId: userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetPercent: targetPercent ?? this.targetPercent,
      createdAt: createdAt,
      status: status ?? this.status,
      existingId: existingId,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    icon,
    color,
    targetPercent,
    createdAt,
    status,
    existingId,
    parentId,
    failure,
  ];
}
