import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFormCubit extends Cubit<CategoryFormState> {
  CategoryFormCubit({
    required CreateCategoryUseCase createCategory,
    required UpdateCategoryUseCase updateCategory,
    required String userId,
    CategoryEntity? existingCategory,
  }) : _createCategory = createCategory,
       _updateCategory = updateCategory,
       super(
         CategoryFormState.initial(
           userId: userId,
           existing: existingCategory,
         ),
       );

  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;

  void updateName(String value) => emit(state.copyWith(name: value));

  void updateType(CategoryType type) => emit(state.copyWith(type: type));

  void updateIcon(int icon) => emit(state.copyWith(icon: icon));

  void updateColor(int color) => emit(state.copyWith(color: color));

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormStatus.submitting));

    final category = CategoryEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      name: state.name,
      icon: state.icon,
      color: state.color,
      type: state.type,
      isDefault: false,
      sortOrder: 99,
    );

    (state.isEditing
            ? await _updateCategory(category)
            : await _createCategory(category))
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

class CategoryFormState extends Equatable {
  const CategoryFormState({
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.status,
    required this.isDefault,
    this.existingId,
    this.failure,
  });

  factory CategoryFormState.initial({
    required String userId,
    CategoryEntity? existing,
  }) {
    return CategoryFormState(
      userId: userId,
      name: existing?.name ?? '',
      type: existing?.type ?? CategoryType.expense,
      icon: existing?.icon ?? 58332,
      color: existing?.color ?? 4280391411,
      status: FormStatus.initial,
      existingId: existing?.id,
      isDefault: existing?.isDefault ?? false,
    );
  }

  final String userId;
  final String name;
  final CategoryType type;
  final int icon;
  final int color;
  final FormStatus status;
  final bool isDefault;
  final String? existingId;
  final Failure? failure;

  bool get isEditing => existingId != null;
  bool get isValid => name.isNotEmpty;

  CategoryFormState copyWith({
    String? name,
    CategoryType? type,
    int? icon,
    int? color,
    FormStatus? status,
    Failure? failure,
  }) {
    return CategoryFormState(
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
      existingId: existingId,
      isDefault: isDefault,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    type,
    icon,
    color,
    status,
    isDefault,
    existingId,
    failure,
  ];
}
