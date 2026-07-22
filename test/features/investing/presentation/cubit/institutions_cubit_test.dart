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
}
