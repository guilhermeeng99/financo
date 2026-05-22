import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';

/// Turns a domain [Failure] into a user-facing, localised message.
///
/// This is the single UI boundary where failures become copy the user reads
/// (ErrorView, SnackBars). Domain and data layers stay free of i18n: they
/// raise typed failures — optionally carrying data (amounts, percentages) —
/// and never English sentences. Generic failure types map to `t.errors.*`;
/// [ValidationFailure] already carries a localised message from its producer.
///
/// A `null` failure resolves to the generic "unexpected" message, so callers
/// holding a nullable `state.failure` can drop their own fallback.
///
/// Example:
/// ```dart
/// ScaffoldMessenger.of(context).showSnackBar(
///   SnackBar(content: Text(localizedFailure(state.failure))),
/// );
/// ```
String localizedFailure(Failure? failure) {
  return switch (failure) {
    null => t.errors.unexpected,
    ValidationFailure() => failure.message,
    AuthFailure() => t.errors.auth,
    AiFailure() => t.errors.ai,
    AccessDeniedFailure() => t.errors.accessDenied,
    AllocationExceedsBalanceFailure() => t.investments.allocationExceedsBalance(
      available: formatCurrency(failure.available),
    ),
    TargetSumExceededFailure() => failure.isRoot
        ? t.investments.targetSumExceedsRoot(
            available: '${failure.availablePercent.toStringAsFixed(0)}%',
          )
        : t.investments.targetSumExceedsSub(
            available: '${failure.availablePercent.toStringAsFixed(0)}%',
          ),
    ServerFailure() => t.errors.server,
  };
}
