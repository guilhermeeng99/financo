import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/investing/domain/usecases/import_assets_csv_usecase.dart';
import 'package:financo/features/investing/presentation/cubit/assets_cubit.dart';
import 'package:financo/features/investing/presentation/pages/assets_page.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Read-only review of a parsed assets CSV before committing the import.
/// Confirming runs the import (with a determinate progress bar) and pops with a
/// success summary. See `docs/specs/investing_csv_import.md`.
class ImportInvestingAssetsPage extends StatefulWidget {
  const ImportInvestingAssetsPage({required this.preview, super.key});

  final AssetImportPreview preview;

  @override
  State<ImportInvestingAssetsPage> createState() =>
      _ImportInvestingAssetsPageState();
}

class _ImportInvestingAssetsPageState extends State<ImportInvestingAssetsPage> {
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final result = await context.read<AssetsCubit>().confirmImport(
      items: widget.preview.toCreate,
      duplicateCount: widget.preview.duplicates.length,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _submitting = false);
        context.showSnack(localizedFailure(failure));
      },
      (report) {
        final t0 = t.investing.assets.import;
        final base = t0.success(imported: report.importedCount);
        final message = report.institutionsCreated > 0
            ? '$base '
                  '${t0.institutionsCreated(count: report.institutionsCreated)}'
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
    final canImport = preview.toCreate.isNotEmpty;
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.assets.import.previewTitle,
        showBack: true,
      ),
      body: BlocBuilder<AssetsCubit, AssetsState>(
        builder: (context, state) {
          if (state is AssetsImporting) {
            return ImportProgressInline(progress: state.progress);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (!canImport)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    t.investing.assets.import.empty,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.onBackgroundLight,
                    ),
                  ),
                ),
              if (canImport)
                ImportSection(
                  title:
                      '${t.investing.assets.import.toCreate} '
                      '(${preview.toCreate.length})',
                  children: [
                    for (final item in preview.toCreate) _AssetRow(item: item),
                  ],
                ),
              if (preview.duplicates.isNotEmpty)
                ImportSection(
                  title:
                      '${t.investing.assets.import.duplicates} '
                      '(${preview.duplicates.length})',
                  children: [
                    for (final item in preview.duplicates)
                      _AssetRow(item: item, muted: true),
                  ],
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: canImport
          ? FinancoSubmitBar(
              label: t.investing.assets.import.confirm,
              isLoading: _submitting,
              onSubmit: () => unawaited(_confirm()),
            )
          : null,
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.item, this.muted = false});

  final AssetImportPreviewItem item;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                      '${assetKindLabel(item.kind)} · '
                      '${marketLabel(item.market)} · ${item.institutionName}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.currency.code,
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
}
