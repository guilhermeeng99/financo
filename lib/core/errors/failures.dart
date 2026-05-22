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
