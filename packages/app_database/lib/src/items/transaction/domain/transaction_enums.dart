enum TransactionPaymentStatus {
  paid('paid'),
  unpaid('unpaid');

  const TransactionPaymentStatus(this.value);
  final String value;
}

enum TransactionRecurrenceType {
  unique('unique'),
  fixed('fixed');

  const TransactionRecurrenceType(this.value);
  final String value;
}

enum TransactionRecurrenceFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const TransactionRecurrenceFrequency(this.value);
  final String value;
}
