import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  testWidgets('empty form does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(const SuperForm(child: SizedBox()));
  });

  testWidgets('empty form with key does not crash',
      (WidgetTester tester) async {
    final key = GlobalKey<SuperFormState>();

    await tester.pumpWidget(SuperForm(key: key, child: const SizedBox()));

    expect(key.currentState?.data.length, 0);
  });

  testWidgets('actions on unregistered field throws StateError',
      (WidgetTester tester) async {
    final key = GlobalKey<SuperFormState>();

    await tester.pumpWidget(SuperForm(key: key, child: const SizedBox()));

    expect(() => key.currentState?.setTouched("hello", true), throwsStateError);
    expect(() => key.currentState?.setValue("hello", true), throwsStateError);
    expect(() => key.currentState?.validate("hello"), throwsStateError);
    expect(() => key.currentState?.validate("hello", markSubmitted: true),
        throwsStateError);
    expect(() => key.currentState?.reset(name: "hello"), throwsStateError);
    expect(
        () => key.currentState?.updateFieldData(const SuperFormFieldData(
            name: "hello",
            value: true,
            rules: [],
            touched: true,
            errors: [],
            submitted: false)),
        throwsStateError);
  });

  testWidgets('calls .of without ancestor throws', (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate(
      child: Builder(
        builder: (context) => OutlinedButton(
          onPressed: () {
            SuperForm.of(context).setValue("bomb", "boom");
          },
          child: const Text("Detonator"),
        ),
      ),
    ));

    await tester.tap(find.byType(OutlinedButton));

    expect(tester.takeException(), isInstanceOf<FlutterError>());
  });

  testWidgets('rogue text field does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate(
      child: TextSuperFormField(name: "hello_there"),
    ));

    expect(find.text("fallback"), findsNothing);
    expect(find.byType(TextField), findsNothing);

    await tester.pumpWidget(boilerplate(
      child: TextSuperFormField(
        name: "hello_there",
        noFormFallback: const Text("fallback"),
      ),
    ));

    expect(find.text("fallback"), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
