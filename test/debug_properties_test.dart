import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  testWidgets('dumps tree with improved properties',
      (WidgetTester tester) async {
    String? seen;

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                name: "login",
                rules: [
                  RequiredRule("Login is required"),
                  PatternRule(RegExp("^[0-9]*\$"), "Only digits are allowed"),
                  MinimumLengthRule(3, "At least 3 digits"),
                  MaximumLengthRule(9, "At most 9 digits"),
                ],
              ),
              TextSuperFormField(
                name: "email",
                rules: [
                  EmailRule("Must be email like"),
                  IsEqualRule("test@pr0gramista.pl", "Must be test email")
                ],
              ),
              TextSuperFormField(
                name: "count",
                rules: [
                  IsNumberRule("Must be a number"),
                  IsIntegerRule("Must be an integer"),
                  MinValueRule(1, "Must be at least 1"),
                  MaxValueRule(3, "Must be at most 3"),
                  CustomRule((value) {
                    return null;
                  })
                ],
              ),
              TextSuperFormField(
                name: "password",
                rules: [
                  RequiredRule("Password is required"),
                  MinimumLengthRule(6, "Must be at least 6 characters"),
                  ContainsRule(
                      RegExp("^hello"), "Must start with hello or something")
                ],
              ),
              const SuperFormErrorText(
                name: "password",
              ),
              ElevatedButton(
                onPressed: () {
                  seen = WidgetsBinding.instance!.renderViewElement!
                      .toStringDeep();
                },
                child: const Text("Check"),
              )
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));

    expect(seen, contains("MinimumLengthRule (min: 6)"));
    expect(seen, contains("RequiredRule"));
    expect(seen, contains("IsEqualRule to test@pr0gramista.pl"));
    expect(seen, contains("ContainsRule RegExp: pattern=^hello flags=]"));
  });
}
