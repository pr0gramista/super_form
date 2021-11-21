import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:super_form/super_form.dart';

Widget boilerplate({required Widget child, String? restorationScopeId}) {
  return MaterialApp(
    restorationScopeId: restorationScopeId,
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

class SuperFormMangler extends StatefulWidget {
  final Widget child;

  const SuperFormMangler({Key? key, required this.child}) : super(key: key);

  @override
  State<SuperFormMangler> createState() => _SuperFormManglerState();
}

class _SuperFormManglerState extends State<SuperFormMangler> {
  bool enabled = true;
  ValidationMode validationMode = ValidationMode.onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SuperForm(
        enabled: enabled,
        validationMode: validationMode,
        child: widget.child,
      ),
      TextButton(
        onPressed: () {
          setState(() {
            enabled = false;
          });
        },
        child: const Text("Disable"),
      ),
      TextButton(
        onPressed: () {
          setState(() {
            validationMode = ValidationMode.onBlur;
          });
        },
        child: const Text("Set onBlur"),
      )
    ]);
  }
}

class SubmitListener extends Mock {
  void call(Map<String, dynamic> values);
}

class VoidListener extends Mock {
  void call();
}

class CheckboxChangedListener<T> extends Mock {
  void call(T value, bool checked);
}

class SliderChangedListener<T> extends Mock {
  void call(double value);
}

class RadioChangedListener<T> extends Mock {
  void call(T? value);
}

class DropdownListener<T> extends Mock {
  void call(T value);
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
