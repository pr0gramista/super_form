import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  group("SuperFormScope", () {
    testWidgets('of with listen', (WidgetTester tester) async {
      const inputKey = Key('input');

      // This must be unique between all tests
      const buildCounterName = "of";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: "name",
                ),
                Builder(builder: (context) {
                  SuperForm.of(context);

                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            ),
          ),
        ),
      );

      expect(buildCounters[buildCounterName], 1);
      await tester.enterText(find.byKey(inputKey), "hello world");
      expect(buildCounters[buildCounterName], 2);
    });

    testWidgets('of without listen', (WidgetTester tester) async {
      const inputKey = Key('input');

      // This must be unique between all tests
      const buildCounterName = "ofnolisten";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: "name",
                ),
                Builder(builder: (context) {
                  SuperForm.of(context, listen: false);

                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            ),
          ),
        ),
      );

      expect(buildCounters[buildCounterName], 1);
      await tester.enterText(find.byKey(inputKey), "hello world");
      expect(buildCounters[buildCounterName], 1);
    });

    testWidgets('ofMaybe with listen', (WidgetTester tester) async {
      const inputKey = Key('input');

      // This must be unique between all tests
      const buildCounterName = "ofmaybe";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: "name",
                ),
                Builder(builder: (context) {
                  SuperForm.ofMaybe(context);

                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            ),
          ),
        ),
      );

      expect(buildCounters[buildCounterName], 1);
      await tester.enterText(find.byKey(inputKey), "hello world");
      expect(buildCounters[buildCounterName], 2);
    });

    testWidgets('ofMaybe without listen', (WidgetTester tester) async {
      const inputKey = Key('input');

      // This must be unique between all tests
      const buildCounterName = "ofmaybenolisten";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: "name",
                ),
                Builder(builder: (context) {
                  SuperForm.ofMaybe(context, listen: false);

                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            ),
          ),
        ),
      );

      expect(buildCounters[buildCounterName], 1);
      await tester.enterText(find.byKey(inputKey), "hello world");
      expect(buildCounters[buildCounterName], 1);
    });

    testWidgets('ofField', (WidgetTester tester) async {
      const inputKey = Key('input');
      const anotherInput = Key('anotherInput');

      // 1st null because field is not registered yet
      // 2nd null because field was registered but it is null
      // 3rd value because field was edited
      final expectedValues = [null, null, "hello world"];
      final seenValues = [];

      // This must be unique between all tests
      const buildCounterName = "offield";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: "name",
                ),
                TextSuperFormField(
                  key: anotherInput,
                  name: "anotherField",
                ),
                Builder(builder: (context) {
                  final state = SuperForm.ofField(context, "anotherField");
                  seenValues.add(state.values["anotherField"]);
                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.enterText(find.byKey(inputKey), "hello world");
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.enterText(find.byKey(anotherInput), "hello world");
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 3);

      expect(seenValues, expectedValues);
    });

    testWidgets('ofFieldMaybe', (WidgetTester tester) async {
      const inputKey = Key('input');
      const anotherInput = Key('anotherInput');

      // 1st null because field is not registered yet
      // 2nd null because field was registered but it is null
      // 3rd value because field was edited
      final expectedValues = [null, null, "hello world"];
      final seenValues = [];

      // This must be unique between all tests
      const buildCounterName = "offieldmaybe";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: "name",
                ),
                TextSuperFormField(
                  key: anotherInput,
                  name: "anotherField",
                ),
                Builder(builder: (context) {
                  final state = SuperForm.ofFieldMaybe(context, "anotherField");
                  seenValues.add(state?.values["anotherField"]);
                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.enterText(find.byKey(inputKey), "hello world");
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.enterText(find.byKey(anotherInput), "hello world");
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 3);

      expect(seenValues, expectedValues);
    });

    testWidgets('ofFieldValue', (WidgetTester tester) async {
      const name1 = "firstField";
      const name2 = "secondField";

      const inputKey = Key(name1);
      const anotherInput = Key(name2);

      // 1st null because field is not registered yet
      // 2nd null because field was registered but it is null
      // 3rd and 4th value because field was edited
      final expectedValues = [null, null, "hello world", "hi"];
      final seenValues = [];

      // This must be unique between all tests
      const buildCounterName = "offieldvalue";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            child: Builder(
              builder: (context) => Column(children: [
                TextSuperFormField(
                  key: inputKey,
                  name: name1,
                ),
                TextSuperFormField(
                  key: anotherInput,
                  name: name2,
                ),
                Builder(builder: (context) {
                  final f = SuperForm.ofFieldValue(context, name2);
                  seenValues.add(f);
                  return Column(children: [
                    BuildCounter(name: buildCounterName),
                    Text("Value: $f")
                  ]);
                }),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.enterText(find.byKey(inputKey), "hello world");
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.enterText(find.byKey(anotherInput), "hello world");
      await tester.pumpAndSettle();
      expect(find.text("Value: hello world"), findsOneWidget);
      expect(buildCounters[buildCounterName], 3);

      await tester.enterText(find.byKey(anotherInput), "hi");
      await tester.pumpAndSettle();
      expect(find.text("Value: hi"), findsOneWidget);
      expect(buildCounters[buildCounterName], 4);

      expect(seenValues, expectedValues);
    });

    testWidgets('ofField updates when form properties are changed',
        (WidgetTester tester) async {
      // This must be unique between all tests
      const buildCounterName = "offield-form-properties";

      await tester.pumpWidget(
        boilerplate(
          child: Builder(builder: (context) {
            return SuperFormMangler(
              child: Column(children: [
                TextSuperFormField(name: "name"),
                Builder(builder: (context) {
                  SuperForm.ofField(context, "name");

                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            );
          }),
        ),
      );

      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.tap(find.text("Disable"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 3);

      await tester.tap(find.text("Set onBlur"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 4);

      // These are not providing any real change
      await tester.tap(find.text("Set onBlur"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 4);

      await tester.tap(find.text("Disable"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 4);
    });

    testWidgets('of updates when form properties are changed',
        (WidgetTester tester) async {
      // This must be unique between all tests
      const buildCounterName = "of-form-properties";

      await tester.pumpWidget(
        boilerplate(
          child: Builder(builder: (context) {
            return SuperFormMangler(
              child: Column(children: [
                TextSuperFormField(name: "name"),
                Builder(builder: (context) {
                  SuperForm.of(context);

                  return BuildCounter(name: buildCounterName);
                }),
              ]),
            );
          }),
        ),
      );

      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 2);

      await tester.tap(find.text("Disable"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 3);

      await tester.tap(find.text("Set onBlur"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 4);

      // These are not providing any real change
      await tester.tap(find.text("Set onBlur"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 4);

      await tester.tap(find.text("Disable"));
      await tester.pumpAndSettle();
      expect(buildCounters[buildCounterName], 4);
    });
  });
}
