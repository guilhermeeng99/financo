class ServerException implements Exception {
  const ServerException([this.message = 'An unexpected error occurred.']);

  final String message;
}

class AuthException implements Exception {
  const AuthException([this.message = 'Authentication failed.']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error occurred.']);

  final String message;
}

class AiException implements Exception {
  const AiException([this.message = 'AI service error occurred.']);

  final String message;
}
