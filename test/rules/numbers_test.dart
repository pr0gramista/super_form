import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

const maxValueTestCases = [
  ParamRuleTestCase(5, 5, true),
  ParamRuleTestCase(5.1, 5, false),
  ParamRuleTestCase(4.7, 5, true),
  ParamRuleTestCase(6, 5, false),
  ParamRuleTestCase(0, 5, true),
  ParamRuleTestCase(-1.5, 5, true),
  ParamRuleTestCase(1, 0, false),
  ParamRuleTestCase(0, 0, true),
  ParamRuleTestCase(-50, -1, true),
  ParamRuleTestCase(0, 1000, true),
  ParamRuleTestCase("1000", 1000, true),
  ParamRuleTestCase("1001", 1000, false),
  ParamRuleTestCase("null", 1000, false),
  ParamRuleTestCase("kaboom", 1000, false),
];

const minValueTestCases = [
  ParamRuleTestCase(0, 5, false),
  ParamRuleTestCase(5, 5, true),
  ParamRuleTestCase(6, 5, true),
  ParamRuleTestCase(-1, 5, false),
  ParamRuleTestCase(0, 0, true),
  ParamRuleTestCase(-1, 0, false),
  ParamRuleTestCase(4.2, 4, true),
  ParamRuleTestCase(3.7, 4, false),
  ParamRuleTestCase("4", 4, true),
  ParamRuleTestCase("4.6", 4.5, true),
  ParamRuleTestCase("3", 4, false),
  ParamRuleTestCase("null", 0, false),
  ParamRuleTestCase("kaboom", 0, false),
];

const numberTestCases = [
  RuleTestCase("egogke", false),
  RuleTestCase("5.4", true),
  RuleTestCase("-2", true),
  RuleTestCase(4, true),
  RuleTestCase(00999.99, true),
  RuleTestCase(0x16, true),
  RuleTestCase(0x16, true),
  RuleTestCase("", false),
  RuleTestCase(null, false),
  RuleTestCase(Object(), false),
];

const integerTestCases = [
  RuleTestCase("egogke", false),
  RuleTestCase("5.4", false),
  RuleTestCase("-2", true),
  RuleTestCase(4, true),
  RuleTestCase(00999.99, false),
  RuleTestCase(0x16, true),
  RuleTestCase("", false),
  RuleTestCase(null, false),
  RuleTestCase(Object(), false),
];

void main() {
  group("MaximumValueRule", () {
    maxValueTestCases.forEach((testCase) {
      test(
          'for max value ${testCase.param} "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = MaxValueRule(testCase.param, "Error");

        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });

  group("MinValueRule", () {
    minValueTestCases.forEach((testCase) {
      test(
          'for min value ${testCase.param} "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = MinValueRule(testCase.param, "Error");

        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });

  group("IsNumberRule", () {
    numberTestCases.forEach((testCase) {
      test('for "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = IsNumberRule("Error");

        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });

  group("IsIntegerRule", () {
    integerTestCases.forEach((testCase) {
      test('for "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = IsIntegerRule("Error");

        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });
}
