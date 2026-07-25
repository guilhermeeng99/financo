import 'dart:async';

import 'package:financo/app/di/injection_container.dart';
import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/data_migration/domain/account_migration_executor.dart';
import 'package:financo/features/data_migration/presentation/cubit/migration_cubit.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One-time guided migration screen (F8.5 + F9.6): fold investment accounts
/// into institutions and convert Wise-style institutions into foreign cash
/// accounts. Strings are hard-coded PT-BR here on purpose — this is a one-off
/// admin utility, not part of the localized product surface.
class MigrationPage extends StatelessWidget {
  const MigrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = MigrationCubit(
          accountRepository: sl<AccountRepository>(),
          institutionRepository: sl<InstitutionRepository>(),
          transactionRepository: sl<TransactionRepository>(),
          assetRepository: sl<AssetRepository>(),
          executor: sl<AccountMigrationExecutor>(),
          userId: context.currentUserId,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const _MigrationView(),
    );
  }
}

class _MigrationView extends StatelessWidget {
  const _MigrationView();

  Future<void> _confirmAndApply(BuildContext context, MigrationReady s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aplicar migração?'),
        content: Text(
          'Isto reescreve e apaga registros reais no seu Firestore:\n'
          '• ${s.plan.merges.length} conta(s) de investimento → instituição\n'
          '• ${s.plan.conversions.length} instituição(ões) → conta EUR\n\n'
          'Revise o resumo antes. Não é facilmente reversível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      if (!context.mounted) return;
      await context.read<MigrationCubit>().apply();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migração de contas')),
      body: BlocBuilder<MigrationCubit, MigrationState>(
        builder: (context, state) {
          return switch (state) {
            MigrationLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            MigrationApplying() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Aplicando…'),
                ],
              ),
            ),
            MigrationError(:final failure) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro: ${localizedFailure(failure)}'),
              ),
            ),
            MigrationDone(:final result) => _DoneView(result: result),
            MigrationReady() => _ReadyView(
              state: state,
              onApply: () => _confirmAndApply(context, state),
            ),
          };
        },
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({required this.state, required this.onApply});

  final MigrationReady state;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MigrationCubit>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text(
          'Contas de investimento → instituição',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (final account in state.investmentAccounts)
          Card(
            child: ListTile(
              title: Text(account.name),
              subtitle: const Text('Fundir em:'),
              trailing: DropdownButton<String?>(
                value: state.mapping[account.id],
                hint: const Text('escolher'),
                items: [
                  const DropdownMenuItem<String?>(child: Text('—')),
                  for (final i in state.institutions)
                    DropdownMenuItem<String?>(value: i.id, child: Text(i.name)),
                ],
                onChanged: (id) => cubit.chooseInstitution(account.id, id),
              ),
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Instituições → conta em moeda estrangeira (EUR)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (final institution in state.institutions)
          _ConvertTile(
            institution: institution,
            holdings: state.assetCounts[institution.id] ?? 0,
            selected: state.toConvert.contains(institution.id),
            onChanged: (v) =>
                cubit.toggleConvert(institution.id, convert: v ?? false),
          ),
        if (state.plan.warnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Avisos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final warning in state.plan.warnings)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(warning)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: state.plan.isEmpty ? null : onApply,
          child: const Text('Revisar e aplicar'),
        ),
      ],
    );
  }
}

class _ConvertTile extends StatelessWidget {
  const _ConvertTile({
    required this.institution,
    required this.holdings,
    required this.selected,
    required this.onChanged,
  });

  final Institution institution;
  final int holdings;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasHoldings = holdings > 0;
    return CheckboxListTile(
      value: selected,
      onChanged: hasHoldings ? null : onChanged,
      title: Text(institution.name),
      subtitle: Text(
        hasHoldings
            ? '$holdings ativo(s) — mova-os antes de converter'
            : 'Converter em conta EUR',
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.result});

  final MigrationResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: colors.income, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Migração concluída',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text('Aportes re-etiquetados: ${result.aportesRetagged}'),
            Text('Pernas removidas: ${result.legsDeleted}'),
            Text('Contas de investimento removidas: ${result.accountsRemoved}'),
            Text('Contas EUR criadas: ${result.accountsCreated}'),
            Text('Instituições removidas: ${result.institutionsRemoved}'),
          ],
        ),
      ),
    );
  }
}
