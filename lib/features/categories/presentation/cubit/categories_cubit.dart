import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({
    required GetCategoriesUseCase getCategories,
    required String userId,
  }) : _getCategories = getCategories,
       _userId = userId,
       super(const CategoriesInitial());

  final GetCategoriesUseCase _getCategories;
  final String _userId;

  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (state is CategoriesLoaded && !forceRefresh) return;
    emit(const CategoriesLoading());

    final result = await _getCategories(
      userId: _userId,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => emit(CategoriesError(failure)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<CategoryEntity> categories;

  @override
  List<Object> get props => [categories];
}

final class CategoriesError extends CategoriesState {
  const CategoriesError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
