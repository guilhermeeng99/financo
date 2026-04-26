import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';

class GetBillsUseCase {
  const GetBillsUseCase(this._repository);

  final BillRepository _repository;

  Future<Either<Failure, List<BillEntity>>> call({
    required String userId,
    BillStatus? status,
    bool forceRefresh = false,
  }) => _repository.getBills(
    userId: userId,
    status: status,
    forceRefresh: forceRefresh,
  );
}
