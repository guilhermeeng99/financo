import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/quantity_format.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/investing/presentation/cubit/investing_transactions_cubit.dart';
import 'package:financo/features/investing/presentation/pages/investing_transactions_page.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Read-only review of a parsed transactions CSV before committing the import.
/// Importable rows are listed alongside skipped ones (with the reason).
/// Confirming imports the good rows and pops with a summary. See
/// `docs/specs/investing_csv_import.md`.
class ImportInvestingTransactionsPage extends StatefulWidget {
  const ImportInvestingTransactionsPage({required this.preview, super.key});

  final InvestingTransactionImportPreview preview;

  @override
  State<ImportInvestingTransactionsPage> createState() =>
      _ImportInvestingTransactionsPageState();
}

class _ImportInvestingTransactionsPageState
    extends State<ImportInvestingTransactionsPage> {
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final result = await context
        .read<InvestingTransactionsCubit>()
        .confirmImport(
          items: widget.preview.toImport,
          skippedCount: widget.preview.skipped.length,
        );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _submitting = false);
        context.showSnack(localizedFailure(failure));
      },
      (report) {
        final t0 = t.investing.transactions.import;
        final base = t0.success(imported: report.importedCount);
        final message = report.skippedCount > 0
            ? '$base ${t0.skippedCount(count: report.skippedCount)}'
            : base;
        context
          ..showSnack(message)
          ..pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    final canImport = preview.toImport.isNotEmpty;
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.transactions.import.previewTitle,
        showBack: true,
      ),
      body: BlocBuilder<InvestingTransactionsCubit, InvestingTransactionsState>(
        builder: (context, state) {
          if (state is InvestingTransactionsImporting) {
            return ImportProgressInline(progress: state.progress);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (!canImport)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    t.investing.transactions.import.empty,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.onBackgroundLight,
                    ),
                  ),
                ),
              if (canImport)
                ImportSection(
                  title:
                      '${t.investing.transactions.import.toImport} '
                      '(${preview.toImport.length})',
                  children: [
                    for (final item in preview.toImport) _TxRow(item: item),
                  ],
                ),
              if (preview.skipped.isNotEmpty)
                ImportSection(
                  title:
                      '${t.investing.transactions.import.skipped} '
                      '(${preview.skipped.length})',
                  children: [
                    for (final item in preview.skipped)
                      _TxRow(item: item, muted: true),
                  ],
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: canImport
          ? FinancoSubmitBar(
              label: t.investing.transactions.import.confirm,
              isLoading: _submitting,
              onSubmit: () => unawaited(_confirm()),
            )
          : null,
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.item, this.muted = false});

  final InvestingTransactionImportPreviewItem item;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = item.problem != null
        ? _problemLabel(item.problem!)
        : '${investingKindLabel(item.kind)} · '
              '${DateFormat('dd MMM yyyy').format(item.date)}';
    return Opacity(
      opacity: muted ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ticker,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: item.problem != null
                            ? colors.expense
                            : colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _amountLabel(item),
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.onBackgroundLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _amountLabel(InvestingTransactionImportPreviewItem item) {
    // Skipped rows have no resolved asset (so no currency) — fall back to BRL,
    // the import's home market, so the amount still formats as money rather
    // than a bare double.
    final currency = item.asset?.currency ?? Currency.brl;
    if (item.kind == TransactionKind.dividend) {
      return formatMoney(Money.fromMajor(item.amountMajor, currency));
    }
    final price = formatMoney(Money.fromMajor(item.unitPriceMajor, currency));
    return '${formatQuantity(item.quantity)} × $price';
  }

  String _problemLabel(InvestingTransactionImportProblem problem) =>
      switch (problem) {
        InvestingTransactionImportProblem.assetNotFound =>
          t.investing.transactions.import.problemAssetNotFound,
        InvestingTransactionImportProblem.assetAmbiguous =>
          t.investing.transactions.import.problemAssetAmbiguous,
        InvestingTransactionImportProblem.assetNoInstitution =>
          t.investing.transactions.import.problemAssetNoInstitution,
      };
}
