import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/csv_parsing.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class BudgetImportResult extends Equatable {
  const BudgetImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;

  /// Rows skipped because the category was unknown, was not a root expense
  /// category, or already had a budget. Strict failures (bad amount,
  /// missing required column) raise [ValidationFailure] instead.
  final int skippedCount;

  @override
  List<Object?> get props => [importedCount, skippedCount];
}

/// Bulk-creates [BudgetEntity] records from a 2-column CSV
/// (`Category,Amount`). Tolerant about category resolution: rows referencing
/// non-existent or non-expense-root categories are skipped and surfaced via
/// `skippedCount`, mirroring the accounts import philosophy.
///
/// Duplicates against existing budgets (same `(userId, categoryId)`) are
/// also skipped — the repository enforces uniqueness, so the use case
/// pre-filters to keep `importedCount` honest.
class ImportBudgetsCsvUseCase {
  const ImportBudgetsCsvUseCase(
    this._budgetRepository,
    this._categoryRepository,
  );

  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;

  Future<Either<Failure, BudgetImportResult>> call({
    required String csvContent,
    required String userId,
  }) async {
    try {
      final rows = _parseCsv(csvContent);

      final categoriesResult = await _categoryRepository.getCategories(
        userId: userId,
      );

      return categoriesResult.fold(Left.new, (categories) async {
        final expenseRoots = <String, String>{
          for (final c in categories.where(
            (c) => c.parentId == null && c.type == CategoryType.expense,
          ))
            c.name.toLowerCase(): c.id,
        };

        final existingBudgetsResult = await _budgetRepository.getBudgets(
          userId: userId,
        );

        return existingBudgetsResult.fold(Left.new, (existing) async {
          final usedCategoryIds = existing.map((b) => b.categoryId).toSet();
          final now = DateTime.now();
          var importedCount = 0;
          var skippedCount = 0;

          for (final row in rows) {
            final categoryId = expenseRoots[row.categoryName.toLowerCase()];
            if (categoryId == null || usedCategoryIds.contains(categoryId)) {
              skippedCount++;
              continue;
            }

            final budget = BudgetEntity(
              id: '',
              userId: userId,
              categoryId: categoryId,
              amount: row.amount,
              createdAt: now,
              updatedAt: now,
            );

            final result = await _budgetRepository.createBudget(budget);
            final failure = result.fold<Failure?>((f) => f, (_) => null);
            if (failure != null) return Left(failure);

            usedCategoryIds.add(categoryId);
            importedCount++;
          }

          return Right(
            BudgetImportResult(
              importedCount: importedCount,
              skippedCount: skippedCount,
            ),
          );
        });
      });
    } on FormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on Exception {
      return const Left(ServerFailure('Failed to import budgets.'));
    }
  }

  List<_BudgetImportRow> _parseCsv(String csvContent) {
    final decoded = Csv().decode(csvContent.trim());
    if (decoded.length < 2) {
      throw FormatException(t.csvImport.errors.emptyFile);
    }

    final colIndex = mapCsvHeaderColumns(
      decoded.first,
      synonyms: _budgetHeaderSynonyms,
    );
    for (final required in const ['category', 'amount']) {
      if (!colIndex.containsKey(required)) {
        throw FormatException(
          t.csvImport.errors.missingColumn(column: required),
        );
      }
    }
    final maxRequiredIdx = [
      colIndex['category']!,
      colIndex['amount']!,
    ].reduce((a, b) => a > b ? a : b);

    final rows = <_BudgetImportRow>[];
    final seen = <String>{};
    var rowNumber = 1; // header
    for (final row in decoded.skip(1)) {
      rowNumber++;
      if (row.length <= maxRequiredIdx) continue;

      final categoryName = readCsvCell(row, colIndex['category']);
      final amountStr = readCsvCell(row, colIndex['amount']);

      if (categoryName.isEmpty) continue;

      // Same-category dedupe within the file itself — keeps the count
      // honest when the user accidentally lists the same category twice.
      final key = categoryName.toLowerCase();
      if (!seen.add(key)) continue;

      final amount = parseCsvAmount(amountStr, absolute: true);
      if (amount <= 0) {
        throw FormatException(
          t.csvImport.errors.invalidAmount(row: rowNumber, value: amountStr),
        );
      }

      rows.add(
        _BudgetImportRow(categoryName: categoryName, amount: amount),
      );
    }

    if (rows.isEmpty) {
      throw FormatException(t.csvImport.errors.noValidBudgets);
    }
    return rows;
  }
}

/// Budgets header synonyms for [mapCsvHeaderColumns] — accepts the
/// 2-column `Category,Amount` layout in PT-BR or English.
const _budgetHeaderSynonyms = <String, List<String>>{
  'category': ['categoria', 'category'],
  'amount': [
    'valor',
    'amount',
    'value',
    'cap',
    'limite',
    'monthly cap',
    'valor mensal',
  ],
};

class _BudgetImportRow {
  const _BudgetImportRow({required this.categoryName, required this.amount});

  final String categoryName;
  final double amount;
}
