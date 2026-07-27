import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_option_picker.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/services/allocation_metadata.dart';
import 'package:financo/features/investing/domain/services/fixed_income_metadata.dart';
import 'package:financo/features/investing/domain/usecases/create_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_institutions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/update_asset_usecase.dart';
import 'package:financo/features/investing/presentation/pages/assets_page.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Create/edit form for an investing asset. See
/// `docs/specs/investing_assets.md`.
class AssetFormPage extends StatefulWidget {
  const AssetFormPage({super.key, this.existing, this.presetClassId});

  final Asset? existing;

  /// When creating (no [existing]), pre-selects this allocation class — set by
  /// the "Add asset" action on an allocation class-detail page.
  final String? presetClassId;

  @override
  State<AssetFormPage> createState() => _AssetFormPageState();
}

class _AssetFormPageState extends State<AssetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _nameController = TextEditingController();
  final _fiRateController = TextEditingController();
  final _allocationTargetController = TextEditingController();

  late AssetKind _kind;
  late Market _market;
  late Currency _currency;
  String? _institutionId;
  String? _allocationClassId;
  FixedIncomeBasis _fiBasis = FixedIncomeBasis.cdi;

  List<Institution> _institutions = const [];
  List<AssetClassEntity> _classes = const [];
  bool _loadingFormData = true;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _kind = existing?.kind ?? AssetKind.etfUs;
    _market = existing?.market ?? Market.us;
    _currency = existing?.currency ?? Currency.usd;
    _institutionId = existing?.institutionId;
    _allocationClassId = existing == null
        ? widget.presetClassId
        : AllocationMetadata.classId(existing);
    if (existing != null) {
      _tickerController.text = existing.ticker;
      _nameController.text = existing.name;
      final target = AllocationMetadata.target(existing);
      if (target > 0) _allocationTargetController.text = _trimRate(target);
      final parsed = FixedIncomeMetadata.read(existing);
      if (parsed != null) {
        _fiBasis = parsed.$1;
        _fiRateController.text = _trimRate(parsed.$2);
      }
    }
    unawaited(_loadFormData());
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _nameController.dispose();
    _fiRateController.dispose();
    _allocationTargetController.dispose();
    super.dispose();
  }

  String get _userId => context.currentUserId;

  Future<void> _loadFormData() async {
    final institutions = await GetIt.I<GetInstitutionsUseCase>()(
      userId: _userId,
    );
    final classes = await GetIt.I<GetAssetClassesUseCase>()(userId: _userId);
    if (!mounted) return;
    setState(() {
      _institutions = institutions.getOrElse(() => const []);
      _classes = classes.getOrElse(() => const []);
      _loadingFormData = false;
    });
  }

  String _trimRate(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  Map<String, String> _buildMetadata() {
    final metadata = Map<String, String>.from(
      widget.existing?.metadata ?? const {},
    );
    if (_kind == AssetKind.fixedIncome) {
      final rate = double.tryParse(_fiRateController.text.replaceAll(',', '.'));
      if (rate != null) {
        metadata.addAll(FixedIncomeMetadata.write(_fiBasis, rate));
      }
    }
    final rawTarget = _allocationTargetController.text.replaceAll(',', '.');
    final target = double.tryParse(rawTarget) ?? 0;
    return AllocationMetadata.write(
      metadata,
      _allocationClassId,
      targetPercent: target,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_institutionId == null) {
      context.showSnack(t.investing.assets.noInstitutions);
      return;
    }
    setState(() => _submitting = true);

    final existing = widget.existing;
    final asset = Asset(
      id: existing?.id ?? '',
      userId: _userId,
      ticker: _tickerController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      kind: _kind,
      market: _market,
      currency: _currency,
      institutionId: _institutionId,
      metadata: _buildMetadata(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    final result = _isEditing
        ? await GetIt.I<UpdateAssetUseCase>()(asset)
        : await GetIt.I<CreateAssetUseCase>()(asset);

    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context
        ..showSnack(
          _isEditing ? t.investing.assets.updated : t.investing.assets.created,
        )
        ..pop(true),
    );
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() => _submitting = true);
    final result = await GetIt.I<DeleteAssetUseCase>()(existing);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context
        ..showSnack(t.investing.assets.deleted)
        ..pop(true),
    );
  }

  String? get _institutionName {
    final id = _institutionId;
    if (id == null) return null;
    for (final inst in _institutions) {
      if (inst.id == id) return inst.name;
    }
    return null;
  }

  Future<void> _pickInstitution() async {
    if (_institutions.isEmpty) {
      context.showSnack(t.investing.assets.noInstitutions);
      return;
    }
    final picked = await _pickOption<Institution>(
      title: t.investing.assets.institution,
      options: _institutions,
      selected: _institutions.firstWhere(
        (i) => i.id == _institutionId,
        orElse: () => _institutions.first,
      ),
      label: (i) => i.name,
    );
    if (picked != null) setState(() => _institutionId = picked.id);
  }

  String? get _className {
    final id = _allocationClassId;
    if (id == null) return null;
    for (final c in _classes) {
      if (c.id == id) return c.name;
    }
    return null;
  }

  Future<void> _pickClass() async {
    if (_classes.isEmpty) {
      context.showSnack(t.investing.assets.noClasses);
      return;
    }
    final picked = await _pickClassOption();
    if (picked == null) return;
    // The sentinel empty id clears the link ("None").
    setState(() => _allocationClassId = picked.isEmpty ? null : picked);
  }

  /// Bottom sheet listing every class plus a "None" row, returning the picked
  /// class id (empty string = None, null = dismissed).
  Future<String?> _pickClassOption() {
    final colors = context.appColors;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FinancoPickerSheet(
        title: t.investing.assets.allocationClass,
        bodyBuilder: (scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            ListTile(
              title: Text(t.investing.assets.noClass),
              trailing: _allocationClassId == null
                  ? FaIcon(
                      FontAwesomeIcons.check,
                      size: 14,
                      color: colors.primary,
                    )
                  : null,
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final option in _classes)
              ListTile(
                title: Text(option.name),
                trailing: option.id == _allocationClassId
                    ? FaIcon(
                        FontAwesomeIcons.check,
                        size: 14,
                        color: colors.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, option.id),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickKind() async {
    final picked = await _pickOption<AssetKind>(
      title: t.investing.assets.kind,
      options: AssetKind.selectableKinds,
      selected: AssetKind.selectableKinds.contains(_kind)
          ? _kind
          : AssetKind.selectableKinds.first,
      label: assetKindLabel,
    );
    if (picked != null) setState(() => _kind = picked);
  }

  Future<void> _pickMarket() async {
    final picked = await _pickOption<Market>(
      title: t.investing.assets.market,
      options: Market.values,
      selected: _market,
      label: marketLabel,
    );
    if (picked != null) setState(() => _market = picked);
  }

  Future<void> _pickCurrency() async {
    final picked = await _pickOption<Currency>(
      title: t.investing.assets.currency,
      options: Currency.values,
      selected: _currency,
      label: (c) => '${c.code} (${c.symbol})',
    );
    if (picked != null) setState(() => _currency = picked);
  }

  Future<void> _pickFiBasis() async {
    final picked = await _pickOption<FixedIncomeBasis>(
      title: t.investing.assets.fiBasis,
      options: FixedIncomeBasis.values,
      selected: _fiBasis,
      label: fixedIncomeBasisLabel,
    );
    if (picked != null) setState(() => _fiBasis = picked);
  }

  Future<T?> _pickOption<T>({
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) label,
  }) => showOptionPickerSheet<T>(
    context: context,
    title: title,
    options: options,
    selected: selected,
    label: label,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_loadingFormData) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditing ? t.investing.assets.edit : t.investing.assets.add,
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
              FinancoFormSection(
                label: t.investing.assets.sectionInstrument,
                children: [
                  FinancoTextField(
                    controller: _tickerController,
                    label: t.investing.assets.ticker,
                    hintText: t.investing.assets.tickerHint,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  FinancoTextField(
                    controller: _nameController,
                    label: t.investing.assets.name,
                    hintText: t.investing.assets.nameHint,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  FinancoPickerField(
                    label: t.investing.assets.kind,
                    value: assetKindLabel(_kind),
                    placeholder: t.investing.assets.kind,
                    onTap: () => unawaited(_pickKind()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FinancoPickerField(
                          label: t.investing.assets.market,
                          value: marketLabel(_market),
                          placeholder: t.investing.assets.market,
                          onTap: () => unawaited(_pickMarket()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FinancoPickerField(
                          label: t.investing.assets.currency,
                          value: _currency.code,
                          placeholder: t.investing.assets.currency,
                          onTap: () => unawaited(_pickCurrency()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinancoFormSection(
                label: t.investing.assets.sectionCustody,
                children: [
                  FinancoPickerField(
                    label: t.investing.assets.institution,
                    value: _institutionName,
                    placeholder: t.investing.assets.pickInstitution,
                    isError: _institutionId == null,
                    onTap: () => unawaited(_pickInstitution()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinancoFormSection(
                label: t.investing.assets.sectionAllocation,
                children: [
                  FinancoPickerField(
                    label: t.investing.assets.allocationClass,
                    value: _className,
                    placeholder: _classes.isEmpty
                        ? t.investing.assets.noClasses
                        : t.investing.assets.pickClass,
                    onTap: () => unawaited(_pickClass()),
                  ),
                  if (_allocationClassId != null) ...[
                    const SizedBox(height: 12),
                    FinancoTextField(
                      controller: _allocationTargetController,
                      label: t.investing.assets.allocationTarget,
                      hintText: t.investing.assets.allocationTargetHint,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ],
              ),
              if (_kind == AssetKind.fixedIncome) ...[
                const SizedBox(height: 20),
                FinancoFormSection(
                  label: t.investing.assets.sectionFixedIncome,
                  children: [
                    FinancoPickerField(
                      label: t.investing.assets.fiBasis,
                      value: fixedIncomeBasisLabel(_fiBasis),
                      placeholder: t.investing.assets.fiBasis,
                      onTap: () => unawaited(_pickFiBasis()),
                    ),
                    const SizedBox(height: 12),
                    FinancoTextField(
                      controller: _fiRateController,
                      label: t.investing.assets.fiRate,
                      hintText: t.investing.assets.fiRateHint,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ],
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
