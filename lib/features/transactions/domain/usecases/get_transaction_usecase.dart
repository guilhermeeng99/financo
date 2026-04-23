import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionUseCase {
  const GetTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, TransactionEntity>> call(String id) =>
      _repository.getTransaction(id);
}
