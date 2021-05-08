import '../super_form.dart';

/// Ensures that value is not null and if it is a
/// string that it is not empty after trimming.
class RequiredRule extends SuperFormFieldRule {
  final String message;

  RequiredRule(this.message);

  @override
  ValidationError? validate(dynamic value) {
    if (value == null) return ValidationError(message);

    if (value is String && value.trim().isEmpty) {
      return ValidationError(message);
    }
  }
}

/// Ensures that value is equal to given [value].
///
/// Note that if you are going to use it with classes you may
/// want to make sure to implement == operator.
class IsEqualRule<T> extends SuperFormFieldRule {
  final T value;
  final String message;

  IsEqualRule(this.value, this.message);

  @override
  ValidationError? validate(dynamic valueToValidate) {
    if (value != valueToValidate) {
      return ValidationError(message);
    }
  }
}

/// Converts value into a string via [toString] method and then
/// check if it has a match against given [pattern].
class PatternRule extends SuperFormFieldRule {
  final RegExp pattern;
  final String message;

  PatternRule(this.pattern, this.message);

  @override
  ValidationError? validate(dynamic value) {
    final String s = value.toString();

    if (!pattern.hasMatch(s)) {
      return ValidationError(message);
    }
  }
}

/// General Email Regex (RFC 5322 Official Standard)
/// This is still 99.9% email regex
/// https://www.emailregex.com/
const emailPatternSource =
    '^(?:[a-z0-9!#\$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])\$';

final RegExp _emailPattern = RegExp(emailPatternSource);

/// Ensures that the value matches RFC 5322 email regular expression.
///
/// Note that this regex is not valid for **all** emails.
///
/// This is a great example of extending [PatternRule].
///
/// See also:
///   * [emailPatternSource] for exact pattern
class EmailRule extends PatternRule {
  EmailRule(String message) : super(_emailPattern, message);
}
