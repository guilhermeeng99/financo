import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

class PayBillUseCase {
  const PayBillUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, BillPaymentResult>> call({
    required String billId,
    required String accountId,
    required String categoryId,
  }) => _repository.payBill(
    billId: billId,
    accountId: accountId,
    categoryId: categoryId,
  );
}
