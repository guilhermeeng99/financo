import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

class LinkBillToTransactionUseCase {
  const LinkBillToTransactionUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, BillPaymentResult>> call({
    required String billId,
    required String transactionId,
  }) =>
      _repository.linkBillToExistingTransaction(
        billId: billId,
        transactionId: transactionId,
      );
}
