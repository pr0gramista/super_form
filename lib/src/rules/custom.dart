import '../super_form.dart';

/// Rule that accepts function for validating the value.
/// The output of the function is recognized as a message.
///
/// If the function returns null the rule will see that as if
/// there was no errors.
class CustomRule extends SuperFormFieldRule {
  final String? Function(dynamic value) validator;

  CustomRule(this.validator);

  @override
  ValidationError? validate(dynamic value) {
    final message = validator(value);

    if (message != null) return ValidationError(message);

    return null;
  }

  @override
  String toString() {
    return 'CustomRule ($validator)';
  }
}
