sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected error occurred.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

final class AiFailure extends Failure {
  const AiFailure([super.message = 'AI service error occurred.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error.']);
}

/// Raised when a successfully authenticated user is not in the access
/// allowlist (`allowed_emails/`) and is not the master. Carries the email
/// so the UI can show the user which address to ask the master to enable.
final class AccessDeniedFailure extends Failure {
  const AccessDeniedFailure(this.email)
    : super('Access restricted for this account.');

  final String email;
}

/// Raised when an asset-holding allocation would exceed the account's
/// available (un-allocated) balance. Carries `available` (a raw amount) so
/// the UI boundary can format + localise it — the domain stays i18n-free.
final class AllocationExceedsBalanceFailure extends Failure {
  const AllocationExceedsBalanceFailure(this.available)
    : super('Allocation exceeds available balance.');

  final double available;
}

/// Raised when sibling asset-class target percentages would sum past 100%.
/// Carries the still-available percent and whether the scope is root classes
/// or subclasses, so the UI can localise the message.
final class TargetSumExceededFailure extends Failure {
  const TargetSumExceededFailure({
    required this.availablePercent,
    required this.isRoot,
  }) : super('Target percent sum exceeds 100%.');

  final double availablePercent;
  final bool isRoot;
}

/// Raised when a user-supplied name is blank after trimming (e.g. asset
/// class names). The UI boundary localises the copy.
final class EmptyNameFailure extends Failure {
  const EmptyNameFailure() : super('Name must not be empty.');
}

/// Raised when a monetary amount that must be zero or positive turns out
/// negative (e.g. asset-holding amounts).
final class NegativeAmountFailure extends Failure {
  const NegativeAmountFailure() : super('Amount must be at least zero.');
}

/// Raised when an asset-class target percent falls outside the [0, 100]
/// range.
final class TargetPercentOutOfRangeFailure extends Failure {
  const TargetPercentOutOfRangeFailure()
    : super('Target percent must be between 0 and 100.');
}

/// Raised when the parent referenced by an asset class does not exist in
/// the user's class list.
final class ParentAssetClassNotFoundFailure extends Failure {
  const ParentAssetClassNotFoundFailure() : super('Parent class not found.');
}

/// Raised when an asset class would be nested under a subclass — the
/// hierarchy allows a single nesting level (docs/specs/investments.md §1).
final class SubclassCannotBeParentFailure extends Failure {
  const SubclassCannotBeParentFailure()
    : super('A subclass cannot be the parent of another subclass.');
}

/// Raised when an asset class declares itself as its own parent.
final class SelfParentAssetClassFailure extends Failure {
  const SelfParentAssetClassFailure()
    : super('A class cannot be its own parent.');
}

/// Raised when demoting a root asset class that still owns subclasses —
/// the demotion would create a two-level chain.
final class ClassOwnsSubclassesFailure extends Failure {
  const ClassOwnsSubclassesFailure()
    : super('This class still owns subclasses.');
}

/// Raised when deleting an asset class that subclasses still reference.
/// Carries the blocking count so the UI can localise a helpful prompt.
final class AssetClassHasSubclassesFailure extends Failure {
  const AssetClassHasSubclassesFailure(this.count)
    : super('Subclasses still reference this class.');

  final int count;
}

/// Raised when deleting an asset class that holdings still reference.
/// Carries the blocking count so the UI can localise a helpful prompt.
final class AssetClassHasHoldingsFailure extends Failure {
  const AssetClassHasHoldingsFailure(this.count)
    : super('Holdings still reference this class.');

  final int count;
}

/// Raised when a holding references an asset class that no longer exists.
final class AssetClassNotFoundFailure extends Failure {
  const AssetClassNotFoundFailure() : super('Asset class not found.');
}

/// Raised when a holding points at a non-investment account
/// (docs/specs/investments.md §2 rule 1).
final class HoldingAccountNotInvestmentFailure extends Failure {
  const HoldingAccountNotInvestmentFailure()
    : super('Holdings can only be attached to investment accounts.');
}

/// Raised when a holding points at a root asset class — money lives on
/// subclasses only (docs/specs/investments.md §2 rule 4).
final class HoldingRequiresSubclassFailure extends Failure {
  const HoldingRequiresSubclassFailure()
    : super('Holdings must point at a subclass.');
}

/// Raised when an email address fails basic format validation.
final class InvalidEmailFormatFailure extends Failure {
  const InvalidEmailFormatFailure() : super('Invalid email address.');
}

/// Raised when trying to allowlist the master email — the master has
/// implicit access, so the addition is rejected as a no-op.
final class MasterEmailAlreadyAllowedFailure extends Failure {
  const MasterEmailAlreadyAllowedFailure()
    : super('The master already has access.');
}

/// Raised when creating a budget for a category that already has one —
/// budgets are unique per (userId, categoryId).
final class DuplicateBudgetCategoryFailure extends Failure {
  const DuplicateBudgetCategoryFailure()
    : super('A budget already exists for this category.');
}
