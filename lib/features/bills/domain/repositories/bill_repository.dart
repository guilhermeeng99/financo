import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';

abstract class BillRepository {
  Future<Either<Failure, List<BillEntity>>> getBills({
    required String userId,
    BillStatus? status,
    bool forceRefresh = false,
  });

  Future<Either<Failure, BillEntity>> getBill(String id);

  Future<Either<Failure, BillEntity>> createBill(BillEntity bill);

  Future<Either<Failure, BillEntity>> updateBill(BillEntity bill);

  Future<Either<Failure, void>> deleteBill(String id);

  Future<Either<Failure, BillPaymentResult>> payBill({
    required String billId,
    required String accountId,
    required String categoryId,
  });
}
