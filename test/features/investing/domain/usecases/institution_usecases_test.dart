import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/usecases/create_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/update_institution_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(InstitutionFactory.nubank());
  });

  late MockInstitutionRepository institutions;
  late MockAssetRepository assets;
  late MockAssetTransactionRepository transactions;

  setUp(() {
    institutions = MockInstitutionRepository();
    assets = MockAssetRepository();
    transactions = MockAssetTransactionRepository();
  });

  group('CreateInstitutionUseCase', () {
    late CreateInstitutionUseCase useCase;
    setUp(() => useCase = CreateInstitutionUseCase(institutions));

    test('rejects a blank name', () async {
      final result = await useCase(
        InstitutionFactory.nubank(name: '   '),
      );
      expect(result, isA<Left<Failure, Institution>>());
      result.leftMap((f) => expect(f, isA<EmptyNameFailure>()));
    });

    test('rejects a duplicate name (case-insensitive)', () async {
      when(() => institutions.getInstitutions(userId: 'user-1')).thenAnswer(
        (_) async => Right([InstitutionFactory.nubank()]),
      );
      final result = await useCase(
        InstitutionFactory.avenue(id: 'other', name: 'nubank'),
      );
      result.leftMap((f) => expect(f, isA<DuplicateInstitutionNameFailure>()));
      expect(result.isLeft(), isTrue);
      verifyNever(() => institutions.createInstitution(any()));
    });

    test('creates when the name is unique, trimming it', () async {
      when(
        () => institutions.getInstitutions(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([]));
      when(() => institutions.createInstitution(any())).thenAnswer(
        (invocation) async =>
            Right(invocation.positionalArguments.first as Institution),
      );

      final result = await useCase(InstitutionFactory.nubank(name: '  Inter '));

      expect(result.isRight(), isTrue);
      final captured =
          verify(
                () => institutions.createInstitution(captureAny()),
              ).captured.single
              as Institution;
      expect(captured.name, 'Inter');
    });
  });

  group('UpdateInstitutionUseCase', () {
    late UpdateInstitutionUseCase useCase;
    setUp(() => useCase = UpdateInstitutionUseCase(institutions));

    test('allows keeping the same name on the edited institution', () async {
      final self = InstitutionFactory.nubank();
      when(
        () => institutions.getInstitutions(userId: 'user-1'),
      ).thenAnswer((_) async => Right([self]));
      when(
        () => institutions.updateInstitution(any()),
      ).thenAnswer((_) async => Right(self));

      final result = await useCase(self);
      expect(result.isRight(), isTrue);
    });
  });

  group('DeleteInstitutionUseCase', () {
    late DeleteInstitutionUseCase useCase;
    setUp(
      () => useCase = DeleteInstitutionUseCase(
        institutionRepository: institutions,
        assetRepository: assets,
        transactionRepository: transactions,
      ),
    );

    test('blocks deletion when an asset references it', () async {
      when(() => assets.getAssets(userId: 'user-1')).thenAnswer(
        (_) async => Right([AssetFactory.stockBr()]),
      );
      when(
        () => transactions.getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase(InstitutionFactory.nubank());
      result.leftMap((f) => expect(f, isA<InstitutionInUseFailure>()));
      expect(result.isLeft(), isTrue);
      verifyNever(() => institutions.deleteInstitution(any()));
    });

    test('deletes when nothing references it', () async {
      when(
        () => assets.getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => transactions.getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => institutions.deleteInstitution('inst-nubank'),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(InstitutionFactory.nubank());
      expect(result.isRight(), isTrue);
      verify(() => institutions.deleteInstitution('inst-nubank')).called(1);
    });
  });
}
