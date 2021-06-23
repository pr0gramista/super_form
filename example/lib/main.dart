import 'package:flutter/material.dart';
import 'package:super_form_example/sign_up/sign_up.dart';
import 'package:super_form_example/survey/survey.dart';

import 'burritox/burritox.dart';

void main() {
  runApp(MyBeautifulApp());
}

/// Entrypoint for our beautiful example app
///
/// Visit https://superform.dev/example for preview
class MyBeautifulApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Form Demo',
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case "sign_up":
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case "burrito":
            return MaterialPageRoute(
              builder: (_) => Theme(
                data: ThemeData(primarySwatch: Colors.deepOrange),
                child: const Burritox(),
              ),
            );
          case "survey":
            return MaterialPageRoute(
              builder: (_) => Theme(
                data: ThemeData(primarySwatch: Colors.blueGrey),
                child: const SurveyPage(),
              ),
            );
        }
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "SuperForm examples library 📕",
          ),
        ),
        body: Builder(
          builder: (context) => Column(
            children: const [
              RouteButton(routeName: "sign_up", name: "Sign Up"),
              RouteButton(routeName: "burrito", name: "Burritox"),
              RouteButton(routeName: "survey", name: "Survey"),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteButton extends StatelessWidget {
  final String name;
  final String routeName;

  const RouteButton({
    Key? key,
    required this.routeName,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(routeName);
        },
        child: Text(name),
      ),
    );
  }
}
