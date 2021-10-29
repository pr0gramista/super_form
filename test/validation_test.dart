import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  testWidgets('Validates on submit', (WidgetTester tester) async {
    const errorText = "Must be at least 8 characters";
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: inputKey,
                name: "name",
                rules: [MinimumLengthRule(8, errorText)],
              ),
              ElevatedButton(
                onPressed: () {
                  SuperForm.of(context, listen: false).submit();
                },
                child: const Text("Submit"),
              )
            ]),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello");
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text(errorText), findsOneWidget);

    await tester.enterText(find.byKey(inputKey), "hello world");
    // Notice no tap here - this is expected behavior
    await tester.pump();
    expect(find.text(errorText), findsNothing);

    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('Validates on change', (WidgetTester tester) async {
    const errorText = "Must be at least 8 characters";
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          validationMode: ValidationMode.onChange,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: inputKey,
                name: "name",
                rules: [MinimumLengthRule(8, errorText)],
              ),
              ElevatedButton(
                onPressed: () {
                  SuperForm.of(context, listen: false).submit();
                },
                child: const Text("Submit"),
              )
            ]),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello");
    await tester.pump();
    expect(find.text(errorText), findsOneWidget);

    await tester.enterText(find.byKey(inputKey), "hello world");
    await tester.pump();
    expect(find.text(errorText), findsNothing);

    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('Validates on editing complete', (WidgetTester tester) async {
    const errorText = "Must be at least 8 characters";
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');
    const anotherInput = Key('anotherInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: inputKey,
                name: "name",
                rules: [MinimumLengthRule(8, errorText)],
              ),
              const TextField(key: anotherInput),
              ElevatedButton(
                onPressed: () {
                  SuperForm.of(context, listen: false).submit();
                },
                child: const Text("Submit"),
              )
            ]),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello");
    await tester.pump();
    expect(find.text(errorText), findsNothing);

    await tester.tap(find.byKey(anotherInput));
    await tester.pump();
    expect(find.text(errorText), findsOneWidget);

    await tester.enterText(find.byKey(inputKey), "hello world");
    await tester.pump();
    expect(find.text(errorText), findsNothing);

    await tester.tap(find.byKey(anotherInput));
    await tester.pump();
    expect(find.text(errorText), findsNothing);

    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('Manually registered fields are validated',
      (WidgetTester tester) async {
    const errorText = "Must be a number";
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          validationMode: ValidationMode.onBlur,
          onInit: (formState) {
            formState.register(name: "manual", rules: [
              IsNumberRule("Must be a number"),
            ]);
          },
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: inputKey,
                name: "name",
              ),
              ElevatedButton(
                onPressed: () {
                  SuperForm.of(context, listen: false).submit();
                },
                child: const Text("Submit"),
              )
            ]),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello");
    await tester.pump();
    expect(find.text(errorText), findsNothing);

    await tester.tap(find.byType(ElevatedButton));

    expect(formKey.currentState?.errors["manual"]?[0].message, errorText);

    verifyNever(listener(formKey.currentState!.values));

    formKey.currentState?.setValue("manual", "5");
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(1);
    verifyNoMoreInteractions(listener);
  });

  test("ValidationError.toString", () {
    const error = ValidationError("Must be a number!");

    expect(error.toString(), "Validation error: Must be a number!");
  });

  test("ValidationError implements hashCode/equals", () {
    const error = ValidationError("Must be a number!");
    const error2 = ValidationError("Must be a number!");

    expect(error == error2, true);
    expect(error.hashCode == error2.hashCode, true);
  });
}
