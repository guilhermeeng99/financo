import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

class UpdateBillUseCase {
  const UpdateBillUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, BillEntity>> call(BillEntity bill) =>
      _repository.updateBill(bill);
}
