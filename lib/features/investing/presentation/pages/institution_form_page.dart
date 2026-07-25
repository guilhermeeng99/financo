import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/utils/validators.dart';import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/usecases/create_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/update_institution_usecase.dart';
import 'package:financo/features/investing/presentation/pages/institutions_page.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Create/edit form for a custody institution. See
/// `docs/specs/institutions.md`.
class InstitutionFormPage extends StatefulWidget {
  const InstitutionFormPage({super.key, this.existing});

  final Institution? existing;

  @override
  State<InstitutionFormPage> createState() => _InstitutionFormPageState();
}

class _InstitutionFormPageState extends State<InstitutionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late InstitutionKind _kind;
  late Currency _currency;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _kind = existing?.kind ?? InstitutionKind.broker;
    _currency = existing?.currency ?? Currency.brl;
    if (existing != null) _nameController.text = existing.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _userId => context.currentUserId;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final existing = widget.existing;
    final institution = Institution(
      id: existing?.id ?? '',
      userId: _userId,
      name: _nameController.text.trim(),
      kind: _kind,
      currency: _currency,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    final result = _isEditing
        ? await GetIt.I<UpdateInstitutionUseCase>()(institution)
        : await GetIt.I<CreateInstitutionUseCase>()(institution);

    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context
        ..showSnack(
          _isEditing
              ? t.investing.institutions.updated
              : t.investing.institutions.created,
        )
        ..pop(true),
    );
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() => _submitting = true);
    final result = await GetIt.I<DeleteInstitutionUseCase>()(existing);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) => context
        ..showSnack(t.investing.institutions.deleted)
        ..pop(true),
    );
  }

  Future<void> _pickKind() async {
    final picked = await _pickOption<InstitutionKind>(
      title: t.investing.institutions.kind,
      options: InstitutionKind.values,
      selected: _kind,
      label: institutionKindLabel,
    );
    if (picked != null) setState(() => _kind = picked);
  }

  Future<void> _pickCurrency() async {
    final picked = await _pickOption<Currency>(
      title: t.investing.institutions.currency,
      options: Currency.values,
      selected: _currency,
      label: (c) => '${c.code} (${c.symbol})',
    );
    if (picked != null) setState(() => _currency = picked);
  }

  Future<T?> _pickOption<T>({
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) label,
  }) {
    final colors = context.appColors;
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: ctx.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(label(option)),
                trailing: option == selected
                    ? FaIcon(
                        FontAwesomeIcons.check,
                        size: 14,
                        color: colors.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
              ? t.investing.institutions.edit
              : t.investing.institutions.add,
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
                label: t.investing.institutions.name,
                children: [
                  FinancoTextField(
                    controller: _nameController,
                    label: t.investing.institutions.name,
                    hintText: t.investing.institutions.nameHint,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  FinancoPickerField(
                    label: t.investing.institutions.kind,
                    value: institutionKindLabel(_kind),
                    placeholder: t.investing.institutions.kind,
                    onTap: () => unawaited(_pickKind()),
                  ),
                  const SizedBox(height: 12),
                  FinancoPickerField(
                    label: t.investing.institutions.currency,
                    value: '${_currency.code} (${_currency.symbol})',
                    placeholder: t.investing.institutions.currency,
                    onTap: () => unawaited(_pickCurrency()),
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
