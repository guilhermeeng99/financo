import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/import_assets_csv_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped list of the user's investing assets. Created by the shell
/// route; the assets page refreshes it on mount. Mutations are done by the form
/// via the use cases, then `load` is called again. Also drives CSV import
/// (`previewCsv` / `confirmImport`). See `docs/specs/investing_assets.md` and
/// `docs/specs/investing_csv_import.md`.
class AssetsCubit extends Cubit<AssetsState> {
  AssetsCubit({
    required GetAssetsUseCase getAssets,
    required ImportAssetsCsvUseCase importAssetsCsv,
    required String userId,
  }) : _getAssets = getAssets,
       _importAssetsCsv = importAssetsCsv,
       _userId = userId,
       super(const AssetsInitial());

  final GetAssetsUseCase _getAssets;
  final ImportAssetsCsvUseCase _importAssetsCsv;
  final String _userId;

  Future<void> load({bool forceRefresh = false}) async {
    if (forceRefresh || state is! AssetsLoaded) {
      emit(const AssetsLoading());
    }
    final result = await _getAssets(
      userId: _userId,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(AssetsError(failure)),
      (assets) => emit(AssetsLoaded(assets)),
    );
  }

  Future<Either<Failure, AssetImportPreview>> previewCsv(String csvContent) {
    return _importAssetsCsv.preview(csvContent: csvContent, userId: _userId);
  }

  /// Confirms the import for the parsed preview [items]. Emits
  /// [AssetsImporting] per item for the progress UI, then refreshes to
  /// [AssetsLoaded], and
  /// **returns** the report so the preview page can pop with a summary. A
  /// failure emits [AssetsError] and returns a `Left`.
  Future<Either<Failure, AssetImportResult>> confirmImport({
    required List<AssetImportPreviewItem> items,
    int duplicateCount = 0,
  }) async {
    emit(AssetsImporting(processed: 0, total: items.length));

    final result = await _importAssetsCsv.importItems(
      items: items,
      userId: _userId,
      duplicateCount: duplicateCount,
      onProgress: (processed, total) {
        if (isClosed) return;
        emit(AssetsImporting(processed: processed, total: total));
      },
    );

    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      emit(AssetsError(failure));
      return Left(failure);
    }
    await load(forceRefresh: true);
    return result;
  }
}

sealed class AssetsState extends Equatable {
  const AssetsState();

  @override
  List<Object?> get props => [];
}

final class AssetsInitial extends AssetsState {
  const AssetsInitial();
}

final class AssetsLoading extends AssetsState {
  const AssetsLoading();
}

/// Active state during a confirmed CSV import — carries progress so the UI can
/// render a determinate bar.
final class AssetsImporting extends AssetsState {
  const AssetsImporting({required this.processed, required this.total});

  final int processed;
  final int total;

  double get progress => total == 0 ? 1 : processed / total;

  @override
  List<Object?> get props => [processed, total];
}

final class AssetsLoaded extends AssetsState {
  const AssetsLoaded(this.assets);

  final List<Asset> assets;

  @override
  List<Object?> get props => [assets];
}

final class AssetsError extends AssetsState {
  const AssetsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
