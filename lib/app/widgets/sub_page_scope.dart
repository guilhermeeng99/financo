import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Counter of how many sub-pages (pages pushed inside the shell that aren't
/// one of the four primary tabs) are currently mounted. Wrap a sub-page in
/// [SubPageScope] and the shell hides its bottom bar / month filter while
/// that page is visible.
///
/// We track depth (not just a boolean) so concurrent transitions — where
/// the outgoing page is still mid-dispose while the incoming page is
/// already mounted — don't briefly toggle the bar back on.
final ValueNotifier<int> _subPageDepth = ValueNotifier<int>(0);

/// Read-only listenable for the shell to subscribe to.
ValueListenable<int> get subPageDepthListenable => _subPageDepth;

/// True when at least one sub-page is mounted.
bool get isOnSubPage => _subPageDepth.value > 0;

/// Wrap a sub-page's body so the shell knows to hide the bottom bar
/// while it's mounted. Drop-in:
///
///   return SubPageScope(
///     child: Scaffold(...),
///   );
class SubPageScope extends StatefulWidget {
  const SubPageScope({required this.child, super.key});

  final Widget child;

  @override
  State<SubPageScope> createState() => _SubPageScopeState();
}

class _SubPageScopeState extends State<SubPageScope> {
  // Whether this scope has accounted for itself in the global depth. Both
  // increment and decrement are deferred to post-frame callbacks because:
  //   • initState fires during the parent build (locked tree)
  //   • dispose may fire during a pop's commit phase (locked tree)
  // Notifying the shell's ValueListenableBuilder in either situation would
  // throw "setState called during build" / "tree was locked".
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _subPageDepth.value = _subPageDepth.value + 1;
      _registered = true;
    });
  }

  @override
  void dispose() {
    if (_registered) {
      // Schedule on the next frame so the notification fires after the
      // current build/commit phase. Captures `_subPageDepth` directly
      // (no `mounted` check needed — it's a top-level singleton).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _subPageDepth.value = _subPageDepth.value - 1;
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
