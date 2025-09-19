import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';

enum PastAndFutureReleasesType {
  past,
  future;

  static PastAndFutureReleasesType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'past':
        return PastAndFutureReleasesType.past;
      case 'future':
      default:
        return PastAndFutureReleasesType.future;
    }
  }

  List<TransactionFilterType> get allowedFilters {
    switch (this) {
      case PastAndFutureReleasesType.past:
        return [TransactionFilterType.pending, TransactionFilterType.paid];
      case PastAndFutureReleasesType.future:
        return [TransactionFilterType.pending, TransactionFilterType.unpaid];
    }
  }
}
