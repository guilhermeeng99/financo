import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_navigation_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/transaction_amounts.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_transaction_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/save_asset_transaction_usecase.dart';
import 'package:financo/features/investing/presentation/widgets/funding_account_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
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
  final _cashAmountController = TextEditingController();

  TransactionKind _kind = TransactionKind.buy;
  String? _assetId;
  String? _fundingAccountId;
  late DateTime _date;

  List<Asset> _assets = const [];
  List<AccountEntity> _accounts = const [];
  bool _loadingForm = true;
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
      _fundingAccountId = existing.fundingAccountId;
      _quantityController.text = _trim(existing.quantity);
      _notesController.text = existing.notes ?? '';
      // Money fields are currency-formatted inputs, so they seed through the
      // same formatter that will reformat them on the next keystroke.
      _unitPriceController.text = _money(existing.unitPrice);
      _amountController.text = _money(existing.amount);
      _feesController.text = _money(existing.fees);
      final cash = existing.cashAmount;
      if (cash != null) _cashAmountController.text = _money(cash);
    }
    unawaited(_loadForm());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _amountController.dispose();
    _feesController.dispose();
    _notesController.dispose();
    _cashAmountController.dispose();
    super.dispose();
  }

  String get _userId => context.currentUserId;

  Future<void> _loadForm() async {
    final assets = await GetIt.I<GetAssetsUseCase>()(userId: _userId);
    final accounts = await GetIt.I<GetAccountsUseCase>()(userId: _userId);
    if (!mounted) return;
    setState(() {
      _assets = assets.getOrElse(() => const []);
      // Only a checking account can fund an aporte or receive a resgate — a
      // credit card has no cash to move.
      _accounts = [
        for (final account in accounts.getOrElse(() => const []))
          if (account.type == AccountType.checking) account,
      ];
      _loadingForm = false;
    });
  }

  String _trim(double v) {
    final s = v.toStringAsFixed(4);
    if (!s.contains('.')) return s;
    return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  /// Seeds a money field with the currency's own formatting (`2.000,00` /
  /// `2,000.00`), matching what [FinancoCurrencyField] produces while typing.
  String _money(Money value) =>
      CurrencyInputFormatter.format(value.major, value.currency);

  /// Reads a field that may be BR- or EN-formatted — quantity is typed raw,
  /// money fields arrive grouped by the currency's locale.
  double _parse(TextEditingController c) => parseDecimalAmount(c.text) ?? 0;

  Asset? get _asset {
    final id = _assetId;
    if (id == null) return null;
    for (final a in _assets) {
      if (a.id == id) return a;
    }
    return null;
  }

  AccountEntity? get _fundingAccount {
    final id = _fundingAccountId;
    if (id == null) return null;
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// A dividend is yield credited at the broker, not cash crossing between the
  /// two ledgers, so it never offers a funding account.
  bool get _supportsFunding => _kind != TransactionKind.dividend;

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
    final fundingAccountId = _supportsFunding ? _fundingAccountId : null;
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
      fundingAccountId: fundingAccountId,
      cashAmount: fundingAccountId == null
          ? null
          : Money.fromMajor(_cashAmount(resolved.amount), Currency.brl),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await GetIt.I<SaveAssetTransactionUseCase>()(tx);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold((failure) => context.showSnack(localizedFailure(failure)), (_) {
      context.showSnack(t.investing.transactions.saved);
      _leave();
    });
  }

  /// The reais that actually moved on the checking side. Defaults to the
  /// transaction's own amount, which is already BRL for a BRL asset; a foreign
  /// asset needs the field because the debit is in reais, not the native
  /// currency (F8 O2).
  double _cashAmount(Money nativeAmount) {
    final typed = _parse(_cashAmountController);
    if (typed > 0) return typed;
    return nativeAmount.major;
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() => _submitting = true);
    final result = await GetIt.I<DeleteAssetTransactionUseCase>()(existing);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold((failure) => context.showSnack(localizedFailure(failure)), (_) {
      context.showSnack(t.investing.transactions.deleted);
      _leave();
    });
  }

  /// Closes the form. Falls back to the transactions list when there is
  /// nothing to pop — the page is deep-linkable (`/investing/transaction/add`),
  /// and on a direct hit `pop` would strand the user on a form with no exit.
  void _leave() =>
      context.popOrGo(AppRoutes.investingTransactions, result: true);

  Future<void> _pickAsset() async {
    if (_assets.isEmpty) {
      context.showSnack(t.investing.transactions.noAssets);
      return;
    }
    final colors = context.appColors;
    // Draggable, scrollable sheet — the flat Column overflowed once the user
    // had more than a handful of assets (RenderFlex bottom overflow).
    final picked = await showModalBottomSheet<Asset>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FinancoPickerSheet(
        title: t.investing.transactions.asset,
        bodyBuilder: (scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 8),
          children: [
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
          ],
        ),
      ),
    );
    if (picked == null) return;
    final previous = _asset?.currency ?? Currency.brl;
    setState(() => _assetId = picked.id);
    // The money fields are formatted per currency; a BRL→USD switch would
    // otherwise leave `1.234,56` sitting under a `$` prefix until the next
    // keystroke reformatted it.
    if (picked.currency != previous) _reformatNativeMoney(picked.currency);
  }

  void _reformatNativeMoney(Currency currency) {
    for (final controller in [
      _unitPriceController,
      _amountController,
      _feesController,
    ]) {
      if (controller.text.isEmpty) continue;
      controller.text = CurrencyInputFormatter.format(
        _parse(controller),
        currency,
      );
    }
  }

  Future<void> _pickFundingAccount() async {
    final picked = await showFundingAccountPicker(
      context: context,
      accounts: _accounts,
      selectedId: _fundingAccountId,
    );
    if (picked == null) return;
    setState(() => _fundingAccountId = picked.isEmpty ? null : picked);
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

  /// Optional checking account the cash moved to/from. Picking one is what
  /// turns a buy/sell into a single-entry aporte/resgate (F8.4).
  Widget _fundingSection() {
    final isBuy = _kind == TransactionKind.buy;
    final preview = _previewCashAmount();
    return FinancoFormSection(
      label: t.investing.transactions.funding,
      children: [
        FinancoPickerField(
          label: isBuy
              ? t.investing.transactions.fundingDebit
              : t.investing.transactions.fundingCredit,
          value: _fundingAccount?.name,
          placeholder: t.investing.transactions.fundingNone,
          onTap: () => unawaited(_pickFundingAccount()),
        ),
        if (_fundingAccountId != null) ...[
          const SizedBox(height: 12),
          FinancoCurrencyField(
            controller: _cashAmountController,
            label: t.investing.transactions.cashAmount,
            hintText: preview > 0
                ? CurrencyInputFormatter.format(preview)
                : null,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          t.investing.transactions.fundingHint,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ],
    );
  }

  /// What the cash field defaults to when left blank — shown as its hint so the
  /// user can see the amount before deciding to override it.
  double _previewCashAmount() =>
      _parse(_unitPriceController) * _parse(_quantityController);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_loadingForm) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final isDividend = _kind == TransactionKind.dividend;
    // Money fields speak the asset's own currency — symbol prefix and
    // grouping/decimal separators both follow it (F9 multi-currency).
    final currency = _asset?.currency ?? Currency.brl;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        // Explicit leading: `automaticallyImplyLeading` hides the arrow when
        // the route can't pop, which is exactly the deep-link case where the
        // user most needs a way out.
        automaticallyImplyLeading: false,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: FinancoAppBarIconButton(
              icon: FontAwesomeIcons.chevronLeft,
              color: colors.onBackground,
              tooltip: t.general.back,
              onPressed: _leave,
            ),
          ),
        ),
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
                    FinancoCurrencyField(
                      controller: _amountController,
                      currency: currency,
                      label: t.investing.transactions.amount,
                    )
                  else ...[
                    FinancoTextField(
                      controller: _quantityController,
                      label: t.investing.transactions.quantity,
                      // Rebuild so the cash field's default-amount hint tracks
                      // quantity × unit price as the user types.
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FinancoCurrencyField(
                      controller: _unitPriceController,
                      currency: currency,
                      label: t.investing.transactions.unitPrice,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FinancoCurrencyField(
                    controller: _feesController,
                    currency: currency,
                    label: t.investing.transactions.fees,
                  ),
                ],
              ),
              if (_supportsFunding) ...[
                const SizedBox(height: 20),
                _fundingSection(),
              ],
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
