import 'package:financo/core/utils/amount_parser.dart';
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

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validators.amountRequired;
    }
    // The previous `replaceAll(',', '.')` blew up on BR values with a
    // thousands grouper — `2.000,00` became `2.000.00` and parsed as
    // null. `parseDecimalAmount` handles both BR and EN styles.
    final parsed = parseDecimalAmount(value);
    if (parsed == null || parsed <= 0) {
      return t.validators.amountInvalid;
    }
    return null;
  }

}
