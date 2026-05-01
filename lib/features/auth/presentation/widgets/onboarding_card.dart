import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// One step of the onboarding carousel — large color-tinted icon tile,
/// bold title, supportive body. Each step gets its own accent so the
/// three pages feel distinct as the user swipes through.
class OnboardingCard extends StatelessWidget {
  const OnboardingCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    super.key,
  });

  final FaIconData icon;
  final Color accent;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  accent.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Center(
              child: FaIcon(icon, size: 56, color: accent),
            ),
          )
              .animate()
              .scale(
                duration: 500.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackgroundLight,
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 350.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
