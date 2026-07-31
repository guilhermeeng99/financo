import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/presentation/cubit/institutions_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetInstitutionsUseCase getInstitutions;

  setUp(() => getInstitutions = MockGetInstitutionsUseCase());

  blocTest<InstitutionsCubit, InstitutionsState>(
    'emits [Loading, Loaded] when the load succeeds',
    build: () {
      when(() => getInstitutions(userId: 'user-1')).thenAnswer(
        (_) async => Right([InstitutionFactory.nubank()]),
      );
      return InstitutionsCubit(
        getInstitutions: getInstitutions,
        userId: 'user-1',
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InstitutionsLoading(),
      InstitutionsLoaded([InstitutionFactory.nubank()]),
    ],
  );

  blocTest<InstitutionsCubit, InstitutionsState>(
    'emits [Loading, Error] when the load fails',
    build: () {
      when(
        () => getInstitutions(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return InstitutionsCubit(
        getInstitutions: getInstitutions,
        userId: 'user-1',
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InstitutionsLoading(),
      const InstitutionsError(ServerFailure()),
    ],
  );

  // NOTE: this cubit has no `previewCsv`/`confirmImport` — institutions are
  // created on the fly by the *asset* CSV import, not imported directly. What
  // is worth pinning instead is the cache-first refresh below.
  blocTest<InstitutionsCubit, InstitutionsState>(
    'skips the Loading state when refreshing an already-loaded list',
    build: () {
      when(() => getInstitutions(userId: 'user-1')).thenAnswer(
        (_) async =>
            Right([InstitutionFactory.nubank(), InstitutionFactory.avenue()]),
      );
      return InstitutionsCubit(
        getInstitutions: getInstitutions,
        userId: 'user-1',
      );
    },
    seed: () => InstitutionsLoaded([InstitutionFactory.nubank()]),
    act: (cubit) => cubit.load(),
    // The page calls load() on every mount; emitting Loading would flash a
    // spinner over a list the user is already looking at.
    expect: () => [
      InstitutionsLoaded([
        InstitutionFactory.nubank(),
        InstitutionFactory.avenue(),
      ]),
    ],
  );

  blocTest<InstitutionsCubit, InstitutionsState>(
    'forceRefresh shows Loading even when already loaded',
    build: () {
      when(
        () => getInstitutions(userId: 'user-1', forceRefresh: true),
      ).thenAnswer((_) async => Right([InstitutionFactory.avenue()]));
      return InstitutionsCubit(
        getInstitutions: getInstitutions,
        userId: 'user-1',
      );
    },
    seed: () => InstitutionsLoaded([InstitutionFactory.nubank()]),
    act: (cubit) => cubit.load(forceRefresh: true),
    expect: () => [
      const InstitutionsLoading(),
      InstitutionsLoaded([InstitutionFactory.avenue()]),
    ],
  );
}
