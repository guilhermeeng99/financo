import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

class RejectBillMatchUseCase {
  const RejectBillMatchUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, BillEntity>> call({
    required String billId,
    required String transactionId,
  }) =>
      _repository.rejectBillTransactionMatch(
        billId: billId,
        transactionId: transactionId,
      );
}
