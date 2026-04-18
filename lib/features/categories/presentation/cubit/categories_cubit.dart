import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({
    required GetCategoriesUseCase getCategories,
    required ImportCategoriesCsvUseCase importCategoriesCsv,
    required String userId,
  }) : _getCategories = getCategories,
       _importCategoriesCsv = importCategoriesCsv,
       _userId = userId,
       super(const CategoriesInitial());

  final GetCategoriesUseCase _getCategories;
  final ImportCategoriesCsvUseCase _importCategoriesCsv;
  final String _userId;

  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (forceRefresh || state is! CategoriesLoaded) {
      emit(const CategoriesLoading());
    }

    final result = await _getCategories(
      userId: _userId,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => emit(CategoriesError(failure)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<Either<Failure, CategoryImportPreview>> previewCsv(
    String csvContent,
  ) {
    return _importCategoriesCsv.preview(
      csvContent: csvContent,
      userId: _userId,
    );
  }

  Future<void> importCsv(String csvContent) async {
    emit(const CategoriesLoading());

    final result = await _importCategoriesCsv(
      csvContent: csvContent,
      userId: _userId,
    );

    await result.fold(
      (failure) async => emit(CategoriesError(failure)),
      (importResult) async {
        final refreshResult = await _getCategories(
          userId: _userId,
          forceRefresh: true,
        );
        refreshResult.fold(
          (failure) => emit(CategoriesError(failure)),
          (categories) => emit(
            CategoriesImported(
              categories: categories,
              importedCount: importResult.importedCount,
              duplicateCount: importResult.duplicateCount,
            ),
          ),
        );
      },
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

final class CategoriesImported extends CategoriesState {
  const CategoriesImported({
    required this.categories,
    required this.importedCount,
    required this.duplicateCount,
  });

  final List<CategoryEntity> categories;
  final int importedCount;
  final int duplicateCount;

  @override
  List<Object> get props => [categories, importedCount, duplicateCount];
}
