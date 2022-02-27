import 'package:flutter/material.dart';
import 'package:super_form_example/sign_up/sign_up.dart';
import 'package:super_form_example/survey/survey.dart';

import 'burritox/burritox.dart';

void main() {
  runApp(ExamplesApp());
}

/// Entrypoint for the super SuperForm examples.
///
/// Visit https://superform.dev
class ExamplesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: "example_app",
      title: 'Super Form Demo',
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case "sign_up":
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case "burritox":
            return MaterialPageRoute(
              builder: (_) => Theme(
                data: ThemeData(primarySwatch: Colors.deepOrange),
                child: const Burritox(),
              ),
            );
          case "survey":
            return MaterialPageRoute(
              builder: (_) => Theme(
                data: ThemeData(primarySwatch: Colors.green),
                child: const SurveyPage(),
              ),
            );
        }
        return null;
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "SuperForm examples library 📕",
          ),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: [
              ListTile(
                title: const Text("Sign Up"),
                subtitle:
                    const Text("Classic sign up form with gradual validation"),
                onTap: () {
                  Navigator.of(context).restorablePushNamed("sign_up");
                },
              ),
              ListTile(
                title: const Text("Survey"),
                subtitle: const Text(
                    "Survey with sliders, dynamic email field, navigation block and loading state"),
                onTap: () {
                  Navigator.of(context).restorablePushNamed("survey");
                },
              ),
              ListTile(
                title: const Text("Burritox"),
                subtitle: const Text(
                    "Takeaway order with checkboxes, dynamic rules and editing"),
                onTap: () {
                  Navigator.of(context).restorablePushNamed("burritox");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
