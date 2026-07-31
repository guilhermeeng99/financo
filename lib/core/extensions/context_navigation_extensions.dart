import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers that stay correct on a deep link.
extension ContextNavigationExtensions on BuildContext {
  /// Closes the current page, falling back to [fallbackRoute] when there is
  /// nothing to pop.
  ///
  /// Every sub-page in this app is reachable by URL on web, and a route opened
  /// directly has an empty stack: `pop()` then does nothing and the user is
  /// stranded on a page with no way out — which is exactly what happened on
  /// `/investing/transaction/add` before the 2026-07-31 audit. Three call
  /// sites had grown three different answers to this (`_leave`,
  /// `_navigateBack`, and a bare `if (canPop) pop()` with no fallback at all).
  ///
  /// [result] is forwarded to `pop` so a form can still report "saved" to the
  /// page that pushed it; it is meaningless on the fallback path, where no one
  /// is awaiting a result.
  ///
  /// Example:
  /// ```dart
  /// context.popOrGo(AppRoutes.investingTransactions, result: true);
  /// ```
  void popOrGo(String fallbackRoute, {Object? result}) {
    if (canPop()) {
      pop(result);
      return;
    }
    go(fallbackRoute);
  }
}
