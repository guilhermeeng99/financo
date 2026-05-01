import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

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

class ImportTransactionsCsvUseCase {
  const ImportTransactionsCsvUseCase(
    this._transactionRepository,
    this._categoryRepository,
    this._accountRepository,
  );

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;

  Future<Either<Failure, TransactionImportPreview>> preview({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final parsed = _parseCsv(csvContent);
      final rows = parsed.rows;
      final skippedRows = parsed.skippedRows;

      final categoriesResult = await _categoryRepository.getCategories(
        userId: userId,
      );
      final accountsResult = await _accountRepository.getAccounts(
        userId: userId,
      );

      return categoriesResult.fold(Left.new, (categories) {
        return accountsResult.fold(Left.new, (accounts) {
          return Right(
            _buildPreview(
              rows: rows,
              categories: categories,
              accounts: accounts,
              skippedRows: skippedRows,
            ),
          );
        });
      });
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to parse transactions CSV.'));
    }
  }

  Future<Either<Failure, TransactionImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    final previewResult = await preview(
      csvContent: csvContent,
      userId: userId,
    );

    return previewResult.fold(Left.new, (previewData) async {
      if (!previewData.canImport) {
        final missing = <String>[
          ...previewData.missingCategories,
          ...previewData.missingAccounts,
        ];
        return Left(
          ValidationFailure(
            'Cannot import: missing ${missing.join(', ')}',
          ),
        );
      }

      return importRows(
        rows: previewData.rows,
        userId: userId,
        skippedCount: previewData.skippedRows,
      );
    });
  }

  /// Creates the (possibly user-edited) [rows] as transactions/transfers
  /// for [userId]. Resolves account/category names against the latest
  /// repository state, so renames between preview and import still work.
  ///
  /// Rows with unresolved account or category references are silently
  /// skipped — the caller (import-preview page) is expected to surface
  /// these as validation errors before invoking this method.
  Future<Either<Failure, TransactionImportResult>> importRows({
    required List<TransactionImportRow> rows,
    required String userId,
    int skippedCount = 0,
  }) async {
    final categoriesResult = await _categoryRepository.getCategories(
      userId: userId,
    );
    final accountsResult = await _accountRepository.getAccounts(
      userId: userId,
    );

    return categoriesResult.fold(Left.new, (categories) {
      return accountsResult.fold(Left.new, (accounts) async {
        final categoryLookup = _buildCategoryLookup(categories);
        final accountLookup = _buildAccountLookup(accounts);
        final now = DateTime.now();
        var importedCount = 0;

        for (final row in rows) {
          if (row.isTransfer) {
            final sourceId = accountLookup[row.accountName.toLowerCase()];
            final destId =
                accountLookup[row.destinationAccountName?.toLowerCase() ?? ''];

            if (sourceId == null || destId == null) continue;

            final expense = TransactionEntity(
              id: '',
              userId: userId,
              accountId: sourceId,
              categoryId: '',
              type: TransactionType.expense,
              amount: row.amount,
              description: row.description,
              date: row.date,
              createdAt: now,
              updatedAt: now,
            );

            final income = TransactionEntity(
              id: '',
              userId: userId,
              accountId: destId,
              categoryId: '',
              type: TransactionType.income,
              amount: row.amount,
              description: row.description,
              date: row.date,
              createdAt: now,
              updatedAt: now,
            );

            final result = await _transactionRepository.createTransfer(
              expense: expense,
              income: income,
            );

            final failure = result.fold<Failure?>((f) => f, (_) => null);
            if (failure != null) return Left(failure);

            importedCount += 2;
          } else {
            final categoryId = _resolveCategoryId(
              categoryLookup: categoryLookup,
              categoryName: row.categoryName,
              subcategoryName: row.subcategoryName,
            );

            final accountId = accountLookup[row.accountName.toLowerCase()];
            if (categoryId == null || accountId == null) continue;

            final type = row.csvType == CsvTransactionType.receita
                ? TransactionType.income
                : TransactionType.expense;

            final transaction = TransactionEntity(
              id: '',
              userId: userId,
              accountId: accountId,
              categoryId: categoryId,
              type: type,
              amount: row.amount,
              description: row.description,
              date: row.date,
              createdAt: now,
              updatedAt: now,
            );

            final result = await _transactionRepository.createTransaction(
              transaction,
            );

            final failure = result.fold<Failure?>((f) => f, (_) => null);
            if (failure != null) return Left(failure);

            importedCount++;
          }
        }

        return Right(
          TransactionImportResult(
            importedCount: importedCount,
            skippedCount: skippedCount,
          ),
        );
      });
    });
  }

  ({List<TransactionImportRow> rows, int skippedRows}) _parseCsv(
    String csvContent,
  ) {
    final decoded = Csv().decode(csvContent.trim());
    if (decoded.length < 2) {
      throw const FormatException('CSV file is empty or invalid.');
    }

    final rows = <TransactionImportRow>[];
    var skippedRows = 0;

    for (final row in decoded.skip(1)) {
      if (row.length < 7) {
        skippedRows++;
        continue;
      }

      final tipoStr = '${row[0] ?? ''}'.trim().toLowerCase();
      final dataStr = '${row[1] ?? ''}'.trim();
      final valorStr = '${row[2] ?? ''}'.trim();
      final descricao = '${row[3] ?? ''}'.trim();
      final categoriaStr = '${row[4] ?? ''}'.trim();
      final contaStr = '${row[5] ?? ''}'.trim();
      final contaTransfStr = '${row[6] ?? ''}'.trim();

      final csvType = _parseTipo(tipoStr);
      if (csvType == null || contaStr.isEmpty) {
        skippedRows++;
        continue;
      }

      final amount = _parseAmount(valorStr);
      if (amount <= 0) {
        skippedRows++;
        continue;
      }

      final date = _parseDate(dataStr);
      if (date == null) {
        skippedRows++;
        continue;
      }

      String? categoryName;
      String? subcategoryName;

      if (!_isTransferType(csvType) && categoriaStr.isNotEmpty) {
        // Split on "/" only when NOT surrounded by spaces
        // e.g. "Saúde/Plano" → parent + sub,
        // but "Mercado / Almoço" → single name
        final match = RegExp(r'(?<! )\/(?! )').firstMatch(categoriaStr);
        if (match != null) {
          categoryName = categoriaStr.substring(0, match.start).trim();
          subcategoryName = categoriaStr.substring(match.end).trim();
          if (subcategoryName.isEmpty) subcategoryName = null;
        } else {
          categoryName = categoriaStr;
        }
      }

      rows.add(
        TransactionImportRow(
          csvType: csvType,
          amount: amount,
          description: descricao,
          date: date,
          categoryName: categoryName,
          subcategoryName: subcategoryName,
          accountName: contaStr,
          destinationAccountName: contaTransfStr.isNotEmpty
              ? contaTransfStr
              : null,
        ),
      );
    }

    if (rows.isEmpty) {
      throw const FormatException('CSV file has no valid transactions.');
    }

    return (rows: rows, skippedRows: skippedRows);
  }

  CsvTransactionType? _parseTipo(String tipo) {
    return switch (tipo) {
      'despesa' => CsvTransactionType.despesa,
      'receita' => CsvTransactionType.receita,
      'transferência' || 'transferencia' => CsvTransactionType.transferencia,
      'pagamento' => CsvTransactionType.pagamento,
      _ => null,
    };
  }

  bool _isTransferType(CsvTransactionType type) =>
      type == CsvTransactionType.transferencia ||
      type == CsvTransactionType.pagamento;

  double _parseAmount(String raw) {
    var cleaned = raw.replaceAll('"', '').trim();
    cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(cleaned) ?? 0;
    return value.abs();
  }

  DateTime? _parseDate(String raw) {
    final parts = raw.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    return DateTime(year, month, day);
  }

  TransactionImportPreview _buildPreview({
    required List<TransactionImportRow> rows,
    required List<CategoryEntity> categories,
    required List<AccountEntity> accounts,
    required int skippedRows,
  }) {
    final categoryLookup = _buildCategoryLookup(categories);
    final accountLookup = _buildAccountLookup(accounts);

    final missingCategories = <String>{};
    final missingAccounts = <String>{};

    for (final row in rows) {
      // Check source account
      if (!accountLookup.containsKey(row.accountName.toLowerCase())) {
        missingAccounts.add(row.accountName);
      }

      // Check destination account for transfers
      if (row.isTransfer && row.destinationAccountName != null) {
        final destKey = row.destinationAccountName!.toLowerCase();
        if (!accountLookup.containsKey(destKey)) {
          missingAccounts.add(row.destinationAccountName!);
        }
      }

      // Check category for non-transfer rows
      if (!row.isTransfer && row.categoryName != null) {
        final resolvedId = _resolveCategoryId(
          categoryLookup: categoryLookup,
          categoryName: row.categoryName,
          subcategoryName: row.subcategoryName,
        );
        if (resolvedId == null) {
          final displayName = row.subcategoryName != null
              ? '${row.categoryName}/${row.subcategoryName}'
              : row.categoryName!;
          missingCategories.add(displayName);
        }
      }
    }

    return TransactionImportPreview(
      rows: rows,
      missingCategories: missingCategories.toList(),
      missingAccounts: missingAccounts.toList(),
      skippedRows: skippedRows,
    );
  }

  /// Builds a lookup: lowercased account name → account ID.
  Map<String, String> _buildAccountLookup(List<AccountEntity> accounts) {
    return {
      for (final account in accounts) account.name.toLowerCase(): account.id,
    };
  }

  /// Builds a nested lookup for categories.
  /// Key: lowercased category name → { null: rootId, lowercased sub: subId }
  Map<String, Map<String?, String>> _buildCategoryLookup(
    List<CategoryEntity> categories,
  ) {
    final byId = {for (final c in categories) c.id: c};
    final lookup = <String, Map<String?, String>>{};

    // First pass: roots
    for (final c in categories.where((c) => c.parentId == null)) {
      final key = c.name.toLowerCase();
      lookup.putIfAbsent(key, () => {});
      lookup[key]![null] = c.id;
    }

    // Second pass: children
    for (final c in categories.where((c) => c.parentId != null)) {
      final parent = byId[c.parentId];
      if (parent == null) continue;
      final parentKey = parent.name.toLowerCase();
      lookup.putIfAbsent(parentKey, () => {});
      lookup[parentKey]![c.name.toLowerCase()] = c.id;
    }

    return lookup;
  }

  /// Resolves a category + optional subcategory to a category ID.
  String? _resolveCategoryId({
    required Map<String, Map<String?, String>> categoryLookup,
    required String? categoryName,
    required String? subcategoryName,
  }) {
    if (categoryName == null) return null;

    final parentKey = categoryName.toLowerCase();
    final parentMap = categoryLookup[parentKey];
    if (parentMap == null) return null;

    if (subcategoryName != null) {
      return parentMap[subcategoryName.toLowerCase()];
    }

    return parentMap[null];
  }
}
