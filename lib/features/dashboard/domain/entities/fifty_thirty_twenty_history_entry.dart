import 'package:equatable/equatable.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';

/// One month inside a 50/30/20 history series. Returned in chronological
/// order by `Get503020HistoryUseCase` (oldest first → current month
/// last) so the chart can render left-to-right without re-sorting.
class FiftyThirtyTwentyHistoryEntry extends Equatable {
  const FiftyThirtyTwentyHistoryEntry({
    required this.month,
    required this.overview,
  });

  /// First day of the represented month (time-of-day 00:00). Equality and
  /// the chart use `(year, month)` only — the day component is fixed to
  /// 1 for stable comparison across timezones.
  final DateTime month;
  final FiftyThirtyTwentyOverview overview;

  @override
  List<Object?> get props => [month, overview];
}
