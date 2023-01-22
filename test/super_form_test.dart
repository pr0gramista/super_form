import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

enum ExampleEnum { one, two, three }

void main() {
  testWidgets('can submit', (WidgetTester tester) async {
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

  testWidgets('can submit multiple times', (WidgetTester tester) async {
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

  testWidgets('validates on form submit', (WidgetTester tester) async {
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

  testWidgets('un-registers field automatically', (WidgetTester tester) async {
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

  testWidgets('can un-register field manually', (WidgetTester tester) async {
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
    await tester.enterText(find.byKey(passwordInput), "123456");

    // Not really doing anything meaningful, but if you want to unregister a field
    // that is "live" you still should be able to.
    formKey.currentState!.unregister(name: "password");

    expect(formKey.currentState!.values["login"], "hello@12345.pl");
    expect(formKey.currentState!.values["password"], isNull);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ElevatedButton));

    verify(listener({"login": "hello@12345.pl"})).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('can reset form', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const loginInput = Key('loginInput');
    const passwordInput = Key('passwordInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          onSubmit: listener,
          key: formKey,
          initialValues: const {"login": "hellothere"},
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
    expect(formKey.currentState!.modified, isTrue);

    expect(find.text("123"), findsWidgets);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text("Must be at least 6 characters"), findsOneWidget);

    formKey.currentState?.reset();
    await tester.pumpAndSettle();

    expect(formKey.currentState!.values["login"], "hellothere");
    expect(formKey.currentState!.values["password"], isNull);
    expect(formKey.currentState!.errors["login"], isEmpty);
    expect(formKey.currentState!.errors["password"], isEmpty);
    expect(formKey.currentState!.modified, isFalse);

    expect(find.text("hellothere"), findsOneWidget);

    expect(find.text("Must be at least 6 characters"), findsNothing);
  });

  testWidgets('can reset field', (WidgetTester tester) async {
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

  testWidgets('hot-reload / widget move does not remove field data',
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

  testWidgets('field state resets after name change',
      (WidgetTester tester) async {
    final initialValues = {"email": "test@pr0gramista.pl"};
    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          initialValues: initialValues,
          onSubmit: listener,
          child: Column(children: [
            TextSuperFormField(
              name: "something",
            ),
          ]),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          initialValues: initialValues,
          onSubmit: listener,
          child: Column(children: [
            TextSuperFormField(
              name: "email",
            ),
          ]),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("test@pr0gramista.pl"), findsOneWidget);
  });

  testWidgets('validates on rules changes', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = "email";
    const errorMessage1 = "Must be an email";
    const errorMessage2 = "Now it must be at least 10 characters";
    const inputKey = Key(fieldName);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Column(children: [
            TextSuperFormField(
              key: inputKey,
              name: fieldName,
              rules: [EmailRule(errorMessage1)],
            ),
          ]),
        ),
      ),
    );

    await tester.enterText(find.byKey(inputKey), "123456");
    formKey.currentState?.submit();

    await tester.pumpAndSettle();
    expect(find.text(errorMessage1), findsOneWidget);
    expect(find.text(errorMessage2), findsNothing);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Column(children: [
            TextSuperFormField(
              key: inputKey,
              name: fieldName,
              rules: [MinimumLengthRule(10, errorMessage2)],
            ),
          ]),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text(errorMessage1), findsNothing);
    expect(find.text(errorMessage2), findsOneWidget);
  });

  testWidgets('can restore state', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const nameInput = Key('nameInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        restorationScopeId: "app",
        child: SuperForm(
          restorationId: "form",
          onSubmit: listener,
          key: formKey,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: nameInput,
                name: "name",
                rules: [RequiredRule("Please provide your name")],
              ),
              CheckboxSuperFormField.listTile(name: "services", options: const [
                CheckboxOption("hoovering", Text("Hoovering")),
                CheckboxOption("laundry", Text("Laundry")),
                CheckboxOption("mopping", Text("Mopping")),
              ]),
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

    await tester.enterText(find.byKey(nameInput), "Bartatus");
    await tester.tap(find.text("Laundry"));

    await tester.pumpAndSettle();
    await tester.restartAndRestore();

    expect(find.text("Bartatus"), findsOneWidget);
    expect(formKey.currentState!.values["services"], {"laundry"});
  });

  testWidgets('can restore ignoring unserializable fields',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const nameInput = Key('nameInput');

    final listener = SubmitListener();

    await tester.pumpWidget(
      boilerplate(
        restorationScopeId: "app",
        child: SuperForm(
          restorationId: "form",
          onSubmit: listener,
          key: formKey,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                key: nameInput,
                name: "name",
                rules: [RequiredRule("Please provide your name")],
              ),
              CheckboxSuperFormField.listTile(name: "numbers", options: const [
                CheckboxOption(ExampleEnum.one, Text("One")),
                CheckboxOption(ExampleEnum.two, Text("Two")),
                CheckboxOption(ExampleEnum.three, Text("Three")),
              ]),
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

    await tester.enterText(find.byKey(nameInput), "Bartatus");
    await tester.tap(find.text("Two"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Three"));
    await tester.pumpAndSettle();

    expect(
      formKey.currentState!.values["numbers"],
      [ExampleEnum.two, ExampleEnum.three],
    );

    await tester.restartAndRestore();

    expect(find.text("Bartatus"), findsOneWidget);
    expect(formKey.currentState!.values["numbers"], null);
  });

  testWidgets('can set touched programatically', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(name: "login"),
              TextSuperFormField(name: "password"),
            ]),
          ),
        ),
      ),
    );

    formKey.currentState!.setTouched("login", true);
    expect(formKey.currentState!.data["login"]!.touched, true);
  });

  testWidgets('can update rules programatically', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: Builder(
            builder: (context) =>
                Column(children: const [SuperFormErrorText(name: "virtual")]),
          ),
        ),
      ),
    );

    formKey.currentState!
        .register(name: "virtual", rules: [MinValueRule(3, "Minimum 3")]);
    formKey.currentState!.setValue("virtual", "a");
    formKey.currentState!.validate("virtual");
    await tester.pumpAndSettle();

    expect(find.text("Minimum 3"), findsOneWidget);

    formKey.currentState!.updateFieldRules(
      "virtual",
      [MinValueRule(1, "Minimum 1")],
    );
    await tester.pumpAndSettle();

    expect(find.text("Minimum 3"), findsOneWidget);

    formKey.currentState!.validate("virtual");
    await tester.pumpAndSettle();

    expect(find.text("Minimum 3"), findsNothing);
    expect(
        formKey.currentState!.rules["virtual"],
        predicate<List>((rules) =>
            rules[0] is MinValueRule && (rules[0] as MinValueRule).min == 1));
  });

  testWidgets('changing initial values does not effect modified state',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          initialValues: const {"name": "Bartosz"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.modified, false);

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          initialValues: const {"name": "Anna"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.modified, false);
  });

  testWidgets(
      'resetting form field does not use internal copy of initial values',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          initialValues: const {"name": "Bartosz"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          initialValues: const {"name": "Anna"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    formKey.currentState!.reset(name: "name");
    expect(formKey.currentState!.values["name"], "Anna");

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          initialValues: const {"name": "John"},
          child: Builder(
            builder: (context) => Column(children: [
              TextSuperFormField(
                name: "name",
              ),
            ]),
          ),
        ),
      ),
    );

    formKey.currentState!.reset();
    expect(formKey.currentState!.values["name"], "John");
  });
}
