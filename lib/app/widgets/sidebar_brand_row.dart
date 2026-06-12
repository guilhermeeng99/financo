import 'dart:async';

import 'package:financo/core/constants/app_constants.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Top zone of the sidebar: brand mark + app name (tappable, navigates
/// home via [onNavigateHome]) and the collapse/expand toggle. Lays out as
/// a row when [expanded] and stacks vertically when collapsed.
class SidebarBrandRow extends StatelessWidget {
  const SidebarBrandRow({
    required this.expanded,
    required this.onNavigateHome,
    required this.onToggle,
    super.key,
  });

  final bool expanded;
  final VoidCallback onNavigateHome;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: expanded ? 44 : 76,
      child: expanded
          ? Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        unawaited(HapticFeedback.selectionClick());
                        onNavigateHome();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 52,
                            child: Center(child: _BrandMark()),
                          ),
                          Expanded(
                            child: Text(
                              AppConstants.appName,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: colors.onBackground,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _SidebarToggleButton(expanded: expanded, onTap: onToggle),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BrandMark(
                  onTap: () {
                    unawaited(HapticFeedback.selectionClick());
                    onNavigateHome();
                  },
                ),
                const SizedBox(height: 8),
                _SidebarToggleButton(
                  expanded: expanded,
                  onTap: onToggle,
                  compact: true,
                ),
              ],
            ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  const _SidebarToggleButton({
    required this.expanded,
    required this.onTap,
    this.compact = false,
  });

  final bool expanded;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final width = compact ? 36.0 : 32.0;
    final height = compact ? 24.0 : 32.0;
    return Tooltip(
      message: expanded ? t.nav.collapseSidebar : t.nav.expandSidebar,
      child: Material(
        color: colors.surfaceVariant.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: width,
            height: height,
            child: Center(
              child: FaIcon(
                expanded
                    ? FontAwesomeIcons.chevronLeft
                    : FontAwesomeIcons.chevronRight,
                size: compact ? 10 : 12,
                color: colors.onBackgroundLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              AppConstants.appName.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
