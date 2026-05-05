import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/repositories/bill_repository.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';

class BillImportResult extends Equatable {
  const BillImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  /// Number of bills the use case actually wrote to the repository.
  final int importedCount;

  /// Number of CSV rows that were silently skipped — currently this only
  /// covers rows whose `Category` column was non-empty but couldn't be
  /// resolved against the user's existing categories. Empty-category rows
  /// are imported with `categoryId = null` and don't count as skipped.
  final int skippedCount;

  @override
  List<Object?> get props => [importedCount, skippedCount];
}

/// Bulk-creates [BillEntity] records from a CSV. The use case is intentionally
/// tolerant about category resolution (unresolved → import without a
/// category, surface as `skippedCount`) so importing into a partially-set-up
/// account still produces useful data — same philosophy used by the
/// accounts CSV import for unresolved credit-card links.
///
/// Strict failures (FormatException → ValidationFailure) are reserved for
/// shape problems the user must fix in the file itself: missing required
/// columns, unparseable date, zero/negative amount, unknown type/recurrence
/// keyword.
class ImportBillsCsvUseCase {
  const ImportBillsCsvUseCase(this._billRepository, this._categoryRepository);

  final BillRepository _billRepository;
  final CategoryRepository _categoryRepository;

  Future<Either<Failure, BillImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final rows = _parseCsv(csvContent);

      final categoriesResult = await _categoryRepository.getCategories(
        userId: userId,
      );

      return categoriesResult.fold(Left.new, (categories) async {
        final lookup = _buildCategoryLookup(categories);

        final now = DateTime.now();
        var importedCount = 0;
        var skippedCount = 0;

        for (final row in rows) {
          String? categoryId;
          if (row.categoryName != null) {
            categoryId = _resolveCategoryId(
              lookup: lookup,
              categoryName: row.categoryName!,
              subcategoryName: row.subcategoryName,
            );
            if (categoryId == null) skippedCount++;
          }

          final bill = BillEntity(
            id: '',
            userId: userId,
            type: row.type,
            description: row.description,
            amount: row.amount,
            dueDate: row.dueDate,
            status: row.status,
            recurrence: row.recurrence,
            categoryId: categoryId,
            notes: row.notes,
            paidAt: row.status == BillStatus.paid ? row.dueDate : null,
            createdAt: now,
            updatedAt: now,
          );

          final result = await _billRepository.createBill(bill);
          final failure = result.fold<Failure?>((f) => f, (_) => null);
          if (failure != null) return Left(failure);

          importedCount++;
        }

        return Right(
          BillImportResult(
            importedCount: importedCount,
            skippedCount: skippedCount,
          ),
        );
      });
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to import bills.'));
    }
  }

  List<_BillImportRow> _parseCsv(String csvContent) {
    final decoded = Csv().decode(csvContent.trim());
    if (decoded.length < 2) {
      throw const FormatException('CSV file is empty or invalid.');
    }

    final colIndex = _mapHeaderColumns(decoded.first);
    for (final required in const ['type', 'description', 'amount', 'date']) {
      if (!colIndex.containsKey(required)) {
        throw FormatException(
          'CSV is missing the required "$required" column.',
        );
      }
    }
    final maxRequiredIdx = [
      colIndex['type']!,
      colIndex['description']!,
      colIndex['amount']!,
      colIndex['date']!,
    ].reduce((a, b) => a > b ? a : b);

    final rows = <_BillImportRow>[];
    var rowNumber = 1; // header
    for (final row in decoded.skip(1)) {
      rowNumber++;
      if (row.length <= maxRequiredIdx) continue;

      final typeStr = _readCell(row, colIndex['type']);
      final description = _readCell(row, colIndex['description']);
      final amountStr = _readCell(row, colIndex['amount']);
      final dateStr = _readCell(row, colIndex['date']);
      final statusStr = _readCell(row, colIndex['status']);
      final recurrenceStr = _readCell(row, colIndex['recurrence']);
      final categoryStr = _readCell(row, colIndex['category']);
      final notesStr = _readCell(row, colIndex['notes']);

      if (description.isEmpty) {
        throw FormatException(
          'Row $rowNumber: description column is empty.',
        );
      }

      final type = _parseType(typeStr, rowNumber);
      final amount = _parseAmount(amountStr);
      if (amount <= 0) {
        throw FormatException(
          'Row $rowNumber: invalid or zero amount "$amountStr".',
        );
      }
      final date = _parseDate(dateStr);
      if (date == null) {
        throw FormatException(
          'Row $rowNumber: invalid date "$dateStr". Use DD/MM/YYYY.',
        );
      }
      final status = _parseStatus(statusStr, rowNumber);
      final recurrence = _parseRecurrence(recurrenceStr, rowNumber);

      String? categoryName;
      String? subcategoryName;
      if (categoryStr.isNotEmpty) {
        // Same "/" rule used by transactions CSV: split only when not
        // surrounded by spaces — keeps freeform names like "P/L" intact.
        final match = RegExp(r'(?<! )\/(?! )').firstMatch(categoryStr);
        if (match != null) {
          categoryName = categoryStr.substring(0, match.start).trim();
          final sub = categoryStr.substring(match.end).trim();
          subcategoryName = sub.isEmpty ? null : sub;
        } else {
          categoryName = categoryStr;
        }
      }

      rows.add(
        _BillImportRow(
          type: type,
          description: description,
          amount: amount,
          dueDate: date,
          status: status,
          recurrence: recurrence,
          categoryName: categoryName,
          subcategoryName: subcategoryName,
          notes: notesStr.isEmpty ? null : notesStr,
        ),
      );
    }

    if (rows.isEmpty) {
      throw const FormatException('CSV file has no valid bills.');
    }
    return rows;
  }

  Map<String, int> _mapHeaderColumns(List<dynamic> header) {
    const synonyms = <String, List<String>>{
      'type': ['tipo', 'type', 'kind'],
      'description': ['descricao', 'description', 'descrição', 'memo'],
      'amount': ['valor', 'amount', 'value'],
      'date': [
        'data',
        'date',
        'vencimento',
        'due date',
        'duedate',
        'due',
      ],
      'status': ['status', 'situacao', 'situação', 'state'],
      'recurrence': [
        'recorrencia',
        'recorrência',
        'recurrence',
        'frequency',
        'frequencia',
      ],
      'category': ['categoria', 'category'],
      'notes': ['observacoes', 'observações', 'notes', 'note', 'observacao'],
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

  BillType _parseType(String raw, int csvRow) {
    final normalized = _normalize(raw);
    if (normalized.isEmpty) {
      throw FormatException(
        'Row $csvRow: type column is empty. Use Payable or Receivable.',
      );
    }
    if (normalized.contains('pagar') ||
        normalized.contains('payable') ||
        normalized == 'pay' ||
        normalized == 'pagavel' ||
        normalized == 'a pagar' ||
        normalized == 'to pay') {
      return BillType.payable;
    }
    if (normalized.contains('receber') ||
        normalized.contains('receivable') ||
        normalized == 'receive' ||
        normalized == 'a receber' ||
        normalized == 'to receive') {
      return BillType.receivable;
    }
    throw FormatException(
      'Row $csvRow: invalid type "$raw". Use Payable or Receivable.',
    );
  }

  /// Defaults to [BillStatus.pending] when the column is empty so a CSV
  /// without a Status column still imports cleanly. Recognised "paid"
  /// keywords cover both the payable side ("Paid"/"Paga") and the
  /// receivable side ("Received"/"Recebida") since both end up at the
  /// same enum value.
  BillStatus _parseStatus(String raw, int csvRow) {
    final normalized = _normalize(raw);
    if (normalized.isEmpty) return BillStatus.pending;
    if (normalized == 'pending' ||
        normalized == 'pendente' ||
        normalized == 'open') {
      return BillStatus.pending;
    }
    if (normalized == 'paid' ||
        normalized == 'paga' ||
        normalized == 'pago' ||
        normalized == 'received' ||
        normalized == 'recebida' ||
        normalized == 'recebido' ||
        normalized == 'settled') {
      return BillStatus.paid;
    }
    throw FormatException(
      'Row $csvRow: invalid status "$raw". Use Pending or Paid.',
    );
  }

  BillRecurrence _parseRecurrence(String raw, int csvRow) {
    final normalized = _normalize(raw);
    if (normalized.isEmpty) return BillRecurrence.oneShot;
    if (normalized == 'monthly' ||
        normalized == 'mensal' ||
        normalized == 'recurring' ||
        normalized == 'recorrente') {
      return BillRecurrence.monthly;
    }
    if (normalized == 'oneshot' ||
        normalized == 'one shot' ||
        normalized == 'one-shot' ||
        normalized == 'one-time' ||
        normalized == 'onetime' ||
        normalized == 'unica' ||
        normalized == 'única' ||
        normalized == 'single') {
      return BillRecurrence.oneShot;
    }
    throw FormatException(
      'Row $csvRow: invalid recurrence "$raw". Use Monthly or One-time.',
    );
  }

  // Same BR/EN-friendly amount parser used by the other import use cases:
  // the rightmost separator is the decimal point.
  double _parseAmount(String raw) {
    var cleaned = raw.replaceAll('"', '').trim();
    if (cleaned.isEmpty) return 0;
    if (cleaned.startsWith('-')) cleaned = cleaned.substring(1);

    final hasComma = cleaned.contains(',');
    final hasDot = cleaned.contains('.');

    if (hasComma && hasDot) {
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');
      if (lastComma > lastDot) {
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (hasComma) {
      cleaned = cleaned.replaceAll(',', '.');
    }

    return (double.tryParse(cleaned) ?? 0).abs();
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

  /// Same nested "parent → {null: rootId, sub: subId}" lookup the
  /// transactions CSV uses, so a `Housing/Internet` cell can resolve
  /// either to the root or to the named child.
  Map<String, Map<String?, String>> _buildCategoryLookup(
    List<CategoryEntity> categories,
  ) {
    final byId = {for (final c in categories) c.id: c};
    final lookup = <String, Map<String?, String>>{};

    for (final c in categories.where((c) => c.parentId == null)) {
      final key = c.name.toLowerCase();
      lookup.putIfAbsent(key, () => {});
      lookup[key]![null] = c.id;
    }

    for (final c in categories.where((c) => c.parentId != null)) {
      final parent = byId[c.parentId];
      if (parent == null) continue;
      final parentKey = parent.name.toLowerCase();
      lookup.putIfAbsent(parentKey, () => {});
      lookup[parentKey]![c.name.toLowerCase()] = c.id;
    }

    return lookup;
  }

  String? _resolveCategoryId({
    required Map<String, Map<String?, String>> lookup,
    required String categoryName,
    required String? subcategoryName,
  }) {
    final parentKey = categoryName.toLowerCase();
    final parentMap = lookup[parentKey];
    if (parentMap == null) return null;

    if (subcategoryName != null) {
      return parentMap[subcategoryName.toLowerCase()];
    }
    return parentMap[null];
  }

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
}

class _BillImportRow {
  const _BillImportRow({
    required this.type,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.recurrence,
    this.categoryName,
    this.subcategoryName,
    this.notes,
  });

  final BillType type;
  final String description;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final BillRecurrence recurrence;
  final String? categoryName;
  final String? subcategoryName;
  final String? notes;
}
