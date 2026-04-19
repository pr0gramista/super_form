import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_example/survey/survey.dart';

const experienceScoreKey = Key('experience_score');
const deliveryScoreKey = Key('delivery_score');
const emailKey = Key('email');

void main() {
  group('Survey', () {
    void setUpTester(WidgetTester tester) {
      // Built for big screens
      tester.binding.platformDispatcher.textScaleFactorTestValue = 0.5;
      tester.view.physicalSize = const Size(1600, 2000);
      tester.view.devicePixelRatio = 1;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(
        tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
      );
    }

    testWidgets('can complete without email', (WidgetTester tester) async {
      setUpTester(tester);
      await tester.pumpWidget(const MaterialApp(home: SurveyPage()));
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(experienceScoreKey), const Offset(100, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text("SEND"));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "{experience_score: 4.0, delivery_score: 3.0, showEmail: null}",
        ),
        findsOneWidget,
      );
    });

    testWidgets('can complete with email', (WidgetTester tester) async {
      setUpTester(tester);
      await tester.pumpWidget(const MaterialApp(home: SurveyPage()));
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(experienceScoreKey), const Offset(100, 0));
      await tester.pumpAndSettle();

      await tester
          .tap(find.textContaining("I want to receive emails with special"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("SEND"));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Your email address"),
        findsOneWidget,
      );

      await tester.enterText(find.byKey(emailKey), "test@pr0gramista.pl");
      await tester.pumpAndSettle();

      await tester.tap(find.text("SEND"));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "{experience_score: 4.0, delivery_score: 3.0, showEmail: [yes], email: test@pr0gramista.pl}",
        ),
        findsOneWidget,
      );
    });
  });
}
