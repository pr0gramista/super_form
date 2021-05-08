import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

void main() {
  group("SuperFormScope - of/ofMaybe/ofField/ofFieldMaybe", () {
    testWidgets('of with listen', (WidgetTester tester) async {
      const inputKey = Key('input');
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

    testWidgets('of without listen updates when form has changed',
        (WidgetTester tester) async {
      const inputKey = Key('input');
      const buildCounterName = "ofnolistenform";

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            validationMode: ValidationMode.onBlur,
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

      await tester.pumpWidget(
        boilerplate(
          child: SuperForm(
            validationMode: ValidationMode.onChange,
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

      expect(buildCounters[buildCounterName], 2);
    });

    testWidgets('ofMaybe with listen', (WidgetTester tester) async {
      const inputKey = Key('input');
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
                  SuperForm.ofField(context, "anotherField");
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
      await tester.enterText(find.byKey(anotherInput), "hello world");
      expect(buildCounters[buildCounterName], 2);
    });

    testWidgets('ofFieldMaybe', (WidgetTester tester) async {
      const inputKey = Key('input');
      const anotherInput = Key('anotherInput');
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
                  SuperForm.ofFieldMaybe(context, "anotherField");

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
      await tester.enterText(find.byKey(anotherInput), "hello world");
      expect(buildCounters[buildCounterName], 2);
    });
  });
}
