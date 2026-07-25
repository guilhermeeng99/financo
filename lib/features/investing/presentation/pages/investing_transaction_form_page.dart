import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/transaction_amounts.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_transaction_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/save_asset_transaction_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Create/edit form for an investing transaction (buy/sell/dividend). The
/// institution is derived from the chosen asset. See
/// `docs/specs/investing_transactions.md`.
class InvestingTransactionFormPage extends StatefulWidget {
  const InvestingTransactionFormPage({super.key, this.existing});

  final AssetTransaction? existing;

  @override
  State<InvestingTransactionFormPage> createState() =>
      _InvestingTransactionFormPageState();
}

class _InvestingTransactionFormPageState
    extends State<InvestingTransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _amountController = TextEditingController();
  final _feesController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionKind _kind = TransactionKind.buy;
  String? _assetId;
  late DateTime _date;

  List<Asset> _assets = const [];
  bool _loadingAssets = true;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _date = existing?.date ?? DateTime.now();
    if (existing != null) {
      _kind = existing.kind;
      _assetId = existing.assetId;
      _quantityController.text = _trim(existing.quantity);
      _unitPriceController.text = _trim(existing.unitPrice.major);
      _amountController.text = _trim(existing.amount.major);
      _feesController.text = _trim(existing.fees.major);
      _notesController.text = existing.notes ?? '';
    }
    unawaited(_loadAssets());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _amountController.dispose();
    _feesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _userId => context.currentUserId;

  Future<void> _loadAssets() async {
    final result = await GetIt.I<GetAssetsUseCase>()(userId: _userId);
    if (!mounted) return;
    setState(() {
      _assets = result.getOrElse(() => const []);
      _loadingAssets = false;
    });
  }

  String _trim(double v) {
    final s = v.toStringAsFixed(4);
    if (!s.contains('.')) return s;
    return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Asset? get _asset {
    final id = _assetId;
    if (id == null) return null;
    for (final a in _assets) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final asset = _asset;
    if (asset == null) {
      context.showSnack(t.investing.transactions.noAssets);
      return;
    }
    setState(() => _submitting = true);

    final currency = asset.currency;
    final resolved = resolveTransactionAmounts(
      kind: _kind,
      quantity: _parse(_quantityController),
      unitPrice: Money.fromMajor(_parse(_unitPriceController), currency),
      amount: Money.fromMajor(_parse(_amountController), currency),
      currency: currency,
    );
    final existing = widget.existing;
    final now = DateTime.now();
    final tx = AssetTransaction(
      id: existing?.id ?? '',
      userId: _userId,
      institutionId: asset.institutionId ?? '',
      assetId: asset.id,
      kind: _kind,
      quantity: resolved.quantity,
      unitPrice: resolved.unitPrice,
      fees: Money.fromMajor(_parse(_feesController), currency),
      amount: resolved.amount,
      date: _date,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await GetIt.I<SaveAssetTransactionUseCase>()(tx);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context
        ..showSnack(t.investing.transactions.saved)
        ..pop(true),
    );
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() => _submitting = true);
    final result = await GetIt.I<DeleteAssetTransactionUseCase>()(existing.id);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context
        ..showSnack(t.investing.transactions.deleted)
        ..pop(true),
    );
  }

  Future<void> _pickAsset() async {
    if (_assets.isEmpty) {
      context.showSnack(t.investing.transactions.noAssets);
      return;
    }
    final colors = context.appColors;
    final picked = await showModalBottomSheet<Asset>(
      context: context,
      backgroundColor: colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                t.investing.transactions.asset,
                style: ctx.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final asset in _assets)
              ListTile(
                title: Text(asset.ticker),
                subtitle: Text(asset.name),
                trailing: asset.id == _assetId
                    ? FaIcon(
                        FontAwesomeIcons.check,
                        size: 14,
                        color: colors.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, asset),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _assetId = picked.id);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_loadingAssets) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final isDividend = _kind == TransactionKind.dividend;
    final currencyCode = _asset?.currency.code ?? Currency.brl.code;
    final amountLabel = '${t.investing.transactions.amount} ($currencyCode)';
    final priceLabel = '${t.investing.transactions.unitPrice} ($currencyCode)';
    final feesLabel = '${t.investing.transactions.fees} ($currencyCode)';
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditing
              ? t.investing.transactions.edit
              : t.investing.transactions.add,
          style: context.textTheme.titleMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FinancoAppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                tooltip: t.general.delete,
                onPressed: () => unawaited(_delete()),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FinancoPillToggle<TransactionKind>(
                selected: _kind,
                onChanged: (k) => setState(() => _kind = k),
                options: [
                  FinancoPillToggleOption(
                    value: TransactionKind.buy,
                    label: t.investing.transactions.kinds.buy,
                    icon: FontAwesomeIcons.arrowDown,
                  ),
                  FinancoPillToggleOption(
                    value: TransactionKind.sell,
                    label: t.investing.transactions.kinds.sell,
                    icon: FontAwesomeIcons.arrowUp,
                  ),
                  FinancoPillToggleOption(
                    value: TransactionKind.dividend,
                    label: t.investing.transactions.kinds.dividend,
                    icon: FontAwesomeIcons.coins,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinancoFormSection(
                label: t.investing.transactions.asset,
                children: [
                  FinancoPickerField(
                    label: t.investing.transactions.asset,
                    value: _asset?.ticker,
                    placeholder: t.investing.transactions.pickAsset,
                    isError: _assetId == null,
                    onTap: () => unawaited(_pickAsset()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinancoFormSection(
                label: isDividend
                    ? t.investing.transactions.amount
                    : t.investing.transactions.quantity,
                children: [
                  if (isDividend)
                    FinancoTextField(
                      controller: _amountController,
                      label: amountLabel,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    )
                  else ...[
                    FinancoTextField(
                      controller: _quantityController,
                      label: t.investing.transactions.quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FinancoTextField(
                      controller: _unitPriceController,
                      label: priceLabel,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FinancoTextField(
                    controller: _feesController,
                    label: feesLabel,
                    subdued: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinancoFormSection(
                label: t.investing.transactions.date,
                children: [
                  FinancoPickerField(
                    label: t.investing.transactions.date,
                    value: DateFormat('dd MMM yyyy').format(_date),
                    placeholder: t.investing.transactions.date,
                    onTap: () => unawaited(_pickDate()),
                  ),
                  const SizedBox(height: 12),
                  FinancoTextField(
                    controller: _notesController,
                    label: t.investing.transactions.notes,
                    hintText: t.investing.transactions.notesHint,
                    subdued: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FinancoSubmitBar(
        label: _isEditing ? t.general.update : t.general.create,
        isLoading: _submitting,
        onSubmit: () => unawaited(_submit()),
      ),
    );
  }
}
