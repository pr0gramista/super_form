import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

void main() {
  testWidgets('sends value to SuperForm', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const key = Key('slider');
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: SliderSuperFormField(
            name: fieldName,
            key: key,
          ),
        ),
      ),
    );

    expect(formKey.currentState?.values[fieldName], isNull);
    await tester.tap(find.byKey(key));
    expect(formKey.currentState?.values[fieldName], equals(0.5));
  });

  testWidgets('validates when onChange', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const key = Key('slider');
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          validationMode: ValidationMode.onChange,
          key: formKey,
          child: Column(
            children: [
              SliderSuperFormField(
                name: fieldName,
                rules: [MinValueRule(1, "Must be at least 1")],
                key: key,
              ),
              const SuperFormErrorText(name: fieldName),
            ],
          ),
        ),
      ),
    );

    expect(find.text("Must be at least 1"), findsNothing);
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    expect(find.text("Must be at least 1"), findsOneWidget);
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
              SliderSuperFormField(
                name: "one",
                rules: [MinValueRule(1, "Must be at least 1")],
                key: inputKey,
                autofocus: true,
              ),
              TextSuperFormField(
                name: "two",
                key: anotherInput,
              ),
              const SuperFormErrorText(name: "one"),
            ],
          ),
        ),
      ),
    );

    expect(find.text("Must be at least 1"), findsNothing);
    await tester.tap(find.byKey(inputKey));
    await tester.pumpAndSettle();
    expect(find.text("Must be at least 1"), findsNothing);
    await tester.tap(find.byKey(anotherInput));
    await tester.pumpAndSettle();
    expect(find.text("Must be at least 1"), findsOneWidget);
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
              SliderSuperFormField(
                key: inputKey,
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(inputKey));
    expect(formKey1.currentState?.values["name"], 0.5);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey2,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              SliderSuperFormField(
                key: inputKey,
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    expect(formKey1.currentState, null);
    expect(formKey2.currentState?.values["name"], null);
    await tester.tap(find.byKey(inputKey));
    expect(formKey2.currentState?.values["name"], 0.5);
  });

  testWidgets('onChanged is called', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    final listener = SliderChangedListener();
    const key = Key('slider');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: SliderSuperFormField(
            key: key,
            name: "name",
            onChanged: listener,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    verify(listener(0.5)).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('can be disabled', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    final listener = SliderChangedListener();
    const key = Key('slider');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: SliderSuperFormField(
            key: key,
            name: "name",
            onChanged: listener,
            enabled: true,
          ),
        ),
      ),
    );

    final offset = tester.getCenter(find.byKey(key));
    await tester.tapAt(offset.translate(30, 0));
    verify(listener(0.5398936170212766)).called(1);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: SliderSuperFormField(
            key: key,
            name: "name",
            onChanged: listener,
            enabled: false,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    verifyNoMoreInteractions(listener);
  });

  testWidgets('can be disabled by SuperForm', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    final listener = SliderChangedListener();
    const key = Key('slider');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: SliderSuperFormField(
            key: key,
            name: "name",
            onChanged: listener,
          ),
        ),
      ),
    );

    final offset = tester.getCenter(find.byKey(key));
    await tester.tapAt(offset.translate(30, 0));
    verify(listener(0.5398936170212766)).called(1);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          enabled: false,
          child: SliderSuperFormField(
            key: key,
            name: "name",
            onChanged: listener,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    verifyNoMoreInteractions(listener);
  });
}
