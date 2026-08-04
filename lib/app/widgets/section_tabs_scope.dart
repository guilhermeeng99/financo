import 'package:financo/app/widgets/financo_section_tabs.dart';
import 'package:flutter/foundation.dart';

/// Tabs the current route's group should offer, or empty when there are none.
///
/// Published by the shell (the only widget that knows both the viewport width
/// and the current location) and read by `FinancoLargeAppBar`. It has to be a
/// global rather than an inherited widget because `preferredSize` is a plain
/// getter with no `BuildContext` — the app bar must know how much height to
/// reserve *before* it builds. Same reason `subPageDepthListenable` exists.
final ValueNotifier<List<SectionTab>> _sectionTabs =
    ValueNotifier<List<SectionTab>>(const []);

/// Current value — the only accessor. Deliberately not exposed as a
/// `ValueListenable`: nothing may subscribe, because [publishSectionTabs] is
/// called from the shell's `build` and notifying a listener mid-build throws
/// "setState during build". The app bar reads this synchronously instead, and
/// the page rebuild that follows every route change repaints it.
List<SectionTab> get currentSectionTabs => _sectionTabs.value;

/// Called by the shell on every route/layout change. Comparing routes (not
/// list identity) keeps a rebuild from firing when the same group is
/// recomputed — `sectionTabsFor` returns fresh instances each call because
/// the labels come from slang.
void publishSectionTabs(List<SectionTab> tabs) {
  if (_sameGroup(_sectionTabs.value, tabs)) return;
  _sectionTabs.value = tabs;
}

bool _sameGroup(List<SectionTab> current, List<SectionTab> next) {
  if (current.length != next.length) return false;
  for (var i = 0; i < current.length; i++) {
    if (current[i].route != next[i].route) return false;
  }
  return true;
}
