import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

/// Scope passed to the bill form when editing a recurrent bill — picks
/// between updating only the chosen occurrence or also propagating the
/// edit to every later occurrence in the chain.
enum BillEditScope { onlyThis, alsoSubsequents }

class UpdateBillScopedUseCase {
  const UpdateBillScopedUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, BillEntity>> call({
    required BillEntity bill,
    required BillEditScope scope,
  }) {
    return switch (scope) {
      BillEditScope.onlyThis => _repository.updateBill(bill),
      BillEditScope.alsoSubsequents =>
        _repository.updateBillAndSubsequents(bill),
    };
  }
}
