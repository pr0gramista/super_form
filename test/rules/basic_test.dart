import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

const requiredTestCases = [
  RuleTestCase(null, false),
  RuleTestCase("", false),
  RuleTestCase(" ", false),
  RuleTestCase("h", true),
  RuleTestCase("‎ ", true), // six-per-em
];

const isEqualTestCases = [
  ParamRuleTestCase(null, 2, false),
  ParamRuleTestCase(null, null, true),
  ParamRuleTestCase("ggg", 2, false),
  ParamRuleTestCase({}, {}, true),
  ParamRuleTestCase({"t": 1, "b": 4}, {"t": 1, "b": 4}, true),
  ParamRuleTestCase({"t": 1, "b": 4}, {"t": 1, "b": 2}, false),
  ParamRuleTestCase([], [], true),
  ParamRuleTestCase(5, 2, false),
  ParamRuleTestCase("hello", "hello", true),
  ParamRuleTestCase("hello", "hello", true),
  ParamRuleTestCase(2, 2, true),
  ParamRuleTestCase([1, 2], [2, 3], false),
  ParamRuleTestCase([1, 2], [1, 2], true),
  ParamRuleTestCase(Object(), Object(), true),
];

const emailTestCases = [
  RuleTestCase("kontakt@pr0gramista.pl", true),
  RuleTestCase("hey@1.1.1.1", true),
  RuleTestCase("@example.com", false),
  RuleTestCase("email@example", false),
  RuleTestCase("email@[123.123.123.123]", true),
  RuleTestCase("eg3g033g email@4fun.dev g3g3gg", false),
];

void main() {
  group("Required rule", () {
    final rule = RequiredRule("Error");

    requiredTestCases.forEach((testCase) {
      test('For "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });

  group("Email rule", () {
    final rule = EmailRule("Error");

    emailTestCases.forEach((testCase) {
      test('For "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });

  group("IsEqualRule", () {
    isEqualTestCases.forEach((testCase) {
      test(
          'For ${testCase.param} == "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = IsEqualRule(testCase.param, "Error");
        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });
}
