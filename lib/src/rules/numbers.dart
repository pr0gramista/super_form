import '../super_form.dart';

/// Ensures that given [num] value is less or equal than given [max].
///
/// If the value is not a [num] the rule will attempt to parse the value.
/// If it fails ValidationError will be returned. Consider using
/// [IsNumberRule] to provide more gradual error messages.
class MaxValueRule extends SuperFormFieldRule {
  final num max;
  final String message;

  MaxValueRule(this.max, this.message);

  @override
  ValidationError? validate(dynamic value) {
    num numericValue;
    if (value is! num) {
      final result = num.tryParse(value.toString());
      if (result == null) {
        return ValidationError(message);
      } else {
        numericValue = result;
      }
    } else {
      numericValue = value;
    }

    if (numericValue > max) {
      return ValidationError(message);
    }
  }
}

/// Ensures that given [num] value is greater or equal than given [min].
///
/// If the value is not a [num] the rule will attempt to parse the value.
/// If it fails ValidationError will be returned. Consider using
/// [IsNumberRule] to provide more gradual error messages.
class MinValueRule extends SuperFormFieldRule {
  final num min;
  final String message;

  MinValueRule(this.min, this.message);

  @override
  ValidationError? validate(dynamic value) {
    num numericValue;
    if (value is! num) {
      final result = num.tryParse(value.toString());
      if (result == null) {
        return ValidationError(message);
      } else {
        numericValue = result;
      }
    } else {
      numericValue = value;
    }

    if (numericValue < min) {
      return ValidationError(message);
    }
  }
}

/// Ensures that given value is or can be parsed into [num].
class IsNumberRule extends SuperFormFieldRule {
  final String message;

  IsNumberRule(this.message);

  @override
  ValidationError? validate(dynamic value) {
    if (value is num) return null;

    final result = num.tryParse(value?.toString() ?? "");

    if (result == null) {
      return ValidationError(message);
    }
  }
}

/// Ensures that given value is or can be parsed into [int].
class IsIntegerRule extends SuperFormFieldRule {
  final String message;

  IsIntegerRule(this.message);

  @override
  ValidationError? validate(dynamic value) {
    if (value is int) return null;

    final result = int.tryParse(value?.toString() ?? "");

    if (result == null) {
      return ValidationError(message);
    }
  }
}
