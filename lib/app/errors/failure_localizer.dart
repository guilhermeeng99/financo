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
/// context.showSnack(localizedFailure(state.failure));
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
    EmptyNameFailure() => t.errors.emptyName,
    NegativeAmountFailure() => t.errors.negativeAmount,
    TargetPercentOutOfRangeFailure() => t.investments.targetPercentOutOfRange,
    ParentAssetClassNotFoundFailure() => t.investments.parentClassNotFound,
    SubclassCannotBeParentFailure() => t.investments.subclassCannotBeParent,
    SelfParentAssetClassFailure() => t.investments.classCannotBeOwnParent,
    ClassOwnsSubclassesFailure() => t.investments.classOwnsSubclasses,
    AssetClassHasSubclassesFailure() => t.investments
        .deleteBlockedBySubclasses(count: failure.count),
    AssetClassHasHoldingsFailure() => t.investments.deleteBlockedByHoldings(
      count: failure.count,
    ),
    AssetClassNotFoundFailure() => t.investments.assetClassNotFound,
    HoldingAccountNotInvestmentFailure() =>
      t.investments.holdingAccountNotInvestment,
    HoldingRequiresSubclassFailure() => t.investments.holdingRequiresSubclass,
    InvalidEmailFormatFailure() => t.validators.emailInvalid,
    MasterEmailAlreadyAllowedFailure() => t.masterPanel.masterAlreadyAllowed,
    DuplicateBudgetCategoryFailure() => t.budgets.duplicateCategory,
    ServerFailure() => t.errors.server,
  };
}
