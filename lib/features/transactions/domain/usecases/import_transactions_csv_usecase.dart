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
  ///
  /// [onProgress] is called after each row is processed (created or
  /// skipped) with `(processedCount, total)` so the caller can render a
  /// determinate progress UI. The callback is invoked synchronously
  /// between awaits, so emitting cubit/bloc state from inside it is safe.
  Future<Either<Failure, TransactionImportResult>> importRows({
    required List<TransactionImportRow> rows,
    required String userId,
    int skippedCount = 0,
    void Function(int processed, int total)? onProgress,
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
        final total = rows.length;
        var processed = 0;
        var importedCount = 0;

        for (final row in rows) {
          if (row.isTransfer) {
            final sourceId = accountLookup[row.accountName.toLowerCase()];
            final destId =
                accountLookup[row.destinationAccountName?.toLowerCase() ?? ''];

            if (sourceId == null || destId == null) {
              processed++;
              onProgress?.call(processed, total);
              continue;
            }

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
            if (categoryId == null || accountId == null) {
              processed++;
              onProgress?.call(processed, total);
              continue;
            }

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
          processed++;
          onProgress?.call(processed, total);
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

    final colIndex = _mapHeaderColumns(decoded.first);
    for (final required in const ['type', 'date', 'amount', 'account']) {
      if (!colIndex.containsKey(required)) {
        throw FormatException(
          'CSV is missing the required "$required" column.',
        );
      }
    }
    final maxRequiredIdx = [
      colIndex['type']!,
      colIndex['date']!,
      colIndex['amount']!,
      colIndex['account']!,
    ].reduce((a, b) => a > b ? a : b);

    final rows = <TransactionImportRow>[];
    // Mobills (and similar) exports each transfer twice: once as a
    // negative on the source account and once as a positive on the
    // destination — same date, same |amount|, accounts swapped. We group
    // both halves and emit a single canonical row per unique pair.
    final transferGroups = <String, _TransferGroup>{};
    var skippedRows = 0;
    var rowNumber = 1; // header
    for (final row in decoded.skip(1)) {
      rowNumber++;
      // Truly short/incomplete row (e.g. trailing blank line) — skip
      // silently rather than rejecting the whole CSV. Bad data inside
      // an otherwise complete row is still rejected below.
      if (row.length <= maxRequiredIdx) {
        skippedRows++;
        continue;
      }

      final tipoStr = _readCell(row, colIndex['type']);
      final dataStr = _readCell(row, colIndex['date']);
      final valorStr = _readCell(row, colIndex['amount']);
      final descricao = _readCell(row, colIndex['description']);
      final categoriaStr = _readCell(row, colIndex['category']);
      final contaStr = _readCell(row, colIndex['account']);
      final contaTransfStr = _readCell(row, colIndex['destination']);

      final csvType = _parseTipo(tipoStr, rowNumber);

      if (contaStr.isEmpty) {
        throw FormatException(
          'Row $rowNumber: account column is empty.',
        );
      }

      final amount = _parseAmount(valorStr);
      if (amount <= 0) {
        throw FormatException(
          'Row $rowNumber: invalid or zero amount "$valorStr".',
        );
      }
      final wasNegative = valorStr.replaceAll('"', '').trim().startsWith('-');

      final date = _parseDate(dataStr);
      if (date == null) {
        throw FormatException(
          'Row $rowNumber: invalid date "$dataStr". Use DD/MM/YYYY.',
        );
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

      final newRow = TransactionImportRow(
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
      );

      if (_isTransferType(csvType)) {
        final key = _transferDedupKey(
          date: date,
          amount: amount,
          source: contaStr,
          destination: contaTransfStr,
        );
        final group = transferGroups.putIfAbsent(key, _TransferGroup.new);
        if (wasNegative) {
          group.negatives.add(newRow);
        } else {
          group.positives.add(newRow);
        }
      } else {
        rows.add(newRow);
      }
    }

    // Resolve transfer groups: pair up negatives with positives 1:1
    // (the canonical representation lives on the negative leg, since its
    // `Conta` is already the source). Any unpaired positive is kept but
    // its source/destination are swapped — for those rows the CSV's
    // `Conta` is actually the destination.
    for (final group in transferGroups.values) {
      final pairs = group.negatives.length < group.positives.length
          ? group.negatives.length
          : group.positives.length;

      for (var i = 0; i < pairs; i++) {
        rows.add(group.negatives[i]);
      }
      // Each discarded positive mirror counts as skipped so the user
      // sees the CSV-row → import-row reduction in the preview.
      skippedRows += pairs;

      for (var i = pairs; i < group.negatives.length; i++) {
        rows.add(group.negatives[i]);
      }
      for (var i = pairs; i < group.positives.length; i++) {
        final pos = group.positives[i];
        rows.add(
          pos.copyWith(
            accountName: pos.destinationAccountName ?? pos.accountName,
            destinationAccountName: pos.accountName,
          ),
        );
      }
    }

    if (rows.isEmpty) {
      throw const FormatException('CSV file has no valid transactions.');
    }

    return (rows: rows, skippedRows: skippedRows);
  }

  /// Canonical key used to detect mirror transfer rows. The key is
  /// independent of which account is reported as the "Conta" — both the
  /// outgoing (-X on source) and incoming (+X on destination) rows of a
  /// single Mobills-style transfer hash to the same value.
  String _transferDedupKey({
    required DateTime date,
    required double amount,
    required String source,
    required String destination,
  }) {
    final dateKey = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final accounts = [source.toLowerCase(), destination.toLowerCase()]..sort();
    return '$dateKey|${amount.toStringAsFixed(2)}|'
        '${accounts[0]}|${accounts[1]}';
  }

  /// Resolves header columns to logical field keys so the parser tolerates
  /// extra columns (e.g. an `Observações` column added by another finance
  /// app) and reordered/English layouts. Matching is accent- and
  /// case-insensitive via [_normalize].
  Map<String, int> _mapHeaderColumns(List<dynamic> header) {
    const synonyms = <String, List<String>>{
      'type': ['tipo', 'type', 'kind'],
      'date': ['data', 'date'],
      'amount': ['valor', 'value', 'amount'],
      'description': [
        'descricao',
        'description',
        'descrição',
        'memo',
        'notes',
      ],
      'category': ['categoria', 'category'],
      'account': ['conta', 'account', 'source account', 'origem'],
      'destination': [
        'conta transferencia',
        'conta transferência',
        'conta destino',
        'destination',
        'destination account',
        'transfer account',
      ],
    };

    final out = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final norm = _normalize('${header[i] ?? ''}');
      if (norm.isEmpty) continue;
      for (final entry in synonyms.entries) {
        if (out.containsKey(entry.key)) continue;
        if (entry.value.contains(norm)) {
          out[entry.key] = i;
          break;
        }
      }
    }
    return out;
  }

  String _readCell(List<dynamic> row, int? index) {
    if (index == null || index >= row.length) return '';
    return '${row[index] ?? ''}'.trim();
  }

  /// Maps the `Tipo` column to a [CsvTransactionType]. Accepts PT-BR
  /// (`Despesa`, `Receita`, `Transferência`, `Pagamento`) and EN
  /// (`Expense`, `Income`, `Transfer`, `Payment`) via accent- and
  /// case-insensitive match. Empty or unrecognized values raise a
  /// [FormatException] tagged with [csvRow] so the UI can point the user
  /// to the exact offending row.
  CsvTransactionType _parseTipo(String tipo, int csvRow) {
    final normalized = _normalize(tipo);
    switch (normalized) {
      case 'despesa':
      case 'expense':
        return CsvTransactionType.despesa;
      case 'receita':
      case 'income':
        return CsvTransactionType.receita;
      case 'transferencia':
      case 'transfer':
        return CsvTransactionType.transferencia;
      case 'pagamento':
      case 'payment':
        return CsvTransactionType.pagamento;
    }
    if (normalized.isEmpty) {
      throw FormatException(
        'Row $csvRow: type column is empty. '
        'Use Despesa, Receita, Transferência or Pagamento.',
      );
    }
    throw FormatException(
      'Row $csvRow: invalid type "$tipo". '
      'Use Despesa, Receita, Transferência or Pagamento.',
    );
  }

  bool _isTransferType(CsvTransactionType type) =>
      type == CsvTransactionType.transferencia ||
      type == CsvTransactionType.pagamento;

  // Accepts either Brazilian ("421,95" / "1.234,56") or English-style
  // ("421.95" / "1,234.56") number formats. The rightmost separator is
  // assumed to be the decimal point; the other one is a thousands grouper
  // and stripped. Returns `abs()` since the type column carries the sign.
  double _parseAmount(String raw) {
    var cleaned = raw.replaceAll('"', '').trim();
    if (cleaned.isEmpty) return 0;
    final negative = cleaned.startsWith('-');
    if (negative) cleaned = cleaned.substring(1);

    final hasComma = cleaned.contains(',');
    final hasDot = cleaned.contains('.');

    if (hasComma && hasDot) {
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');
      if (lastComma > lastDot) {
        // BR: 1.234,56
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // EN: 1,234.56
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (hasComma) {
      cleaned = cleaned.replaceAll(',', '.');
    }
    // hasDot-only or integer falls through unchanged.

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

  // Lowercase + strip Portuguese accents so "Cartão de Crédito" matches
  // "cartao de credito" etc. without keeping a brittle synonym list.
  String _normalize(String raw) {
    final lower = raw.trim().toLowerCase();
    const map = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    final buf = StringBuffer();
    for (final c in lower.split('')) {
      buf.write(map[c] ?? c);
    }
    return buf.toString();
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

/// Bucket of transfer rows that share a canonical key (same date,
/// |amount| and account pair, regardless of direction). Used by
/// `_parseCsv` to fold Mobills-style mirror exports into a single row
/// per real transfer.
class _TransferGroup {
  final List<TransactionImportRow> negatives = [];
  final List<TransactionImportRow> positives = [];
}
