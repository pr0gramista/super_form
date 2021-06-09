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

final containsTestCases = [
  const ParamRuleTestCase([1, 2, 3], 1, true),
  const ParamRuleTestCase([1, 2, 3], 2, true),
  const ParamRuleTestCase([1, 2, 3], 0, false),
  const ParamRuleTestCase([1, 2, 3], [], false),
  const ParamRuleTestCase({'one', 'two', 'three'}, 'two', true),
  const ParamRuleTestCase(['one', 2, 3], 'one', true),
  const ParamRuleTestCase(['one', 'two'], 'three', false),
  const ParamRuleTestCase({"one": 1, "two": 2}, "one", true),
  const ParamRuleTestCase({"one": 1, "two": 2}, "three", false),
  const ParamRuleTestCase({"one": 1, "two": 2}, MapEntry("one", 1), true),
  const ParamRuleTestCase({"one": 1, "two": 2}, MapEntry("one", 2), false),
  const ParamRuleTestCase({"one": 1, "two": 2}, {}, false),
  ParamRuleTestCase("Hello World", RegExp("^Hello"), true),
  ParamRuleTestCase("Hello World", RegExp("^Hello\$"), false),
  const ParamRuleTestCase(Object(), 1, true),
  const ParamRuleTestCase(null, 1, false),
];

void main() {
  group("Required rule", () {
    final rule = RequiredRule("Error");

    requiredTestCases.forEach((testCase) {
      test('for "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
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
      test('for "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
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
          'for ${testCase.param} == "${testCase.value}" ${testCase.isOk ? "passes" : "errors"}',
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

  group("ContainsRule", () {
    containsTestCases.forEach((testCase) {
      test(
          'for ${testCase.value} contains "${testCase.param}" ${testCase.isOk ? "passes" : "errors"}',
          () {
        final rule = ContainsRule(testCase.param, "Error");
        final error = rule.validate(testCase.value);

        expect(error == null, testCase.isOk);
        if (error != null) {
          expect(error.message, "Error");
        }
      });
    });
  });
}
