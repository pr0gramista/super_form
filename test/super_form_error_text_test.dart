import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  group("SuperFormErrorText", () {
    testWidgets('shows error', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            onInit: (formState) {
              formState.register(
                name: "counter",
                rules: [
                  IsNumberRule("Must be a number"),
                  MinValueRule(5, "Must be at least 5 to submit"),
                ],
              );
            },
            key: formKey,
            child: Column(children: const [
              SuperFormErrorText(name: "counter"),
            ]),
          ),
        ),
      );

      formKey.currentState?.setValue("counter", "sorry");
      formKey.currentState?.validate("counter");
      await tester.pumpAndSettle();
      expect(find.text("Must be a number"), findsOneWidget);

      formKey.currentState?.setValue("counter", "3.4");
      formKey.currentState?.validate("counter");
      await tester.pumpAndSettle();
      expect(find.text("Must be at least 5 to submit"), findsOneWidget);

      formKey.currentState?.setValue("counter", "6");
      formKey.currentState?.validate("counter");
      await tester.pumpAndSettle();
      expect(find.text("Must be at least 5 to submit"), findsNothing);
    });

    testWidgets('shows custom fallback', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const fallbackText = "No errors 🎉";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            onInit: (formState) {
              formState.register(name: "counter", rules: []);
            },
            key: formKey,
            child: Column(children: const [
              SuperFormErrorText(
                name: "counter",
                fallback: Text(fallbackText),
              ),
            ]),
          ),
        ),
      );

      expect(find.text(fallbackText), findsOneWidget);
    });

    testWidgets('uses error text color from theme',
        (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const errorText = "It must be true";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            onInit: (formState) {
              formState.register(
                  name: "counter", rules: [IsEqualRule(true, errorText)]);
            },
            key: formKey,
            child: Column(children: const [
              SuperFormErrorText(
                name: "counter",
              ),
            ]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      formKey.currentState?.setValue("counter", false);
      formKey.currentState?.validate("counter");

      await tester.pumpAndSettle();

      final Text errorWidget = tester.widget(find.text(errorText));
      expect(errorWidget.style!.color, Colors.red.shade700);
    });

    testWidgets(
        'uses error text color from theme even when there is a text style',
        (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const errorText = "It must be true";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            onInit: (formState) {
              formState.register(
                  name: "counter", rules: [IsEqualRule(true, errorText)]);
            },
            key: formKey,
            child: Column(children: const [
              SuperFormErrorText(
                name: "counter",
                style: TextStyle(fontSize: 50),
              ),
            ]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      formKey.currentState?.setValue("counter", false);
      formKey.currentState?.validate("counter");

      await tester.pumpAndSettle();

      final Text errorWidget = tester.widget(find.text(errorText));
      expect(errorWidget.style!.color, Colors.red.shade700);
      expect(errorWidget.style!.fontSize, 50);
    });
  });
}
