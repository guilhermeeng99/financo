import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/presentation/widgets/category_color_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_icon_picker.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_class_usecase.dart';
import 'package:financo/features/investments/domain/usecases/delete_asset_class_usecase.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_class_usecase.dart';
import 'package:financo/features/investments/presentation/cubit/asset_class_form_cubit.dart';
import 'package:financo/features/investments/presentation/widgets/parent_class_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Args carried through `context.push(AppRoutes.assetClass, extra: ...)`.
/// Two flavours are mutually exclusive:
///   * `existing != null` → edit mode for the given class.
///   * `presetParent != null` → create mode pre-bound to a root parent.
/// Both null → blank create flow (root).
class AssetClassFormArgs {
  const AssetClassFormArgs({this.existing, this.presetParent});

  final AssetClassEntity? existing;
  final AssetClassEntity? presetParent;
}

class AssetClassFormPage extends StatefulWidget {
  const AssetClassFormPage({
    super.key,
    this.existing,
    this.presetParent,
  });

  final AssetClassEntity? existing;

  /// Optional preset parent — set when the user taps "+ subclasse" on
  /// a root class row to pre-fill the parent picker.
  final AssetClassEntity? presetParent;

  @override
  State<AssetClassFormPage> createState() => _AssetClassFormPageState();
}

class _AssetClassFormPageState extends State<AssetClassFormPage> {
  late final Future<_FormPrep> _prep;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is Authenticated ? authState.user.id : '';
    _prep = _fetchPrep();
  }

  Future<_FormPrep> _fetchPrep() async {
    final result = await GetIt.I<GetAssetClassesUseCase>()(userId: _userId);
    return result.fold(
      (_) => const _FormPrep(count: 0, classes: []),
      (list) => _FormPrep(count: list.length, classes: list),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FutureBuilder<_FormPrep>(
      future: _prep,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final prep = snapshot.data!;
        return BlocProvider(
          create: (_) => AssetClassFormCubit(
            createAssetClass: GetIt.I<CreateAssetClassUseCase>(),
            updateAssetClass: GetIt.I<UpdateAssetClassUseCase>(),
            userId: _userId,
            existingAssetClass: widget.existing,
            existingClassCount: prep.count,
            presetParentId: widget.presetParent?.id,
            presetParentIcon: widget.presetParent?.icon,
            presetParentColor: widget.presetParent?.color,
          ),
          child: _AssetClassFormView(
            existing: widget.existing,
            allClasses: prep.classes,
          ),
        );
      },
    );
  }
}

class _FormPrep {
  const _FormPrep({required this.count, required this.classes});
  final int count;
  final List<AssetClassEntity> classes;
}

class _AssetClassFormView extends StatefulWidget {
  const _AssetClassFormView({
    required this.existing,
    required this.allClasses,
  });

  final AssetClassEntity? existing;
  final List<AssetClassEntity> allClasses;

  @override
  State<_AssetClassFormView> createState() => _AssetClassFormViewState();
}

class _AssetClassFormViewState extends State<_AssetClassFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AssetClassFormCubit>().state;
    _nameController.text = state.name;
    _targetController.text = state.targetPercent == 0
        ? ''
        : state.targetPercent.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.investments.deleteClassTitle,
      message: t.investments.deleteClassConfirm,
      confirmLabel: t.general.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final useCase = GetIt.I<DeleteAssetClassUseCase>();
    final state = context.read<AssetClassFormCubit>().state;
    final result = await useCase(id: existing.id, userId: state.userId);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(localizedFailure(failure)),
      (_) {
        context
          ..showSnack(t.investments.deleteClassSuccess)
          ..pop(true);
      },
    );
  }

  Future<void> _pickParent() async {
    final cubit = context.read<AssetClassFormCubit>();
    // When editing a root that already has children, we never let the
    // user demote it — that would create a 2-level chain and break
    // §1 rule 1. Same when the row IS a root being demoted with its
    // own subclasses around.
    final selectedId = cubit.state.parentId;
    final picked = await showParentClassPickerSheet(
      context: context,
      classes: _eligibleParents(),
      selectedId: selectedId,
    );
    if (picked == null || !mounted) return;
    cubit.updateParent(picked.parent);
  }

  /// Eligible parents = all roots EXCEPT the row currently being
  /// edited (a class cannot be its own parent).
  List<AssetClassEntity> _eligibleParents() {
    final existingId = widget.existing?.id;
    return widget.allClasses
        .where((c) => c.parentId == null && c.id != existingId)
        .toList();
  }

  AssetClassEntity? _resolveParentEntity(String? parentId) {
    if (parentId == null) return null;
    for (final c in widget.allClasses) {
      if (c.id == parentId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocConsumer<AssetClassFormCubit, AssetClassFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          context
            ..showSnack(
              state.isEditing
                  ? t.investments.classUpdated
                  : t.investments.classCreated,
            )
            ..pop(true);
        } else if (state.status == FormStatus.failure &&
            state.failure != null) {
          context.showSnack(localizedFailure(state.failure));
        }
      },
      builder: (context, state) {
        final cubit = context.read<AssetClassFormCubit>();
        final isSubmitting = state.status == FormStatus.submitting;
        final parentEntity = _resolveParentEntity(state.parentId);
        final title = state.isEditing
            ? (state.isSubclass
                  ? t.investments.editSubclassTitle
                  : t.investments.editClassTitle)
            : (state.isSubclass
                  ? t.investments.newSubclassTitle
                  : t.investments.newClassTitle);
        return Scaffold(
          backgroundColor: colors.background,
          appBar: FinancoLargeAppBar(
            title: title,
            showBack: true,
            actions: state.isEditing
                ? [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FinancoAppBarIconButton(
                        icon: FontAwesomeIcons.trash,
                        tooltip: t.general.delete,
                        color: colors.error,
                        onPressed: () => unawaited(_handleDelete()),
                      ),
                    ),
                  ]
                : const [],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  FinancoFormSection(
                    label: t.investments.sectionIdentity,
                    children: [
                      FinancoTextField(
                        controller: _nameController,
                        label: t.investments.classNameLabel,
                        hintText: state.isSubclass
                            ? t.investments.subclassNameHint
                            : t.investments.classNameHint,
                        validator: Validators.requiredField,
                        onChanged: cubit.updateName,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.investments.parentLabel,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FinancoPickerField(
                        label: t.investments.parentLabel,
                        value: parentEntity?.name,
                        placeholder: t.investments.parentPlaceholder,
                        onTap: () => unawaited(_pickParent()),
                      ),
                      // Appearance pickers are root-only — subclasses
                      // mirror the parent's icon + color and the
                      // current state already carries the snapshot.
                      if (!state.isSubclass) ...[
                        const SizedBox(height: 16),
                        Text(
                          t.investments.classIcon,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CategoryIconPickerLauncher(
                          selectedIcon: state.icon,
                          color: state.color,
                          onChanged: cubit.updateIcon,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.investments.classColor,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CategoryColorPicker(
                          selected: state.color,
                          onChanged: cubit.updateColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  FinancoFormSection(
                    label: t.investments.sectionTarget,
                    children: [
                      Text(
                        state.isSubclass
                            ? t.investments.targetSubclassHelper
                            : t.investments.targetHelper,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FinancoTextField(
                        controller: _targetController,
                        label: t.investments.targetPercentLabel,
                        keyboardType: TextInputType.number,
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            widthFactor: 1,
                            child: Text('%'),
                          ),
                        ),
                        onChanged: (raw) {
                          final parsed = double.tryParse(
                            raw.replaceAll(',', '.'),
                          );
                          cubit.updateTargetPercent(parsed ?? 0);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: FinancoSubmitBar(
            label: state.isEditing
                ? t.investments.saveClass
                : (state.isSubclass
                      ? t.investments.createSubclass
                      : t.investments.createClass),
            isEnabled: state.isValid && !isSubmitting,
            isLoading: isSubmitting,
            onSubmit: () {
              if (_formKey.currentState?.validate() ?? false) {
                unawaited(cubit.submit());
              }
            },
          ),
        );
      },
    );
  }
}
