import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';

enum PastAndFutureReleasesScreenType {
  past,
  future;

  static PastAndFutureReleasesScreenType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'past':
        return PastAndFutureReleasesScreenType.past;
      case 'future':
      default:
        return PastAndFutureReleasesScreenType.future;
    }
  }

  List<TransactionFilterType> get allowedFilters {
    switch (this) {
      case PastAndFutureReleasesScreenType.past:
        return [TransactionFilterType.pending, TransactionFilterType.paid];
      case PastAndFutureReleasesScreenType.future:
        return [TransactionFilterType.pending, TransactionFilterType.unpaid];
    }
  }
}
