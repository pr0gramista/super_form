import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

void main() {
  testWidgets('sends value to SuperForm', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const key = Key('dropdown');
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: DropdownSuperFormField(
            name: fieldName,
            key: key,
            items: const [
              DropdownMenuItem(value: 1, child: Text("One")),
              DropdownMenuItem(value: 2, child: Text("Two")),
            ],
          ),
        ),
      ),
    );

    expect(formKey.currentState?.values[fieldName], isNull);
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Two").last);
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals(2));
  });

  testWidgets('validates when onChange', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const key = Key('dropdown');
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          validationMode: ValidationMode.onChange,
          key: formKey,
          child: Column(
            children: [
              DropdownSuperFormField(
                name: fieldName,
                key: key,
                rules: [MinValueRule(2, "Must be at least 2")],
                items: const [
                  DropdownMenuItem(value: 1, child: Text("One")),
                  DropdownMenuItem(value: 2, child: Text("Two")),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text("Must be at least 2"), findsNothing);
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.tap(find.text("One").last);
    await tester.pumpAndSettle();
    expect(find.text("Must be at least 2"), findsOneWidget);
  });

  testWidgets('validates when onBlur', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');
    const anotherInput = Key('anotherInput');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          validationMode: ValidationMode.onBlur,
          key: formKey,
          child: Column(
            children: [
              DropdownSuperFormField(
                key: inputKey,
                name: "one",
                autofocus: true,
                rules: [MinValueRule(2, "Must be at least 2")],
                items: const [
                  DropdownMenuItem(value: 1, child: Text("One")),
                  DropdownMenuItem(value: 2, child: Text("Two")),
                ],
              ),
              const SizedBox(height: 200),
              TextSuperFormField(
                name: "two",
                key: anotherInput,
              ),
            ],
          ),
        ),
      ),
    );

    // It seems that DropdownButton can't be really focused using touch controls
    expect(find.text("Must be at least 2"), findsNothing);
    await tester.tap(find.byKey(anotherInput));
    await tester.pumpAndSettle();
    expect(find.text("Must be at least 2"), findsOneWidget);
  });

  testWidgets('can reset when form is replaced', (WidgetTester tester) async {
    final formKey1 = GlobalKey<SuperFormState>();
    final formKey2 = GlobalKey<SuperFormState>();
    const inputKey = Key('input');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey1,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              DropdownSuperFormField(
                key: inputKey,
                name: "name",
                rules: [MinValueRule(2, "Must be at least 2")],
                items: const [
                  DropdownMenuItem(value: 1, child: Text("One")),
                  DropdownMenuItem(value: 2, child: Text("Two")),
                ],
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(inputKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text("One").last);
    expect(formKey1.currentState?.values["name"], 1);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey2,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              DropdownSuperFormField(
                key: inputKey,
                name: "name",
                rules: [MinValueRule(2, "Must be at least 2")],
                items: const [
                  DropdownMenuItem(value: 1, child: Text("One")),
                  DropdownMenuItem(value: 2, child: Text("Two")),
                ],
              ),
            ]),
          ),
        ),
      ),
    );

    expect(formKey1.currentState, null);
    expect(formKey2.currentState?.values["name"], null);
    await tester.tap(find.byKey(inputKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text("One").last);
    expect(formKey2.currentState?.values["name"], 1);
  });

  testWidgets('onChanged is called', (WidgetTester tester) async {
    const key = Key('dropdown');
    const fieldName = 'field';
    final listener = DropdownListener<int?>();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          child: Column(
            children: [
              DropdownSuperFormField(
                name: fieldName,
                key: key,
                onChanged: listener,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("One")),
                  DropdownMenuItem(value: 2, child: Text("Two")),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Two").last);

    verify(listener(2)).called(1);
    verifyNoMoreInteractions(listener);
  });
}
