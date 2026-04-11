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

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}

final class AiFailure extends Failure {
  const AiFailure([super.message = 'AI service error occurred.']);
}
