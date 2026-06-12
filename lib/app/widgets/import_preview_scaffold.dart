import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared chrome for the CSV import-preview pages (accounts, categories,
/// transactions): large app bar, type pill toggle, optional notice banners,
/// the row list, the importing progress overlay, and the bottom submit bar.
///
/// Pages stay responsible for their state handling ([onStateChanged]) and
/// for building [typeToggle], [notices] and [list]; the scaffold owns the
/// layout, paddings and bloc wiring so every import preview behaves
/// identically.
///
/// ```dart
/// ImportPreviewScaffold<AccountsCubit, AccountsState>(
///   title: t.accounts.importPageTitle,
///   subtitle: t.accounts.importPageSubtitle,
///   onStateChanged: _onCubitState,
///   typeToggle: _buildTypeToggle(),
///   list: _ImportList(...),
///   progressOverlayOf: _progressOverlayOf,
///   submitLabel: t.accounts.importSubmit(count: _items.length),
///   isSubmitting: (state) => state is AccountsImporting,
///   canSubmit: _items.isNotEmpty,
///   onSubmit: _onSubmit,
/// )
/// ```
class ImportPreviewScaffold<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const ImportPreviewScaffold({
    required this.title,
    required this.subtitle,
    required this.onStateChanged,
    required this.typeToggle,
    required this.list,
    required this.progressOverlayOf,
    required this.submitLabel,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onSubmit,
    this.notices = const [],
    super.key,
  });

  final String title;
  final String subtitle;

  /// `BlocListener` callback — success/error snackbars and navigation.
  final void Function(BuildContext context, S state) onStateChanged;

  /// The feature's `FinancoPillToggle`; the scaffold adds the padding.
  final Widget typeToggle;

  /// Optional warning banners/pills rendered between the toggle and [list].
  final List<Widget> notices;

  /// The preview list; the scaffold wraps it in `Expanded`.
  final Widget list;

  /// Maps an in-progress import state to its overlay; return null for any
  /// other state so the overlay stays hidden.
  final ImportProgressOverlay? Function(S state) progressOverlayOf;

  final String submitLabel;

  /// Whether the submit bar should render its loading style for [S].
  final bool Function(S state) isSubmitting;

  final bool canSubmit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listener: onStateChanged,
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: FinancoLargeAppBar(
          title: title,
          subtitle: subtitle,
          showBack: true,
        ),
        body: Stack(children: [_buildContent(), _buildProgressOverlay()]),
        bottomNavigationBar: _buildSubmitBar(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: typeToggle,
        ),
        for (final notice in notices)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: notice,
          ),
        Expanded(child: list),
      ],
    );
  }

  Widget _buildProgressOverlay() {
    return BlocBuilder<B, S>(
      buildWhen: (previous, current) =>
          progressOverlayOf(previous) != null ||
          progressOverlayOf(current) != null,
      builder: (context, state) =>
          progressOverlayOf(state) ?? const SizedBox.shrink(),
    );
  }

  Widget _buildSubmitBar() {
    return BlocBuilder<B, S>(
      builder: (context, state) => FinancoSubmitBar(
        label: submitLabel,
        isLoading: isSubmitting(state),
        isEnabled: canSubmit,
        onSubmit: onSubmit,
      ),
    );
  }
}
