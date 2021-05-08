import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  testWidgets('Get simple text field value', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const inputKey = Key('input');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Builder(
            builder: (context) =>
                TextSuperFormField(key: inputKey, name: "name"),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "hello");
    expect(formKey.currentState?.data["name"]?.value, "hello");

    await tester.enterText(find.byKey(inputKey), "hello world");
    expect(formKey.currentState?.data["name"]?.value, "hello world");
  });

  testWidgets('Can submit', (WidgetTester tester) async {
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

    await tester.enterText(find.byKey(inputKey), "hello world");

    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('Can submit multiple times', (WidgetTester tester) async {
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

    await tester.enterText(find.byKey(inputKey), "hello world");

    await tester.tap(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(2);
    verifyNoMoreInteractions(listener);
  });

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

  testWidgets('Can reset when form is replaced', (WidgetTester tester) async {
    final formKey1 = GlobalKey<SuperFormState>();
    final formKey2 = GlobalKey<SuperFormState>();
    const inputKey = Key('input');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey1,
          validationMode: ValidationMode.onBlur,
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

    await tester.enterText(find.byKey(inputKey), "hello world");
    expect(find.text("hello world"), findsOneWidget);
    expect(formKey1.currentState?.values["name"], "hello world");

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey2,
          validationMode: ValidationMode.onBlur,
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

    expect(find.text("hello world"), findsNothing);
    expect(formKey1.currentState, null);

    expect(formKey2.currentState?.values["name"], null);
    await tester.enterText(find.byKey(inputKey), "hello world");
    expect(formKey2.currentState?.values["name"], "hello world");
  });

  testWidgets('Un-registers field automatically', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');
    const passwordInput = Key('passwordInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: loginInput,
                name: "login",
                rules: [RequiredRule("Login is required")],
              ),
              TextSuperFormField(
                key: passwordInput,
                name: "password",
                rules: [
                  RequiredRule("Password is required"),
                  MinimumLengthRule(6, "Must be at least 6 characters"),
                ],
              ),
              Builder(builder: (context) {
                final pass = SuperForm.ofFieldMaybe(context, "password")
                    ?.data["password"]
                    ?.value as String?;

                return Text(pass ?? "No password");
              }),
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

    await tester.enterText(find.byKey(loginInput), "hello@12345.pl");
    await tester.enterText(find.byKey(passwordInput), "123");

    expect(find.text("123"), findsWidgets);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text("Must be at least 6 characters"), findsOneWidget);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: loginInput,
                name: "login",
              ),
              Builder(builder: (context) {
                final pass = SuperForm.ofFieldMaybe(context, "password")
                    ?.data["password"]
                    ?.value as String?;

                return Text(pass ?? "No password");
              }),
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

    await tester.pump();

    expect(formKey.currentState!.values["login"], "hello@12345.pl");
    expect(formKey.currentState!.values["password"], isNull);
    expect(formKey.currentState!.errors["login"], isEmpty);
    expect(formKey.currentState!.errors["password"], isNull);

    expect(find.text("No password"), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));

    verify(listener(formKey.currentState!.values)).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('Can reset form', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');
    const passwordInput = Key('passwordInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          initialValues: const {"login": "@12345.pl"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: loginInput,
                name: "login",
                rules: [RequiredRule("Login is required")],
              ),
              TextSuperFormField(
                key: passwordInput,
                name: "password",
                rules: [
                  RequiredRule("Password is required"),
                  MinimumLengthRule(6, "Must be at least 6 characters"),
                ],
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

    await tester.enterText(find.byKey(loginInput), "hello@12345.pl");
    await tester.enterText(find.byKey(passwordInput), "123");

    expect(find.text("123"), findsWidgets);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text("Must be at least 6 characters"), findsOneWidget);

    formKey.currentState?.reset();
    await tester.pumpAndSettle();

    expect(formKey.currentState!.values["login"], "@12345.pl");
    expect(formKey.currentState!.values["password"], isEmpty);
    expect(formKey.currentState!.errors["login"], isEmpty);
    expect(formKey.currentState!.errors["password"], isEmpty);

    expect(find.text("Must be at least 6 characters"), findsNothing);
  });

  testWidgets('Can reset field', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');
    const passwordInput = Key('passwordInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          initialValues: const {"login": "@12345.pl"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: loginInput,
                name: "login",
                rules: [RequiredRule("Login is required")],
              ),
              TextSuperFormField(
                key: passwordInput,
                name: "password",
                rules: [
                  RequiredRule("Password is required"),
                  MinimumLengthRule(6, "Must be at least 6 characters"),
                ],
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

    await tester.enterText(find.byKey(loginInput), "hello@12345.pl");
    await tester.enterText(find.byKey(passwordInput), "123");

    expect(find.text("123"), findsWidgets);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text("Must be at least 6 characters"), findsOneWidget);

    formKey.currentState?.reset(name: "login");
    await tester.pumpAndSettle();

    expect(formKey.currentState!.values["login"], "@12345.pl");
    expect(formKey.currentState!.values["password"], "123");
    expect(formKey.currentState!.errors["login"], isEmpty);

    expect(find.text("Must be at least 6 characters"), findsOneWidget);
  });

  testWidgets('Hot-reload / widget move does not remove field data',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');
    const passwordInput = Key('passwordInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          child: Column(children: [
            TextSuperFormField(
              key: loginInput,
              name: "login",
            ),
            TextSuperFormField(
              key: passwordInput,
              name: "password",
            ),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SuperForm.of(context, listen: false).submit();
                },
                child: const Text("Submit"),
              ),
            )
          ]),
        ),
      ),
    );

    await tester.enterText(find.byKey(loginInput), "hello@12345.pl");
    await tester.enterText(find.byKey(passwordInput), "123");

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          child: Column(children: [
            TextSuperFormField(
              key: loginInput,
              name: "login",
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextSuperFormField(
                key: passwordInput,
                name: "password",
              ),
            ),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SuperForm.of(context, listen: false).submit();
                },
                child: const Text("Submit"),
              ),
            )
          ]),
        ),
      ),
    );

    expect(formKey.currentState!.values["login"], "hello@12345.pl");
    expect(formKey.currentState!.values["password"], "123");

    expect(find.text("123"), findsOneWidget);
  });

  testWidgets('text field onEditingComplete is called',
      (WidgetTester tester) async {
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
}
