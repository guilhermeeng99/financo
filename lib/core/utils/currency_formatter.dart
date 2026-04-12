import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
  decimalDigits: 2,
);

String formatCurrency(double value) => _currencyFormat.format(value);
