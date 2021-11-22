import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

import '../utils.dart';

void main() {
  Widget get123({
    required String name,
    void Function(String?)? onChanged,
    List<SuperFormFieldRule>? rules,
    bool autofocus = false,
    RadioBuilder<String>? builder,
    bool toggleable = false,
    bool? enabled,
  }) {
    if (builder != null) {
      return RadioSuperFormField(
        onChanged: onChanged,
        name: name,
        builder: builder,
        rules: rules,
        enabled: enabled,
        options: const [
          RadioOption("one", Text("One")),
          RadioOption("two", Text("Two")),
          RadioOption("three", Text("Three")),
        ],
      );
    }

    return RadioSuperFormField.listTile(
      onChanged: onChanged,
      name: name,
      autofocus: autofocus,
      rules: rules,
      toggleable: toggleable,
      enabled: enabled,
      options: const [
        RadioOption("one", Text("One")),
        RadioOption("two", Text("Two")),
        RadioOption("three", Text("Three")),
      ],
    );
  }

  testWidgets('sends value to SuperForm', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(key: formKey, child: get123(name: fieldName)),
      ),
    );

    expect(formKey.currentState?.values[fieldName], isNull);
    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("one"));
    await tester.tap(find.text("Two"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("two"));
  });

  testWidgets('can be toggleable', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          initialValues: const {fieldName: "one"},
          key: formKey,
          child: get123(
            name: fieldName,
            toggleable: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], isNull);
  });

  testWidgets('validates when onChange', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          validationMode: ValidationMode.onChange,
          key: formKey,
          child: Column(
            children: [
              get123(
                name: fieldName,
                rules: [IsEqualRule("three", "Pick 3 my lord!!!")],
              ),
              const SuperFormErrorText(name: fieldName),
            ],
          ),
        ),
      ),
    );

    expect(find.text("Pick 3 my lord!!!"), findsNothing);
    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(find.text("Pick 3 my lord!!!"), findsOneWidget);
  });

  testWidgets('validates when onBlur', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'field';
    const anotherInput = Key('anotherInput');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          validationMode: ValidationMode.onBlur,
          key: formKey,
          child: Column(
            children: [
              get123(
                name: fieldName,
                autofocus: true,
                rules: [IsEqualRule("three", "Pick 3 my lord!!!")],
              ),
              TextSuperFormField(
                name: "two",
                key: anotherInput,
              ),
              const SuperFormErrorText(name: fieldName),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(anotherInput));
    await tester.pumpAndSettle();
    expect(find.text("Pick 3 my lord!!!"), findsOneWidget);
  });

  testWidgets('can reset when form is replaced', (WidgetTester tester) async {
    final formKey1 = GlobalKey<SuperFormState>();
    final formKey2 = GlobalKey<SuperFormState>();
    const fieldName = "number";

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey1,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              get123(
                name: fieldName,
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(formKey1.currentState?.values[fieldName], 'one');

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey2,
          validationMode: ValidationMode.onBlur,
          child: Builder(
            builder: (context) => Column(children: [
              get123(
                name: fieldName,
              ),
            ]),
          ),
        ),
      ),
    );

    expect(formKey1.currentState, null);
    expect(formKey2.currentState?.values[fieldName], null);

    await tester.tap(find.text("Two"));
    await tester.pumpAndSettle();
    expect(formKey2.currentState?.values[fieldName], 'two');
  });

  testWidgets('onChanged is called', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    final listener = RadioChangedListener();

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: get123(
            name: "number",
            onChanged: listener,
          ),
        ),
      ),
    );

    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    verify(listener("one")).called(1);
    verifyNoMoreInteractions(listener);
  });

  testWidgets('clears values that have no corresponding option',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'number';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: RadioSuperFormField.listTile(
            name: fieldName,
            options: const [
              RadioOption("one", Text("One")),
              RadioOption("two", Text("Two")),
              RadioOption("three", Text("Three")),
            ],
          ),
        ),
      ),
    );

    expect(formKey.currentState?.values[fieldName], isNull);
    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("one"));

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: RadioSuperFormField.listTile(
            name: fieldName,
            options: const [
              RadioOption("two", Text("Two")),
              RadioOption("three", Text("Three")),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], isNull);
    await tester.tap(find.text("Two"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("two"));

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: RadioSuperFormField.listTile(
            name: fieldName,
            options: const [
              RadioOption("one", Text("One")),
              RadioOption("two", Text("Two")),
              RadioOption("three", Text("Three")),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("two"));
  });

  testWidgets('renders with selected and subtitle',
      (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'number';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: RadioSuperFormField.listTile(
            name: fieldName,
            selected: (option) => option.value == 1,
            isThreeLine: true,
            subtitle: (RadioOption<int> o) => Text(
              "Did you know that ${o.value} * ${o.value} = ${o.value * o.value}",
            ),
            options: const [
              RadioOption(1, Text("One")),
              RadioOption(2, Text("Two")),
              RadioOption(3, Text("Three")),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text("Did you know that 2 * 2 = 4"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], 2);
  });

  testWidgets('can be disabled', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: get123(
            name: fieldName,
            enabled: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("one"));

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: get123(
            name: fieldName,
            enabled: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Two"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("one"));
  });

  testWidgets('can be disabled by SuperForm', (WidgetTester tester) async {
    final formKey = GlobalKey<SuperFormState>();
    const fieldName = 'field';

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          child: get123(
            name: fieldName,
          ),
        ),
      ),
    );

    await tester.tap(find.text("One"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("one"));

    await tester.pumpWidget(
      boilerplate(
        child: SuperForm(
          key: formKey,
          enabled: false,
          child: get123(
            name: fieldName,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Two"));
    await tester.pumpAndSettle();
    expect(formKey.currentState?.values[fieldName], equals("one"));
  });

  group("custom builder", () {
    Widget builder(BuildContext context, RadioState<String> state) {
      // Let's make something avant-garde
      return Row(
          children: state.options
              .map((o) => ElevatedButton(
                    focusNode: state.focusNode,
                    autofocus: true,
                    onPressed: state.onChanged != null
                        ? () {
                            state.onChanged!(o.value);
                          }
                        : null,
                    child: o.label,
                  ))
              .toList());
    }

    testWidgets('sends value to SuperForm', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const fieldName = 'field';

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
              key: formKey, child: get123(name: fieldName, builder: builder)),
        ),
      );

      expect(formKey.currentState?.values[fieldName], isNull);
      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("one"));
      await tester.tap(find.text("Two"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("two"));
      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("one"));
    });

    testWidgets('validates when onChange', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const fieldName = 'field';

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            validationMode: ValidationMode.onChange,
            key: formKey,
            child: Column(
              children: [
                get123(
                  name: fieldName,
                  builder: builder,
                  rules: [IsEqualRule("three", "Pick 3 my lord!!!")],
                ),
                const SuperFormErrorText(name: fieldName),
              ],
            ),
          ),
        ),
      );

      expect(find.text("Pick 3 my lord!!!"), findsNothing);
      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      expect(find.text("Pick 3 my lord!!!"), findsOneWidget);
    });

    testWidgets('validates when onBlur', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const fieldName = 'field';
      const anotherInput = Key('anotherInput');

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            validationMode: ValidationMode.onBlur,
            key: formKey,
            child: Column(
              children: [
                get123(
                  name: fieldName,
                  builder: builder,
                  rules: [IsEqualRule("three", "Pick 3 my lord!!!")],
                ),
                TextSuperFormField(
                  name: "two",
                  key: anotherInput,
                ),
                const SuperFormErrorText(name: fieldName),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(anotherInput));
      await tester.pumpAndSettle();
      expect(find.text("Pick 3 my lord!!!"), findsOneWidget);
    });

    testWidgets('can reset when form is replaced', (WidgetTester tester) async {
      final formKey1 = GlobalKey<SuperFormState>();
      final formKey2 = GlobalKey<SuperFormState>();
      const fieldName = "number";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey1,
            validationMode: ValidationMode.onBlur,
            child: Builder(
              builder: (context) => Column(children: [
                get123(
                  name: fieldName,
                  builder: builder,
                ),
              ]),
            ),
          ),
        ),
      );

      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      expect(formKey1.currentState?.values[fieldName], 'one');

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey2,
            validationMode: ValidationMode.onBlur,
            child: Builder(
              builder: (context) => Column(children: [
                get123(
                  name: fieldName,
                  builder: builder,
                ),
              ]),
            ),
          ),
        ),
      );

      expect(formKey1.currentState, null);
      expect(formKey2.currentState?.values[fieldName], null);

      await tester.tap(find.text("Two"));
      await tester.pumpAndSettle();
      expect(formKey2.currentState?.values[fieldName], 'two');
    });

    testWidgets('onChanged is called', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      final listener = RadioChangedListener();

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey,
            child: get123(
              name: "number",
              onChanged: listener,
              builder: builder,
            ),
          ),
        ),
      );

      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      verify(listener("one")).called(1);
      verifyNoMoreInteractions(listener);
    });

    testWidgets('can be disabled', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const fieldName = 'field';

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey,
            child: get123(
              name: fieldName,
              builder: builder,
              enabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("one"));

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey,
            child: get123(
              name: fieldName,
              builder: builder,
              enabled: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Two"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("one"));
    });

    testWidgets('can be disabled by SuperForm', (WidgetTester tester) async {
      final formKey = GlobalKey<SuperFormState>();
      const fieldName = 'field';

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey,
            child: get123(
              name: fieldName,
              builder: builder,
            ),
          ),
        ),
      );

      await tester.tap(find.text("One"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("one"));

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            key: formKey,
            enabled: false,
            child: get123(
              name: fieldName,
              builder: builder,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Two"));
      await tester.pumpAndSettle();
      expect(formKey.currentState?.values[fieldName], equals("one"));
    });
  });
}
