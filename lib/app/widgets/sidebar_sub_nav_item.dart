import 'dart:async';

import 'package:financo/app/widgets/sidebar_nav_item.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Indented child entry nested under a [SidebarNavItem] (e.g. the
/// payables/receivables shortcuts under Dashboard). Renders nothing while
/// the sidebar is collapsed — sub-items only make sense with labels.
class SidebarSubNavItem extends StatelessWidget {
  const SidebarSubNavItem({
    required this.icon,
    required this.expanded,
    required this.label,
    required this.onTap,
    required this.isActive,
    super.key,
  });

  final FaIconData icon;
  final bool expanded;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!expanded) return const SizedBox.shrink();

    final colors = context.appColors;
    final foreground = isActive ? colors.primary : colors.onBackgroundLight;

    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 1, bottom: 1),
      child: Stack(
        children: [
          if (expanded)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: colors.surfaceVariant,
              ),
            ),
          Material(
            color: isActive
                ? colors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                onTap();
              },
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 38,
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      child: Center(
                        child: FaIcon(icon, size: 15, color: foreground),
                      ),
                    ),
                    if (expanded)
                      Expanded(
                        child: Text(
                          label,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isActive
                                ? colors.onBackground
                                : colors.onBackgroundLight,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
