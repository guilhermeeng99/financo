import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/settle_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Settles [transaction] and refreshes every cache that renders it.
///
/// Both surfaces that offer the one-tap check — the payables/receivables
/// ledger and the account statement — need the exact same follow-through, and
/// they had drifted into two byte-identical private copies. The caller keeps
/// whatever *local* reload it owns (the statement reloads its own cubit); this
/// helper covers the shared part.
///
/// Returns `true` when the settle succeeded, so the caller can decide whether
/// to reload itself.
///
/// ```dart
/// if (await settleAndRefresh(context, transaction)) _triggerLoad(account);
/// ```
Future<bool> settleAndRefresh(
  BuildContext context,
  TransactionEntity transaction,
) async {
  final result = await GetIt.I<SettleTransactionUseCase>()(transaction);
  if (!context.mounted) return false;

  return result.fold(
    (failure) {
      context.showSnack(localizedFailure(failure));
      return false;
    },
    (_) {
      context
        ..showSnack(
          transaction.isReceivable
              ? t.payablesReceivables.transactionReceived
              : t.payablesReceivables.transactionPaid,
        )
        ..read<TransactionsBloc>().add(
          TransactionsLoadRequested(forceRefresh: true),
        )
        ..read<DashboardBloc>().add(const DashboardRefreshRequested());
      unawaited(context.read<AccountsCubit>().loadAccounts(forceRefresh: true));
      return true;
    },
  );
}
