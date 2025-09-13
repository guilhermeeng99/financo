import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

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

  static T? validateField<T>(
    T Function() validator,
    void Function(String errorMessage) onError,
  ) {
    try {
      return validator();
    } on ValidationException catch (e) {
      logger.e(e.message);
      onError(e.message);
      return null;
    }
  }
}
