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

    await _emitImportResult(result);
  }

  /// Confirms the import for the (possibly user-edited) preview items.
  /// Used by the import-categories page after the user reviews/edits the
  /// parsed CSV preview.
  ///
  /// Emits [CategoriesImporting] for each item processed so the UI can show
  /// a determinate progress bar; on completion transitions to
  /// [CategoriesImported] (or [CategoriesError] on failure).
  Future<void> confirmImport({
    required List<CategoryImportPreviewItem> items,
    int duplicateCount = 0,
  }) async {
    emit(CategoriesImporting(processed: 0, total: items.length));

    final result = await _importCategoriesCsv.importItems(
      items: items,
      userId: _userId,
      duplicateCount: duplicateCount,
      onProgress: (processed, total) {
        if (isClosed) return;
        emit(CategoriesImporting(processed: processed, total: total));
      },
    );

    await _emitImportResult(result);
  }

  Future<void> _emitImportResult(
    Either<Failure, CategoryImportResult> result,
  ) async {
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

/// Active state during a confirmed CSV import. Carries the number of items
/// already processed and the total so the UI can render a determinate
/// progress bar instead of a plain spinner.
final class CategoriesImporting extends CategoriesState {
  const CategoriesImporting({required this.processed, required this.total});

  final int processed;
  final int total;

  double get progress => total == 0 ? 1 : processed / total;

  @override
  List<Object> get props => [processed, total];
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

extension CategoriesStateData on CategoriesState {
  /// Returns the categories carried by states that have a list (Loaded
  /// and Imported), or an empty list otherwise. Use this everywhere the
  /// caller "just wants the categories" — `is CategoriesLoaded` alone
  /// drops the post-import list and silently breaks lookups.
  List<CategoryEntity> get categoriesOrEmpty => switch (this) {
        CategoriesLoaded(:final categories) => categories,
        CategoriesImported(:final categories) => categories,
        _ => const <CategoryEntity>[],
      };
}
