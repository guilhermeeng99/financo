import 'dart:async';

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Top-level sidebar navigation entry. The active item carries a left
/// accent bar for the modern Linear/Notion vibe; the [label] is hidden
/// while the sidebar is collapsed ([expanded] false).
class SidebarNavItem extends StatelessWidget {
  const SidebarNavItem({
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
    final colors = context.appColors;
    final foreground = isActive ? colors.primary : colors.onBackgroundLight;
    final iconWidget = FaIcon(icon, size: 17, color: foreground);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          if (isActive)
            Positioned(
              left: 0,
              top: 10,
              bottom: 10,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Material(
            color: isActive
                ? colors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                onTap();
              },
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Center(child: iconWidget),
                    ),
                    if (expanded)
                      Expanded(
                        child: Text(
                          label,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isActive
                                ? colors.onBackground
                                : colors.onBackgroundLight,
                            fontWeight: isActive
                                ? FontWeight.w600
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
