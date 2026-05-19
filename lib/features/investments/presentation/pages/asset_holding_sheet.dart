import 'dart:async';

import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/services/compute_investment_overview.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_holding_usecase.dart';
import 'package:financo/features/investments/domain/usecases/delete_asset_holding_usecase.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_holding_usecase.dart';
import 'package:financo/features/investments/presentation/cubit/asset_holding_form_cubit.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

/// Opens the holding editor as a modal bottom sheet. Returns `true`
/// when the user saved or deleted — the caller refreshes its data on
/// `true`.
///
/// The page passes in the live `accounts`, `classes` and `holdings`
/// lists so the sheet can compute the available remainder per
/// account locally without re-fetching.
Future<bool?> showAssetHoldingSheet({
  required BuildContext context,
  required List<AccountEntity> investmentAccounts,
  required List<AssetClassEntity> classes,
  required List<AssetHoldingEntity> holdings,
  AssetHoldingEntity? existing,
  String? presetAccountId,
  String? presetClassId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _AssetHoldingSheet(
        investmentAccounts: investmentAccounts,
        classes: classes,
        holdings: holdings,
        existing: existing,
        presetAccountId: presetAccountId,
        presetClassId: presetClassId,
      ),
    ),
  );
}

class _AssetHoldingSheet extends StatelessWidget {
  const _AssetHoldingSheet({
    required this.investmentAccounts,
    required this.classes,
    required this.holdings,
    this.existing,
    this.presetAccountId,
    this.presetClassId,
  });

  final List<AccountEntity> investmentAccounts;
  final List<AssetClassEntity> classes;
  final List<AssetHoldingEntity> holdings;
  final AssetHoldingEntity? existing;
  final String? presetAccountId;
  final String? presetClassId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    final initialAccountId = existing?.accountId ??
        presetAccountId ??
        (investmentAccounts.isNotEmpty ? investmentAccounts.first.id : '');
    final initialAccount = investmentAccounts.firstWhere(
      (a) => a.id == initialAccountId,
      orElse: () => investmentAccounts.isNotEmpty
          ? investmentAccounts.first
          : AccountEntity(
              id: '',
              userId: userId,
              name: '',
              type: AccountType.investment,
              bank: BankType.others,
              initialBalance: 0,
              createdAt: DateTime.now(),
            ),
    );
    final initialAvailable = initialAccount.id.isEmpty
        ? 0.0
        : computeAvailableForAccount(
            account: initialAccount,
            holdings: holdings,
            excludeHoldingId: existing?.id,
          );

    return BlocProvider(
      create: (_) => AssetHoldingFormCubit(
        createAssetHolding: GetIt.I<CreateAssetHoldingUseCase>(),
        updateAssetHolding: GetIt.I<UpdateAssetHoldingUseCase>(),
        userId: userId,
        availableForAccount: initialAvailable,
        existingHolding: existing,
        presetAccountId: initialAccountId,
        presetClassId: presetClassId,
      ),
      child: _AssetHoldingSheetView(
        investmentAccounts: investmentAccounts,
        classes: classes,
        holdings: holdings,
        existing: existing,
      ),
    );
  }
}

class _AssetHoldingSheetView extends StatefulWidget {
  const _AssetHoldingSheetView({
    required this.investmentAccounts,
    required this.classes,
    required this.holdings,
    this.existing,
  });

  final List<AccountEntity> investmentAccounts;
  final List<AssetClassEntity> classes;
  final List<AssetHoldingEntity> holdings;
  final AssetHoldingEntity? existing;

  @override
  State<_AssetHoldingSheetView> createState() => _AssetHoldingSheetViewState();
}

class _AssetHoldingSheetViewState extends State<_AssetHoldingSheetView> {
  late final TextEditingController _notesController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.existing?.notes ?? '',
    );
    _amountController = TextEditingController(
      text: widget.existing == null || widget.existing!.amount == 0
          ? ''
          : BrlCurrencyInputFormatter.format(widget.existing!.amount),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAccount() async {
    final cubit = context.read<AssetHoldingFormCubit>();
    final picked = await _showPickerSheet<AccountEntity>(
      context: context,
      title: t.investments.pickAccount,
      items: widget.investmentAccounts,
      labelFor: (a) => a.name,
      subtitleFor: (a) => formatCurrency(a.effectiveBalance),
      selectedId: cubit.state.accountId,
      idFor: (a) => a.id,
    );
    if (picked == null || !mounted) return;
    final available = computeAvailableForAccount(
      account: picked,
      holdings: widget.holdings,
      excludeHoldingId: widget.existing?.id,
    );
    cubit.updateAccount(picked.id, newAvailable: available);
  }

  Future<void> _pickClass() async {
    final cubit = context.read<AssetHoldingFormCubit>();
    // Holdings only attach to subclasses — root classes are
    // organisational containers (specs/investments.md §2 rule 4).
    // The picker shows subclasses grouped by parent in the subtitle.
    final parentById = {for (final c in widget.classes) c.id: c};
    final subclasses = widget.classes
        .where((c) => c.parentId != null)
        .toList()
      ..sort((a, b) {
        final parentA = parentById[a.parentId]?.name ?? '';
        final parentB = parentById[b.parentId]?.name ?? '';
        final byParent = parentA.compareTo(parentB);
        if (byParent != 0) return byParent;
        return a.name.compareTo(b.name);
      });
    final picked = await _showPickerSheet<AssetClassEntity>(
      context: context,
      title: t.investments.pickClass,
      items: subclasses,
      labelFor: (c) => c.name,
      subtitleFor: (c) {
        final parentName = parentById[c.parentId]?.name ?? '';
        return t.investments.subclassOf(parent: parentName);
      },
      selectedId: cubit.state.assetClassId,
      idFor: (c) => c.id,
    );
    if (picked == null || !mounted) return;
    cubit.updateAssetClass(picked.id);
  }

  Future<void> _handleDelete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.investments.deleteHoldingTitle),
        content: Text(t.investments.deleteHoldingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.general.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.general.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await GetIt.I<DeleteAssetHoldingUseCase>()(existing.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocConsumer<AssetHoldingFormCubit, AssetHoldingFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == FormStatus.failure &&
            state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure!.message)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AssetHoldingFormCubit>();
        final isSubmitting = state.status == FormStatus.submitting;
        final accountName = widget.investmentAccounts
            .firstWhere(
              (a) => a.id == state.accountId,
              orElse: () => AccountEntity(
                id: '',
                userId: state.userId,
                name: '',
                type: AccountType.investment,
                bank: BankType.others,
                initialBalance: 0,
                createdAt: DateTime.now(),
              ),
            )
            .name;
        final className = widget.classes
            .firstWhere(
              (c) => c.id == state.assetClassId,
              orElse: () => AssetClassEntity(
                id: '',
                userId: state.userId,
                name: '',
                icon: 0,
                color: 0,
                targetPercent: 0,
                createdAt: DateTime.now(),
              ),
            )
            .name;
        final overflow = state.amount > state.availableForAccount + 0.005;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onBackgroundLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.isEditing
                                ? t.investments.editHoldingTitle
                                : t.investments.newHoldingTitle,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (state.isEditing)
                          IconButton(
                            tooltip: t.general.delete,
                            icon: FaIcon(
                              FontAwesomeIcons.trashCan,
                              size: 16,
                              color: colors.expense,
                            ),
                            onPressed: () => unawaited(_handleDelete()),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      children: [
                        FinancoPickerField(
                          label: t.investments.account,
                          value: accountName.isEmpty ? null : accountName,
                          placeholder: t.investments.pickAccount,
                          onTap: () => unawaited(_pickAccount()),
                        ),
                        const SizedBox(height: 12),
                        FinancoPickerField(
                          label: t.investments.assetClass,
                          value: className.isEmpty ? null : className,
                          placeholder: t.investments.pickClass,
                          onTap: () => unawaited(_pickClass()),
                        ),
                        const SizedBox(height: 16),
                        FinancoCurrencyField(
                          label: t.investments.amount,
                          controller: _amountController,
                          onChanged: (raw) {
                            cubit.updateAmount(
                              parseDecimalAmount(raw) ?? 0,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          overflow
                              ? t.investments.amountOverflow(
                                  available: formatCurrency(
                                    state.availableForAccount,
                                  ),
                                )
                              : t.investments.amountHelper(
                                  available: formatCurrency(
                                    state.availableForAccount,
                                  ),
                                ),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: overflow
                                ? colors.expense
                                : colors.onBackgroundLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FinancoTextField(
                          controller: _notesController,
                          label: t.investments.notes,
                          hintText: t.investments.notesHint,
                          maxLines: 3,
                          subdued: true,
                          onChanged: cubit.updateNotes,
                        ),
                      ],
                    ),
                  ),
                  FinancoSubmitBar(
                    label: state.isEditing
                        ? t.investments.saveHolding
                        : t.investments.createHolding,
                    isEnabled: state.isValid && !isSubmitting,
                    isLoading: isSubmitting,
                    onSubmit: () => unawaited(cubit.submit()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<T?> _showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelFor,
  required String Function(T)? subtitleFor,
  required String selectedId,
  required String Function(T) idFor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = sheetContext.appColors;
      return Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onBackgroundLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: sheetContext.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Text(
                    t.investments.pickerEmpty,
                    style: sheetContext.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      final isSelected = idFor(item) == selectedId;
                      return Material(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(labelFor(item)),
                          subtitle: subtitleFor != null
                              ? Text(subtitleFor(item))
                              : null,
                          trailing: isSelected
                              ? FaIcon(
                                  FontAwesomeIcons.check,
                                  size: 14,
                                  color: colors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetContext).pop(item),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
