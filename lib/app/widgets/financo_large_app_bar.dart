import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Premium, iOS-style large-title app bar. The title is left-aligned and
/// bold; the bar blends with the scaffold background (no surface contrast,
/// no shadow, no scroll-under tint) so it reads as part of the page rather
/// than a separate Material lane.
///
/// Pass `showBack: true` for sub-pages (accounts, categories) so the bar
/// renders a soft circular back chevron on the left while keeping the
/// large-title aesthetic.
///
/// Example:
///   Scaffold(
///     appBar: FinancoLargeAppBar(title: t.bills.title),
///     body: ...,
///   )
class FinancoLargeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FinancoLargeAppBar({
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBack = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  double get _height => subtitle != null ? 88 : 72;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack ? const _BackChip() : null,
      leadingWidth: showBack ? 56 : null,
      titleSpacing: showBack ? 4 : 20,
      toolbarHeight: _height,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.textTheme.displayMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Material(
          color: colors.surfaceVariant,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  size: 13,
                  color: colors.onBackground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
