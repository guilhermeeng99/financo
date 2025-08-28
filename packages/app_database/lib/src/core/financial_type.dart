import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart' as flutter;

enum FinancialType {
  income('income'),
  expense('expense');

  const FinancialType(this.value);
  final String value;
}

extension FinancialTypeExtension on FinancialType {
  String title(flutter.BuildContext context) {
    switch (this) {
      case FinancialType.expense:
        return context.t.expense;
      case FinancialType.income:
        return context.t.income;
    }
  }
}
