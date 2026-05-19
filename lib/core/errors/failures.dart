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
