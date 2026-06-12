import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Builds the scrollable body of a [FinancoPickerSheet]. Attach
/// [scrollController] to the inner scrollable (`ListView`, `GridView`…)
/// so dragging the list content also drags the sheet.
typedef FinancoPickerSheetBodyBuilder = Widget Function(
  ScrollController scrollController,
);

/// Design-system chrome for modal picker bottom sheets: rounded surface,
/// drag handle and a left-aligned title, shared by every picker so they
/// all speak the same visual language.
///
/// Two variants:
/// * [FinancoPickerSheet.new] — draggable. Wraps a
///   [DraggableScrollableSheet]; [bodyBuilder] fills the space under the
///   title (and optional [header] widgets, e.g. a search field) and must
///   attach the given scroll controller to its scrollable.
/// * [FinancoPickerSheet.fixed] — fixed height. A shrink-wrapped column
///   inside a bottom [SafeArea], for short content (day grid, short
///   lists).
///
/// Example:
/// ```dart
/// showModalBottomSheet<String>(
///   context: context,
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => FinancoPickerSheet(
///     title: t.categories.pickParent,
///     bodyBuilder: (scrollController) => ListView(
///       controller: scrollController,
///       children: const [...],
///     ),
///   ),
/// );
/// ```
class FinancoPickerSheet extends StatelessWidget {
  /// Draggable variant — see class docs for the layout contract.
  const FinancoPickerSheet({
    required this.title,
    required FinancoPickerSheetBodyBuilder this.bodyBuilder,
    this.header = const <Widget>[],
    this.initialChildSize = 0.5,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.85,
    super.key,
  }) : child = null;

  /// Fixed-height variant. [child] is placed directly inside the sheet's
  /// column, so flex widgets (`Flexible`, `Expanded`) are allowed.
  const FinancoPickerSheet.fixed({
    required this.title,
    required Widget this.child,
    super.key,
  }) : bodyBuilder = null,
       header = const <Widget>[],
       initialChildSize = 0.5,
       minChildSize = 0.3,
       maxChildSize = 0.85;

  /// Headline rendered under the drag handle.
  final String title;

  /// Widgets between the title and the body (search field, filters…).
  /// Draggable variant only.
  final List<Widget> header;

  /// Body factory of the draggable variant; `null` on
  /// [FinancoPickerSheet.fixed] sheets.
  final FinancoPickerSheetBodyBuilder? bodyBuilder;

  /// Body of the [FinancoPickerSheet.fixed] variant; `null` on
  /// draggable sheets.
  final Widget? child;

  /// Fraction of the screen the draggable sheet opens at.
  final double initialChildSize;

  /// Smallest fraction the sheet can be dragged down to.
  final double minChildSize;

  /// Largest fraction the sheet can be dragged up to.
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    final fixedChild = child;
    if (fixedChild != null) return _buildFixed(fixedChild);
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (_, scrollController) => _buildDraggable(scrollController),
    );
  }

  Widget _buildFixed(Widget fixedChild) {
    return _SheetSurface(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Grabber(),
            _SheetTitle(title: title),
            fixedChild,
          ],
        ),
      ),
    );
  }

  Widget _buildDraggable(ScrollController scrollController) {
    return _SheetSurface(
      child: Column(
        children: [
          const _Grabber(),
          _SheetTitle(title: title),
          ...header,
          Expanded(child: bodyBuilder!(scrollController)),
        ],
      ),
    );
  }
}

/// Centered muted placeholder for picker bodies with nothing to list —
/// either no data at all or no search hits. Pass the user-facing
/// explanation as [message].
class FinancoPickerSheetEmpty extends StatelessWidget {
  /// Creates the placeholder with the given [message].
  const FinancoPickerSheetEmpty({required this.message, super.key});

  /// User-facing explanation of why the list is empty.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: child,
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: context.appColors.onBackgroundLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.appColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
