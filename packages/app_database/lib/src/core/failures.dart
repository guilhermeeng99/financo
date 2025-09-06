abstract class Failure {
  const Failure(this.message);
  final String message;
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NoChangesFailure extends ValidationFailure {
  const NoChangesFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class DuplicateEntryFailure extends Failure {
  const DuplicateEntryFailure(super.message);
}
