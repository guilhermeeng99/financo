import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';

/// Filter tabs of the transactions import preview. Mirrors the three row
/// kinds a CSV can carry; transfer rows have no category and require a
/// destination account instead.
enum TransactionImportTab { expense, income, transfer }

/// Maps a parsed CSV [row] to the preview tab it belongs to.
///
/// ```dart
/// final tab = transactionImportTabFor(row); // TransactionImportTab.income
/// ```
TransactionImportTab transactionImportTabFor(TransactionImportRow row) {
  if (row.isTransfer) return TransactionImportTab.transfer;
  if (row.csvType == CsvTransactionType.receita) {
    return TransactionImportTab.income;
  }
  return TransactionImportTab.expense;
}
