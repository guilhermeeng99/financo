import 'package:equatable/equatable.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// A pending bill paired with one or more transactions that look like
/// they could be its settlement (same category, amount, day, type).
///
/// Produced by `FindBillMatchCandidatesUseCase` and consumed by the
/// match-suggestion banner / sheet on the BillsPage. The user resolves
/// each `(bill, transaction)` pair as accept (link) or reject (dismiss).
class BillMatchCandidate extends Equatable {
  const BillMatchCandidate({
    required this.bill,
    required this.candidates,
  });

  final BillEntity bill;
  final List<TransactionEntity> candidates;

  @override
  List<Object?> get props => [bill, candidates];
}
