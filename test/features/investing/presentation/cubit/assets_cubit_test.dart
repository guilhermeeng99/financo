import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/presentation/cubit/assets_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAssetsUseCase getAssets;

  setUp(() => getAssets = MockGetAssetsUseCase());

  blocTest<AssetsCubit, AssetsState>(
    'emits [Loading, Loaded] when the load succeeds',
    build: () {
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
      return AssetsCubit(getAssets: getAssets, userId: 'user-1');
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const AssetsLoading(),
      AssetsLoaded([AssetFactory.stockUs()]),
    ],
  );

  blocTest<AssetsCubit, AssetsState>(
    'emits [Loading, Error] when the load fails',
    build: () {
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return AssetsCubit(getAssets: getAssets, userId: 'user-1');
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const AssetsLoading(),
      const AssetsError(ServerFailure()),
    ],
  );
}
