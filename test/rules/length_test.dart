import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

const maxLengthTestCases = [
  ParamRuleTestCase("hello", 5, true),
  ParamRuleTestCase("", 5, true),
  ParamRuleTestCase("hello555", 5, false),
  ParamRuleTestCase("      ", 5, false),
  ParamRuleTestCase("", 0, true),
  ParamRuleTestCase("1", 0, false),
  ParamRuleTestCase("", -1, false),
  ParamRuleTestCase("", 1000, true),
];

const minLengthTestCases = [
  ParamRuleTestCase("hello", 5, true),
  ParamRuleTestCase("", 5, false),
  ParamRuleTestCase("hello555", 5, true),
  ParamRuleTestCase("      ", 5, true),
  ParamRuleTestCase("", 0, true),
  ParamRuleTestCase("1", 0, true),
  ParamRuleTestCase("", -1, true),
  ParamRuleTestCase("", 1000, false),
];

void main() {
  group("MaximumLengthRule", () {
    maxLengthTestCases.forEach((testCase) {
      test(
          'For max length ${testCase.param} "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = MaximumLengthRule(testCase.param, "Error");

        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });

  group("MinimumLengthRule", () {
    minLengthTestCases.forEach((testCase) {
      test(
          'For min length ${testCase.param} "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = MinimumLengthRule(testCase.param, "Error");

        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });
}
