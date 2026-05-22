import 'package:equatable/equatable.dart';

/// Value types for the transaction CSV-import flow, shared between
/// `ImportTransactionsCsvUseCase` (which produces them) and the import-preview
/// page (which renders/edits them). Kept in their own file so the use case
/// stays focused on parsing/import logic.

enum CsvTransactionType { despesa, receita, transferencia, pagamento }

class TransactionImportRow extends Equatable {
  const TransactionImportRow({
    required this.csvType,
    required this.amount,
    required this.description,
    required this.date,
    required this.accountName,
    this.categoryName,
    this.subcategoryName,
    this.destinationAccountName,
  });

  final CsvTransactionType csvType;
  final double amount;
  final String description;
  final DateTime date;
  final String? categoryName;
  final String? subcategoryName;
  final String accountName;
  final String? destinationAccountName;

  bool get isTransfer =>
      csvType == CsvTransactionType.transferencia ||
      csvType == CsvTransactionType.pagamento;

  TransactionImportRow copyWith({
    CsvTransactionType? csvType,
    double? amount,
    String? description,
    DateTime? date,
    String? categoryName,
    bool clearCategoryName = false,
    String? subcategoryName,
    bool clearSubcategoryName = false,
    String? accountName,
    String? destinationAccountName,
    bool clearDestinationAccountName = false,
  }) {
    return TransactionImportRow(
      csvType: csvType ?? this.csvType,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryName: clearCategoryName
          ? null
          : (categoryName ?? this.categoryName),
      subcategoryName: clearSubcategoryName
          ? null
          : (subcategoryName ?? this.subcategoryName),
      accountName: accountName ?? this.accountName,
      destinationAccountName: clearDestinationAccountName
          ? null
          : (destinationAccountName ?? this.destinationAccountName),
    );
  }

  @override
  List<Object?> get props => [
    csvType,
    amount,
    description,
    date,
    categoryName,
    subcategoryName,
    accountName,
    destinationAccountName,
  ];
}

class TransactionImportPreview extends Equatable {
  const TransactionImportPreview({
    required this.rows,
    required this.missingCategories,
    required this.missingAccounts,
    required this.skippedRows,
  });

  final List<TransactionImportRow> rows;
  final List<String> missingCategories;
  final List<String> missingAccounts;
  final int skippedRows;

  bool get canImport =>
      missingCategories.isEmpty && missingAccounts.isEmpty && rows.isNotEmpty;

  @override
  List<Object?> get props => [
    rows,
    missingCategories,
    missingAccounts,
    skippedRows,
  ];
}

class TransactionImportResult extends Equatable {
  const TransactionImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;
  final int skippedCount;

  @override
  List<Object?> get props => [importedCount, skippedCount];
}
