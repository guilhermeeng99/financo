import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_import_tab.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Scrollable list of parsed CSV rows on the transactions import preview,
/// filtered to the selected [filter] tab and sorted newest-first.
/// Callbacks receive the row's index in the *unfiltered* [rows] list so
/// the page can edit/remove the right entry.
class TransactionImportRowsList extends StatelessWidget {
  const TransactionImportRowsList({
    required this.rows,
    required this.filter,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final List<TransactionImportRow> rows;
  final TransactionImportTab filter;
  final void Function(int globalIndex) onTap;
  final void Function(int globalIndex) onRemove;

  @override
  Widget build(BuildContext context) {
    final indexed = <_Indexed>[];
    for (var i = 0; i < rows.length; i++) {
      if (transactionImportTabFor(rows[i]) == filter) {
        indexed.add(_Indexed(row: rows[i], globalIndex: i));
      }
    }
    indexed.sort((a, b) => b.row.date.compareTo(a.row.date));

    if (indexed.isEmpty) {
      return ImportEmptyTab(message: t.transactions.importEmptyTab);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: indexed.length,
      itemBuilder: (_, i) => _RowTile(
        row: indexed[i].row,
        onTap: () => onTap(indexed[i].globalIndex),
        onRemove: () => onRemove(indexed[i].globalIndex),
      ),
    );
  }
}

class _Indexed {
  const _Indexed({required this.row, required this.globalIndex});

  final TransactionImportRow row;
  final int globalIndex;
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.row,
    required this.onTap,
    required this.onRemove,
  });

  final TransactionImportRow row;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dateLabel = formatDayMonth(row.date);

    final isExpenseLike =
        row.csvType == CsvTransactionType.despesa || row.isTransfer;
    final amountColor = isExpenseLike ? colors.expense : colors.income;
    final amountSign = isExpenseLike ? '-' : '+';

    final secondaryLabel = row.isTransfer
        ? '${row.accountName} → ${row.destinationAccountName ?? '?'}'
        : (row.categoryName == null
              ? row.accountName
              : '${_categoryShort(row)} · ${row.accountName}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        dateLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.description.isEmpty
                              ? t.transactions.descriptionHint
                              : row.description,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: row.description.isEmpty
                                ? colors.onBackgroundLight
                                : colors.onBackground,
                            fontWeight: FontWeight.w600,
                            fontStyle: row.description.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secondaryLabel,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$amountSign${formatCurrency(row.amount)}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ImportRemoveButton(onPressed: onRemove),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _categoryShort(TransactionImportRow row) => row.subcategoryName != null
      ? '${row.categoryName} › ${row.subcategoryName}'
      : row.categoryName!;
}
