import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_example/burritox/burritox.dart';

const countKey = Key('count');
const plusKey = Key('plus');
const minusKey = Key('minus');
const submitKey = Key('submit');
const checkoutKey = Key('checkout');

void main() {
  group('Burritox', () {
    void setUpTester(WidgetTester tester) {
      // Burritox is built for big screens
      tester.binding.window.physicalSizeTestValue = const Size(1600, 2000);
      tester.binding.window.devicePixelRatioTestValue = 1;
      tester.binding.window.textScaleFactorTestValue = 0.5;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      addTearDown(tester.binding.window.clearTextScaleFactorTestValue);
    }

    testWidgets('can keep multiple SuperForm instances',
        (WidgetTester tester) async {
      setUpTester(tester);

      await tester.pumpWidget(const MaterialApp(home: Burritox()));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Salsa mango"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Salsa chili"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Mayo"));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(plusKey));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(submitKey));
      await tester.pumpAndSettle();

      expect(find.text("You can't choose more sauces"), findsOneWidget);
      await tester.tap(find.text("Salsa chili"));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(submitKey));
      await tester.pumpAndSettle();
      expect(find.text("You can't choose more sauces"), findsNothing);
      expect(find.text("2x"), findsOneWidget);

      // Select salsa mango and mayo on "Add" form
      await tester.tap(find.text("Salsa mango"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Guacamole"));
      await tester.pumpAndSettle();

      // Open edit form
      await tester.tap(find.text("2x"));
      await tester.pumpAndSettle();

      // Increace count to 3x and save
      await tester.tap(find.byKey(plusKey).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(submitKey).last);
      await tester.pumpAndSettle();

      // Count has changed
      expect(find.text("3x"), findsOneWidget);

      // Add new burrito
      await tester.tap(find.byKey(submitKey));
      await tester.pumpAndSettle();

      expect(find.text("1x"), findsOneWidget);

      await tester.tap(find.byKey(checkoutKey));
      await tester.pumpAndSettle();

      expect(
          find.text(
              "[BurritoOrder(Burrito(beef, {salsa_mango, mayo}, {}), 3), BurritoOrder(Burrito(beef, {salsa_mango, guacamole}, {}), 1)]"),
          findsOneWidget);
    });
  });
}
