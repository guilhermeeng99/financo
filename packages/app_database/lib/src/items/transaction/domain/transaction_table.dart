import 'package:drift/drift.dart';

import '../../../core/financial_type.dart';
import '../../account/account_domain.dart';
import '../../category/category_domain.dart';
import 'transaction_data.dart';
import 'transaction_enums.dart';

@UseRowClass(TransactionData)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionType => textEnum<FinancialType>()();
  DateTimeColumn get actualDate => dateTime()();
  DateTimeColumn get competenceDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(max: 255)();
  TextColumn get paymentStatus => textEnum<TransactionPaymentStatus>()();
  TextColumn get recurrenceType => textEnum<TransactionRecurrenceType>()();
  TextColumn get recurrenceFrequency =>
      textEnum<TransactionRecurrenceFrequency>().nullable()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
