import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

Widget boilerplate({required Widget child}) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800.0, 600.0)),
        child: Center(
          child: Material(
            child: child,
          ),
        ),
      ),
    ),
  );
}

Map<String, int> buildCounters = {};

class BuildCounter extends StatelessWidget {
  final String name;

  // We don't want it to be const since it won't build
  // ignore: prefer_const_constructors_in_immutables
  BuildCounter({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    buildCounters[name] = (buildCounters[name] ?? 0) + 1;

    return Text("Building $name: ${buildCounters[name]}");
  }
}

class SubmitListener extends Mock {
  void call(Map<String, dynamic> values);
}

class VoidListener extends Mock {
  void call();
}

class RuleTestCase<T> {
  final T value;
  final bool isOk;

  const RuleTestCase(this.value, this.isOk);
}

class ParamRuleTestCase<T, P> {
  final T value;
  final P param;
  final bool isOk;

  const ParamRuleTestCase(this.value, this.param, this.isOk);
}
