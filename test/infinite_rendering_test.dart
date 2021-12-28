import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

import 'utils.dart';

class InfiniteRenderingCase extends StatelessWidget {
  const InfiniteRenderingCase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SuperForm(
        child: Column(
      children: [
        Builder(builder: (context) {
          SuperForm.ofField(context, "field");

          return TextSuperFormField(
            name: "field",
            rules: [RequiredRule("Can't be empty")],
          );
        })
      ],
    ));
  }
}

void main() {
  testWidgets('renders in finite amount of frames',
      (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate(child: const InfiniteRenderingCase()));

    await tester.pumpAndSettle();
  });
}
