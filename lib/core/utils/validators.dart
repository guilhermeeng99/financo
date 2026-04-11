import 'package:financo/gen/i18n/strings.g.dart';

class Validators {
  const Validators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validators.required;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validators.emailRequired;
    }
    final regex = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return t.validators.emailInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return t.validators.passwordRequired;
    }
    if (value.length < 6) {
      return t.validators.passwordMinLength;
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validators.amountRequired;
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return t.validators.amountInvalid;
    }
    return null;
  }
}
