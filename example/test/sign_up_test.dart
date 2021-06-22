import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_example/sign_up/sign_up.dart';

const emailKey = Key('email');
const passwordKey = Key('password');
const password2Key = Key('password2');
const termsAndConditionsKey = Key('tc');

void main() {
  group('Sign Up', () {
    testWidgets('checks with complex validation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

      await tester.enterText(find.byKey(emailKey), "testpr0gramista.pl");
      await tester.pumpAndSettle();
      expect(find.text("Must be a valid email"), findsOneWidget);

      await tester.enterText(find.byKey(emailKey), "test@pr0gramista.pl");
      await tester.pumpAndSettle();
      expect(find.text("Must be a valid email"), findsNothing);

      await tester.enterText(find.byKey(passwordKey), "hello1");
      await tester.pumpAndSettle();
      expect(find.text("This password is too weak!"), findsOneWidget);

      await tester.enterText(find.byKey(passwordKey), "hello111");
      await tester.pumpAndSettle();
      expect(find.text("This password is too weak!"), findsNothing);

      await tester.enterText(find.byKey(password2Key), "hello11");
      await tester.pumpAndSettle();
      expect(find.text("Passwords must match"), findsOneWidget);

      await tester.enterText(find.byKey(password2Key), "hello111");
      await tester.pumpAndSettle();
      expect(find.text("Passwords must match"), findsNothing);

      await tester.tap(find.text("Create account"));
      await tester.pumpAndSettle();

      expect(
        find.text("You must accept our Terms & Condition to continue"),
        findsOneWidget,
      );

      await tester.tap(find.byKey(termsAndConditionsKey));
      await tester.tap(find.text("Create account"));
      await tester.pumpAndSettle();

      expect(find.text("Form values"), findsOneWidget);
    });
  });
}
