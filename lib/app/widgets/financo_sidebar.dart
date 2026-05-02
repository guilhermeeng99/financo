import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/constants/app_constants.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

const _collapsedWidth = 80.0;
const _expandedWidth = 240.0;
const _animDuration = Duration(milliseconds: 240);
const Curve _animCurve = Curves.easeOutCubic;

/// Web/tablet navigation rail. Three vertical zones, separated by spacing
/// (not dividers): brand + collapse toggle, date scope picker, nav items;
/// then a profile tile pinned at the bottom. Active item carries a left
/// accent bar for the modern Linear/Notion vibe.
class FinancoSidebar extends StatefulWidget {
  const FinancoSidebar({super.key});

  @override
  State<FinancoSidebar> createState() => _FinancoSidebarState();
}

class _FinancoSidebarState extends State<FinancoSidebar> {
  bool _expanded = false;

  void _toggle() {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final location = GoRouterState.of(context).matchedLocation;
    final dateFilter = context.watch<DateFilterCubit>().state;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      width: _expanded ? _expandedWidth : _collapsedWidth,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(
            color: colors.surfaceVariant.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BrandRow(expanded: _expanded, onToggle: _toggle),
              const SizedBox(height: 24),
              _DateScope(
                year: dateFilter.year,
                month: dateFilter.month,
                expanded: _expanded,
                onPrevious: () =>
                    context.read<DateFilterCubit>().previousMonth(),
                onNext: () => context.read<DateFilterCubit>().nextMonth(),
              ),
              const SizedBox(height: 24),
              _NavItem(
                icon: FontAwesomeIcons.house,
                expanded: _expanded,
                label: t.nav.dashboard,
                onTap: () => context.go(AppRoutes.dashboard),
                isActive: location == AppRoutes.dashboard,
              ),
              _NavItem(
                icon: FontAwesomeIcons.fileInvoiceDollar,
                expanded: _expanded,
                label: t.nav.bills,
                onTap: () => context.go(AppRoutes.bills),
                isActive: location.startsWith(AppRoutes.bills),
              ),
              _NavItem(
                icon: FontAwesomeIcons.wandMagicSparkles,
                expanded: _expanded,
                label: t.nav.chat,
                onTap: () => context.go(AppRoutes.chat),
                isActive: location == AppRoutes.chat,
              ),
              const Spacer(),
              _ProfileTile(
                expanded: _expanded,
                user: user,
                isActive: location == AppRoutes.profile,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Center(child: _BrandMark(onTap: onToggle)),
          ),
          if (expanded)
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.expanded,
    required this.label,
    required this.onTap,
    required this.isActive,
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
                      child: Center(
                        child: FaIcon(icon, size: 17, color: foreground),
                      ),
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

class _DateScope extends StatelessWidget {
  const _DateScope({
    required this.year,
    required this.month,
    required this.expanded,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final int month;
  final bool expanded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: expanded
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
          : const EdgeInsets.symmetric(vertical: 6),
      child: expanded ? _expandedView(context) : _collapsedView(context),
    );
  }

  Widget _expandedView(BuildContext context) {
    final colors = context.appColors;
    final label = formatMonthYear(DateTime(year, month));
    return Row(
      children: [
        _StepperBtn(icon: FontAwesomeIcons.chevronLeft, onTap: onPrevious),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _StepperBtn(icon: FontAwesomeIcons.chevronRight, onTap: onNext),
      ],
    );
  }

  Widget _collapsedView(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        _StepperBtn(icon: FontAwesomeIcons.chevronUp, onTap: onPrevious),
        const SizedBox(height: 4),
        Text(
          _shortMonth(month),
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$year',
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontSize: 10,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        _StepperBtn(icon: FontAwesomeIcons.chevronDown, onTap: onNext),
      ],
    );
  }

  static String _shortMonth(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});

  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FaIcon(icon, size: 11, color: colors.onBackgroundLight),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.expanded,
    required this.user,
    required this.isActive,
    required this.onTap,
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
