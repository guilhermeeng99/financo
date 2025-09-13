class ValidationResult<TData, TErrors> {
  factory ValidationResult.failure(TErrors errors) {
    return ValidationResult._(errors: errors);
  }

  factory ValidationResult.success(TData data) {
    return ValidationResult._(data: data);
  }

  const ValidationResult._({this.data, this.errors});

  final TData? data;

  final TErrors? errors;

  bool get isSuccess => data != null;

  bool get isFailure => errors != null;
}
