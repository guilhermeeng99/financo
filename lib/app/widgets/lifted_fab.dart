import 'package:financo/app/widgets/sub_page_scope.dart';
import 'package:flutter/material.dart';

/// Wraps a FloatingActionButton so it sits above the floating mobile bottom
/// bar. Inner pages have their own Scaffold and don't know about the shell's
/// bottomNavigationBar, so without this wrapper the FAB renders at the very
/// bottom of the screen and gets covered by the bar.
///
/// Adds no extra padding on tablet/web (sidebar layout has no bottom bar)
/// nor on sub-pages (SubPageScope hides the bottom bar, so the lift would
/// leave the FAB floating in empty space).
class LiftedFab extends StatelessWidget {
  const LiftedFab({required this.child, super.key});

  final Widget child;

  // Floating bar = 16 padding + 64 container + 16 padding = 96. We lift the
  // FAB slightly less so it visually anchors just above the bar.
  static const double _liftAmount = 80;
  static const double _mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;
    if (!isMobile) return child;
    return ValueListenableBuilder<int>(
      valueListenable: subPageDepthListenable,
      builder: (context, depth, _) {
        if (depth > 0) return child;
        return Padding(
          padding: const EdgeInsets.only(bottom: _liftAmount),
          child: child,
        );
      },
    );
  }
}
