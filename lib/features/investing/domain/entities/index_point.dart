import 'package:equatable/equatable.dart';

/// Economic index series used to value fixed income. See `docs/specs/quotes.md`.
enum EconomicIndex { cdi, selic, ipca }

/// One dated observation of an economic index.
///
/// [rate] is the **period rate in percent** exactly as BCB publishes it: daily
/// for CDI/Selic, monthly for IPCA (e.g. `0.041` means 0.041% for that day).
/// Divide by 100 before compounding.
class IndexPoint extends Equatable {
  /// Creates an observation.
  const IndexPoint({required this.date, required this.rate});

  /// Reference date of the observation.
  final DateTime date;

  /// Period rate in percent.
  final double rate;

  @override
  List<Object?> get props => [date, rate];
}
