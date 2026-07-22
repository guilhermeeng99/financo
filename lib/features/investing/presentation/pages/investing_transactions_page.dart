import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/presentation/cubit/investing_transactions_cubit.dart';
import 'package:financo/features/investing/presentation/widgets/investing_transactions_csv_import_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Lists investing buy/sell/dividend transactions. See
/// `docs/specs/investing_transactions.md`.
class InvestingTransactionsPage extends StatefulWidget {
  const InvestingTransactionsPage({super.key});

  @override
  State<InvestingTransactionsPage> createState() =>
      _InvestingTransactionsPageState();
}

class _InvestingTransactionsPageState extends State<InvestingTransactionsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<InvestingTransactionsCubit>().load());
  }

  Future<void> _openForm([AssetTransaction? existing]) async {
    final route = existing == null
        ? AppRoutes.addInvestingTransaction
        : AppRoutes.editInvestingTransaction;
    final result = await context.push<bool>(route, extra: existing);
    if (result == true && mounted) {
      unawaited(
        context.read<InvestingTransactionsCubit>().load(forceRefresh: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.transactions.title,
        showBack: true,
        actions: [
          IconButton(
            tooltip: t.investing.transactions.import.cta,
            icon: const FaIcon(FontAwesomeIcons.fileImport, size: 18),
            onPressed: () =>
                unawaited(showInvestingTransactionsCsvImportDialog(context)),
          ),
        ],
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'investing_tx_fab',
          onPressed: _openForm,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<InvestingTransactionsCubit, InvestingTransactionsState>(
        builder: (context, state) {
          if (state is InvestingTransactionsLoading ||
              state is InvestingTransactionsImporting) {
            return const LoadingShimmer();
          }
          if (state is InvestingTransactionsError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () => context.read<InvestingTransactionsCubit>().load(
                forceRefresh: true,
              ),
            );
          }
          final loaded = state as InvestingTransactionsLoaded;
          if (loaded.transactions.isEmpty) {
            return FeatureEmptyState(
              icon: FontAwesomeIcons.rightLeft,
              title: t.investing.transactions.emptyTitle,
              message: t.investing.transactions.empty,
              actionLabel: t.investing.transactions.addFirst,
              onAction: _openForm,
            );
          }
          final assetsById = {for (final a in loaded.assets) a.id: a};
          final sorted = [...loaded.transactions]
            ..sort((a, b) => b.date.compareTo(a.date));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: sorted.length,
            itemBuilder: (_, i) => _TransactionTile(
              transaction: sorted[i],
              asset: assetsById[sorted[i].assetId],
              onTap: () => _openForm(sorted[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.asset,
    required this.onTap,
  });

  final AssetTransaction transaction;
  final Asset? asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, color) = switch (transaction.kind) {
      TransactionKind.buy => (FontAwesomeIcons.arrowDown, colors.income),
      TransactionKind.sell => (FontAwesomeIcons.arrowUp, colors.expense),
      TransactionKind.dividend => (FontAwesomeIcons.coins, colors.primary),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: FaIcon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset?.ticker ?? transaction.assetId,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${investingKindLabel(transaction.kind)} · '
                        '${DateFormat('dd MMM yyyy').format(transaction.date)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMoney(transaction.amount),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Localized label for a [TransactionKind].
String investingKindLabel(TransactionKind kind) => switch (kind) {
  TransactionKind.buy => t.investing.transactions.kinds.buy,
  TransactionKind.sell => t.investing.transactions.kinds.sell,
  TransactionKind.dividend => t.investing.transactions.kinds.dividend,
};
