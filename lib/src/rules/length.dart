import '../super_form.dart';

/// Ensures that given [String] value length is greater or equal than given [length].
class MinimumLengthRule extends SuperFormFieldRule {
  final int length;
  final String message;

  MinimumLengthRule(this.length, this.message);

  @override
  ValidationError? validate(dynamic value) {
    if (value is String && value.length < length) {
      return ValidationError(message);
    }
    return null;
  }
}

/// Ensures that given [String] value length is less or equal than given [length].
class MaximumLengthRule extends SuperFormFieldRule {
  final int length;
  final String message;

  MaximumLengthRule(this.length, this.message);

  @override
  ValidationError? validate(dynamic value) {
    if (value is String && value.length > length) {
      return ValidationError(message);
    }
    return null;
  }
}
