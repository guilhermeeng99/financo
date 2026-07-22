import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session-scoped list of the user's investing assets. Created by the shell
/// route; the assets page refreshes it on mount. Mutations are done by the form
/// via the use cases, then `load` is called again. See
/// `docs/specs/investing_assets.md`.
class AssetsCubit extends Cubit<AssetsState> {
  AssetsCubit({required GetAssetsUseCase getAssets, required String userId})
    : _getAssets = getAssets,
      _userId = userId,
      super(const AssetsInitial());

  final GetAssetsUseCase _getAssets;
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
