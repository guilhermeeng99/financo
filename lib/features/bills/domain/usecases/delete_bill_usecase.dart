import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

class DeleteBillUseCase {
  const DeleteBillUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteBill(id);
}
