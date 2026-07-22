import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';

/// A source of economic index series (CDI/Selic/IPCA) for fixed-income accrual.
/// See `docs/specs/quotes.md`.
abstract class IndexDataSource {
  /// Series for [index] from [from] (inclusive) to today, oldest first.
  Future<Either<Failure, List<IndexPoint>>> series(
    EconomicIndex index,
    DateTime from,
  );
}
