import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Carousel position indicator. The active dot stretches into a short pill
/// while the others stay round — same pattern Apple's onboarding flows use
/// (subtler than always-equal dots, more iOS than Material's `TabBar`).
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    required this.count,
    required this.activeIndex,
    super.key,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary
                : colors.onBackgroundLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
