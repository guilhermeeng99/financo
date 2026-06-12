import 'dart:async';

import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Profile entry pinned at the bottom of the sidebar: avatar (photo with
/// initial fallback), the user's name when [expanded], and a chevron.
/// [user] may be null while the auth state is unresolved — the tile then
/// falls back to the generic profile label.
class SidebarProfileTile extends StatelessWidget {
  const SidebarProfileTile({
    required this.expanded,
    required this.user,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final bool expanded;
  final UserEntity? user;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: isActive
            ? colors.primary.withValues(alpha: 0.10)
            : colors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _UserAvatar(user: user, colors: colors),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user?.name ?? t.nav.profile,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          t.nav.profile,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 11,
                    color: colors.onBackgroundLight,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, required this.colors});

  final UserEntity? user;
  final AppColorsData colors;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    final initial = _initialOf(user?.name);
    return SizedBox(
      width: 36,
      height: 36,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initialFallback(initial),
              )
            : _initialFallback(initial),
      ),
    );
  }

  Widget _initialFallback(String initial) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.18),
            colors.primaryLight.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static String _initialOf(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }
}
