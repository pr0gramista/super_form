import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

void main() {
  testWidgets('sends value to SuperForm', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Builder(
            builder: (context) =>
                TextSuperFormField(key: inputKey, name: fieldName),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello");
    expect(formKey.currentState?.data[fieldName]?.value, "hello");

    await tester.enterText(find.byKey(inputKey), "hello world");
    expect(formKey.currentState?.data[fieldName]?.value, "hello world");
  });

  testWidgets('validates when onBlur', (WidgetTester tester) async {
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

  testWidgets('validates when onChange', (WidgetTester tester) async {
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
              TextSuperFormField(
                key: inputKey,
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello world");
    expect(find.text("hello world"), findsOneWidget);
    expect(formKey1.currentState?.values["name"], "hello world");

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey2,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: inputKey,
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    expect(find.text("hello world"), findsNothing);
    expect(formKey1.currentState, null);

    expect(formKey2.currentState?.values["name"], null);
    await tester.enterText(find.byKey(inputKey), "hello world");
    expect(formKey2.currentState?.values["name"], "hello world");
  });

  testWidgets('onEditingComplete is called', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');

    final listener = VoidListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Column(children: [
            TextSuperFormField(
              key: loginInput,
              name: "login",
              onEditingComplete: listener,
            ),
            TextSuperFormField(
              name: "password",
            ),
          ]),
        ),
      ),
    );

    await tester.enterText(find.byKey(loginInput), "hello@12345.pl");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    verify(listener()).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('onEditingComplete is called when validation mode is onBlur',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');

    final listener = VoidListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          validationMode: ValidationMode.onBlur,
          child: Column(children: [
            TextSuperFormField(
              key: loginInput,
              name: "login",
              onEditingComplete: listener,
            ),
            TextSuperFormField(
              name: "password",
            ),
          ]),
        ),
      ),
    );

    await tester.enterText(find.byKey(loginInput), "hello@12345.pl");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    verify(listener()).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('resets when widget is also changed',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');

    // We will use a StreamBuilder to rebuild our widgets so it will trigger
    // didUpdateWidget
    final StreamController<int> streamController = StreamController<int>();
    streamController.add(1);

    await tester.pumpWidget(
      boilerplate(
          child: StreamBuilder<int>(
        stream: streamController.stream,
        builder: (context, snapshot) {
          return SuperForm(
            key: formKey,
            validationMode: ValidationMode.onBlur,
            initialValues: const {"login": "hello"},
            onSubmit: (values) {
              streamController.add(snapshot.data! + 1);

              formKey.currentState?.reset();
            },
            child: Column(
              children: [
                TextSuperFormField(
                  key: loginInput,
                  name: "login",
                  // Rules are not memorized so this rule will trigger didUpdateWidget
                  rules: [RequiredRule("Must not be empty")],
                ),
                TextSuperFormField(
                  name: "password",
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      SuperForm.of(context, listen: false).submit();
                    },
                    child: const Text("Submit"),
                  );
                })
              ],
            ),
          );
        },
      )),
    );

    await tester.enterText(find.byKey(loginInput), "rex");
    await tester.pumpAndSettle();
    expect(find.text("rex"), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));

    await tester.pumpAndSettle();
    expect(find.text("rex"), findsNothing);
  });

  testWidgets('shows errors when widget is also changed',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');

    // We will use a StreamBuilder to rebuild our widgets so it will trigger
    // didUpdateWidget
    final StreamController<int> streamController = StreamController<int>();
    streamController.add(1);

    await tester.pumpWidget(
      boilerplate(
          child: StreamBuilder<int>(
        stream: streamController.stream,
        builder: (context, snapshot) {
          return SuperForm(
            key: formKey,
            child: Column(
              children: [
                TextSuperFormField(
                  key: loginInput,
                  name: "login",
                  // Rules are not memorized so this rule will trigger didUpdateWidget
                  rules: [RequiredRule("Must not be empty")],
                ),
                TextSuperFormField(
                  name: "password",
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      SuperForm.of(context, listen: false).submit();
                    },
                    child: const Text("Submit"),
                  );
                })
              ],
            ),
          );
        },
      )),
    );
    await tester.pumpAndSettle();

    // We are triggering a rebuild while submit will happen
    streamController.add(2);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text("Must not be empty"), findsOneWidget);
  });
}
