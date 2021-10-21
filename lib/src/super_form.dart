import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'super_form_field.dart';

export 'enums.dart';
export 'fields/checkbox_super_form_field.dart';
export 'fields/dropdown_super_form_field.dart';
export 'fields/radio_super_form_field.dart';
export 'fields/slider_super_form_field.dart';
export 'fields/text_super_form_field.dart';
export 'rules.dart';
export 'super_form_error_text.dart';
export 'super_form_field.dart';

void _doNothing(dynamic _) {}

Random _random = Random();

/// SuperForm container and state manager.
///
/// Each individual field should implement [SuperFormField] with
/// the [SuperForm] widget as a common ancestor of all of those.
///
/// You can use [SuperForm.of] or pass [GlobalKey] to be able to retrieve
/// the [SuperFormState] instance. [SuperFormState] can be called to update,
/// validate, register, unregister fields or to get their state.
///
/// [validationMode] can be provided to customize when fields are validated.
///
/// [onSubmit] is called when form is submitted and contains no errors.
///
/// [onChange] is called when fields is being modified.
///
/// [onInit] is called right after state is initialized. This can be helpful
/// when you want to manually register a field.
///
/// ```dart
/// final _formKey = GlobalKey<SuperFormState>();
///
/// @override
/// Widget build(BuildContext context) {
///   return SuperForm(
///     key: _formKey,
///     onInit: (form) {
///       form.register(
///         name: "rememberMe",
///         rules: [],
///       );
///     },
///     onSubmit: (values) {
///       print(values.toString());
///     },
///     child: Column(
///       children: [
///         TextSuperFormField(
///           name: "login",
///           rules: [Required("Login is required")],
///         ),
///         SizedBox(height: 8),
///         TextSuperFormField(
///           name: "password",
///           obscureText: true,
///           rules: [Required("Password is required")],
///         ),
///         SizedBox(height: 8),
///         OutlinedButton(
///           onPressed: () {
///             _formKey.currentState?.submit();
///           },
///           child: Text("Sign in"),
///         )
///       ],
///     ),
///   );
/// }
/// ```
class SuperForm extends StatefulWidget {
  final Widget child;
  final ValidationMode validationMode;
  final Function(Map<String, dynamic> values) onSubmit;
  final Function(Map<String, SuperFormFieldData> fields) onChange;
  final Function(SuperFormState form) onInit;

  /// Restoration ID to save and restore form values
  ///
  /// See [RestorationManager], which explains how state restoration works in Flutter.
  final String? restorationId;

  /// Map of initial values which will be obtained by field when registered or reset
  ///
  /// Modifying this field without resetting the form or registering fields has no effects.
  final Map<String, dynamic> initialValues;

  const SuperForm({
    Key? key,
    required this.child,
    this.onSubmit = _doNothing,
    this.validationMode = ValidationMode.onSubmit,
    this.onInit = _doNothing,
    this.onChange = _doNothing,
    this.initialValues = const {},
    this.restorationId,
  }) : super(key: key);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty("validationMode", validationMode));
    properties.add(DiagnosticsProperty<Map<String, dynamic>>(
        "initialValues", initialValues));
  }

  /// Gets the closest [SuperFormState] instance.
  ///
  /// If there is no [SuperForm] in scope, this will throw a [TypeError]
  /// exception in release builds, and throw a descriptive [FlutterError] in
  /// debug builds.
  ///
  /// Use this version only when you are sure that the instance is available and you
  /// actually want an error when it doesn't.
  ///
  /// If [listen] is true then widgets using this method will be updated every
  /// time any field changes. If false then the widget will update only when form properties
  /// has changed. If you need to listen for a specific field then use optimized [ofField] instead.
  ///
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () {
  ///     SuperForm.of(context, listen: false).submit();
  ///   },
  ///   child: const Text("Submit"),
  /// )
  /// ```
  ///
  /// See also:
  /// * [ofMaybe] - null safe, not field specific version
  /// * [ofField] - non-null safe, field specific version
  /// * [ofFieldMaybe] - null safe, field specific version
  static SuperFormState of(BuildContext context, {bool listen = true}) {
    return _SuperFormScope.of(context, aspect: listen ? null : "");
  }

  /// Gets the closest [SuperFormState] instance.
  ///
  /// Null safe version of [of] which will not throw errors when SuperForm is not
  /// found. Prefer this version when implementing controllers.
  ///
  /// If [listen] is true then widgets using this method will be updated every
  /// time any field changes. If false then the widget will update only when form properties
  /// has changed. If you need to listen for a specific field then use optimized [ofFieldMaybe] instead.
  ///
  /// See also:
  /// * [of] - non-null safe, not field specific version
  /// * [ofField] - non-null safe, field specific version
  /// * [ofFieldMaybe] - null safe, field specific version
  static SuperFormState? ofMaybe(BuildContext context, {bool listen = true}) {
    return _SuperFormScope.ofMaybe(context, aspect: listen ? null : "");
  }

  /// Gets the closest [SuperFormState] instance.
  ///
  /// If there is no [SuperForm] in scope, this will throw a [TypeError]
  /// exception in release builds, and throw a descriptive [FlutterError] in
  /// debug builds.
  ///
  /// Use this version only when you are sure that the instance is available and you
  /// actually want an error when it doesn't.
  ///
  /// This version will make the using widget update only when field with given name
  /// was modified.
  ///
  /// See also:
  /// * [of] - non-null safe, not field specific version
  /// * [ofMaybe] - null safe, not field specific version
  /// * [ofFieldMaybe] - null safe, field specific version
  static SuperFormState ofField(BuildContext context, String fieldName) {
    return _SuperFormScope.ofField(context, fieldName);
  }

  /// Gets the closest [SuperFormState] instance.
  ///
  /// Null safe version of [ofField] which will not throw errors when SuperForm is not
  /// found. Prefer this version when implementing controllers.
  ///
  /// This version will make the using widget update only when field with given name
  /// was modified.
  ///
  /// ```dart
  /// final formState = SuperForm.ofFieldMaybe(context, name);
  /// final fieldState = formState?.fields[name];
  ///
  /// return Checkbox(
  ///   value: fieldState?.value ?? false,
  ///   onChanged: (newValue) {
  ///     formState?.setValue(name, newValue);
  ///   },
  /// );
  /// ```
  ///
  /// See also:
  /// * [of] - non-null safe, not field specific version
  /// * [ofMaybe] - null safe, not field specific version
  /// * [ofField] - non-null safe, field specific version
  static SuperFormState? ofFieldMaybe(BuildContext context, String fieldName) {
    return _SuperFormScope.ofFieldMaybe(context, fieldName);
  }

  /// Gets the field value of the closest [SuperFormState] instance.
  ///
  /// Using this method will make the subscriber update only when field with given name
  /// was modified.
  ///
  /// In most cases subscribers should expect at least one build with a null value.
  ///
  /// ```dart
  /// final showEmploymentFields = SuperForm.ofFieldValue<bool>(context, "employment") ?? false;
  /// ```
  static T? ofFieldValue<T>(BuildContext context, String fieldName) {
    return _SuperFormScope.ofFieldMaybe(context, fieldName)
        ?.data[fieldName]
        ?.value as T?;
  }

  @override
  SuperFormState createState() => SuperFormState();
}

bool _debugHasSuperFormInScope(BuildContext context) {
  assert(() {
    if (context.widget is! _SuperFormScope &&
        context.findAncestorWidgetOfExactType<_SuperFormScope>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No SuperForm widget ancestor found.'),
        ErrorDescription(
            '${context.widget.runtimeType} requires a SuperForm widget ancestor.'),
        ErrorHint(
            'No SuperForm ancestor could be found starting from the context '
            'that was passed to SuperForm.of(). This can happen because you '
            'have not added a SuperForm widget on top of your form, or it can happen if the '
            'context you use comes from the widget building SuperForm widget, in that case '
            'consider wrapping the part of the tree with a Builder widget like this:'),
        ErrorHint('''
Builder(
  builder: (context) => TextButton(
    onPressed: () => SuperForm.of(context, listen: false).submit(),
    child: const Text("Submit"),
  ),
);
        '''),
        context.describeWidget(
            'The specific widget that could not find a SuperForm ancestor was'),
      ]);
    }
    return true;
  }());
  return true;
}

class _SuperFormScope extends InheritedModel<String> {
  final SuperFormState state;

  // We will keep these values copied since it's state instance stays
  // the same - "old" state is current state.
  final Map<String, SuperFormFieldData> fieldsData;
  final ValidationMode validationMode;
  final String formId;

  _SuperFormScope({
    required Widget child,
    required this.state,
  })  : formId = state.formId,
        validationMode = state.validationMode,
        fieldsData = state.data,
        super(child: child);

  static SuperFormState of(BuildContext context, {String? aspect}) {
    assert(_debugHasSuperFormInScope(context));
    return InheritedModel.inheritFrom<_SuperFormScope>(context, aspect: aspect)!
        .state;
  }

  static SuperFormState? ofMaybe(BuildContext context, {String? aspect}) {
    return InheritedModel.inheritFrom<_SuperFormScope>(context, aspect: aspect)
        ?.state;
  }

  static SuperFormState ofField(BuildContext context, String field) {
    assert(_debugHasSuperFormInScope(context));
    return InheritedModel.inheritFrom<_SuperFormScope>(
      context,
      aspect: field,
    )!
        .state;
  }

  static SuperFormState? ofFieldMaybe(BuildContext context, String field) {
    return InheritedModel.inheritFrom<_SuperFormScope>(
      context,
      aspect: field,
    )?.state;
  }

  bool _propertiesCheck(_SuperFormScope old) {
    if (formId != old.formId) return true;

    if (validationMode != old.validationMode) return true;

    return false;
  }

  @override
  bool updateShouldNotify(_SuperFormScope old) {
    if (_propertiesCheck(old)) return true;

    return old.fieldsData != fieldsData ||
        mapEquals(old.fieldsData, fieldsData);
  }

  @override
  bool updateShouldNotifyDependent(
      _SuperFormScope old, Set<String> fieldNames) {
    if (_propertiesCheck(old)) return true;

    for (final name in fieldNames) {
      if (old.fieldsData[name] != fieldsData[name]) {
        return true;
      }
    }
    return false;
  }
}

/// Field data
///
/// All field properties are handled manually, including validation.
/// This is true as well for [touched], [submitted], [errors] as some
/// would expect those to operate "magically".
class SuperFormFieldData extends Equatable {
  /// Field name
  final String name;

  /// Field rules
  final List<SuperFormFieldRule> rules;

  /// Field's current value
  final dynamic value;

  /// Whether the field was touched
  final bool touched;

  /// Field errors, might not be adequate to current value
  final List<ValidationError> errors;

  /// Whether the field was submitted
  final bool submitted;

  const SuperFormFieldData({
    required this.name,
    required this.value,
    required this.rules,
    required this.touched,
    required this.errors,
    required this.submitted,
  });

  static SuperFormFieldData? of(BuildContext buildContext, String name) {}

  SuperFormFieldData reset(dynamic newInitialValue) {
    return SuperFormFieldData(
      name: name,
      rules: rules,
      touched: false,
      errors: const [],
      submitted: false,
      value: newInitialValue,
    );
  }

  SuperFormFieldData copyWithValue({
    required dynamic value,
    String? name,
    List<SuperFormFieldRule>? rules,
    bool? touched,
    List<ValidationError>? errors,
    bool? submitted,
  }) {
    return SuperFormFieldData(
      name: name ?? this.name,
      rules: rules ?? this.rules,
      touched: touched ?? this.touched,
      errors: errors ?? this.errors,
      submitted: submitted ?? this.submitted,
      value: value,
    );
  }

  SuperFormFieldData copyWith({
    String? name,
    List<SuperFormFieldRule>? rules,
    bool? touched,
    List<ValidationError>? errors,
    bool? submitted,
  }) {
    return SuperFormFieldData(
      name: name ?? this.name,
      rules: rules ?? this.rules,
      touched: touched ?? this.touched,
      errors: errors ?? this.errors,
      submitted: submitted ?? this.submitted,
      value: value,
    );
  }

  /// Validates the field against its rules and returns updated copy
  SuperFormFieldData validate({bool markSubmitted = false}) {
    final errors = rules
        .map((r) => r.validate(value))
        .where((element) => element != null)
        .map<ValidationError>((r) => r!)
        .toList();

    return copyWith(submitted: markSubmitted || submitted, errors: errors);
  }

  @override
  List<Object?> get props => [name, value, rules, touched, errors, submitted];
}

/// [SuperForm] state which holds all field data and can be called to modify the form.
class SuperFormState extends State<SuperForm> with RestorationMixin {
  ValidationMode _validationMode = ValidationMode.onSubmit;
  final String _formId =
      (_random.nextInt(15728640) + 1048576).toRadixString(16);

  final List<SuperFormFieldState> _fields = [];
  Map<String, SuperFormFieldData> _fieldsData = {};

  /// Form id - just a string of random characters, uuid like.
  String get formId => _formId;

  Map<String, SuperFormFieldData> get data => _fieldsData;

  ValidationMode get validationMode => _validationMode;

  /// Gets a map of field names and their values.
  Map<String, dynamic> get values =>
      data.map((key, field) => MapEntry(key, field.value));

  /// Gets a map of field names and their errors.
  Map<String, List<ValidationError>> get errors =>
      data.map((key, field) => MapEntry(key, field.errors));

  final _RestorableSuperFormValues _restorableFormValues =
      _RestorableSuperFormValues();

  @override
  void initState() {
    super.initState();

    _validationMode = widget.validationMode;

    // This is called in [restoreState] to already have restored values as
    // onInit may depend on them i.e. registration of manual field
    // widget.onInit(this);
  }

  @override
  void didUpdateWidget(covariant SuperForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.validationMode != oldWidget.validationMode) {
      _validationMode = widget.validationMode;
    }
  }

  /// Sets value for field under given name.
  ///
  /// This method cannot be on non-registered names. When that happens
  /// [StateError] is thrown.
  ///
  /// This will update the field and therefore trigger didChangeDependencies
  /// on subscribing widgets. When changing multiple properties be careful with
  /// the order of operations or consider using [updateFieldData] instead.
  void setValue(String name, dynamic value) {
    final SuperFormFieldData? fieldData = data[name];

    if (fieldData == null) {
      throw StateError(
          'Field $name is not registered so a value cannot be changed. Have you forget to register your field manually?');
    }

    updateFieldData(fieldData.copyWithValue(value: value));
  }

  /// Updates field data.
  ///
  /// This method cannot be on non-registered names. When that happens
  /// [StateError] is thrown.
  ///
  /// This will update the field and therefore trigger didChangeDependencies
  /// on subscribing widgets.
  void updateFieldData(SuperFormFieldData newData) {
    if (!data.containsKey(newData.name)) {
      throw StateError(
          "You are trying to update field ${newData.name}, but it is not registered");
    }

    _fieldsData = {..._fieldsData, newData.name: newData};
    _triggerRebuild();

    widget.onChange(_fieldsData);

    _restorableFormValues.value =
        values.map((key, value) => MapEntry(key, value));
  }

  /// Validates field and updates it state
  ///
  /// This method cannot be on non-registered names. When that happens
  /// [StateError] is thrown.
  ///
  /// This will update the field and therefore trigger didChangeDependencies
  /// on subscribing widgets. When changing multiple properties be careful with
  /// the order of operations or consider using [updateFieldData] instead.
  bool validate(String name, {bool markSubmitted = false}) {
    final SuperFormFieldData? fieldData = _fieldsData[name];

    if (fieldData == null) {
      throw StateError(
          'Field $name is not registered so it cannot be validated. Have you forget to register your field manually?');
    }

    final newData = fieldData.validate(markSubmitted: markSubmitted);
    updateFieldData(newData);
    return newData.errors.isNotEmpty;
  }

  /// Sets touched value for field under given name.
  ///
  /// This method cannot be on non-registered names. When that happens
  /// [StateError] is thrown.
  ///
  /// This will update the field and therefore trigger didChangeDependencies
  /// on subscribing widgets. When changing multiple properties be careful with
  /// the order of operations or consider using [updateFieldData] instead.
  void setTouched(String name, bool touched) {
    final SuperFormFieldData? fieldData = _fieldsData[name];

    if (fieldData == null) {
      throw StateError(
          'Field $name is not registered so touched property cannot be changed. Have you forget to register your field manually?');
    }

    updateFieldData(fieldData.copyWith(touched: touched));
  }

  bool _validateFields() {
    final newFieldsData = _fieldsData.map(
        (key, field) => MapEntry(key, field.validate(markSubmitted: true)));

    _fieldsData = newFieldsData;
    _triggerRebuild();

    final bool hasError =
        newFieldsData.values.any((field) => field.errors.isNotEmpty);

    widget.onChange(data);
    return hasError;
  }

  /// Submits the form.
  ///
  /// Field will get validated, marked as submitted and updated.
  /// If there are no errors the [onSubmit] will be called with the
  /// form values.
  void submit() {
    final bool hasErrors = _validateFields();

    if (hasErrors) return;

    widget.onSubmit(values);
  }

  /// Registers the field for a given name with a set of rules.
  ///
  /// This field is usually called by [SuperFormField]s like
  /// [TextSuperFormField], but it is totally fine to call this method
  /// manually to register a field that doesn't have a controlling widget.
  ///
  /// If the field of given name is already registered then nothing changes
  /// and existing [SuperFormFieldData] is returned.
  SuperFormFieldData register({
    required String name,
    required List<SuperFormFieldRule> rules,
    SuperFormFieldState? fieldState,
  }) {
    assert(name.isNotEmpty, "Field name cannot be empty");
    final SuperFormFieldData? existingFieldData = _fieldsData[name];

    if (fieldState != null && !_fields.contains(fieldState)) {
      _fields.add(fieldState);
    }

    if (existingFieldData == null) {
      final newField = SuperFormFieldData(
        name: name,
        rules: rules,
        value: _restorableFormValues.value[name] ?? widget.initialValues[name],
        errors: const [],
        submitted: false,
        touched: false,
      );
      _fieldsData = {..._fieldsData, name: newField};

      _triggerRebuild();
      widget.onChange(data);
      return newField;
    } else {
      return existingFieldData;
    }
  }

  void _triggerRebuild() {
    Future.microtask(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _resetAllFields() {
    _fieldsData = _fieldsData.map((name, field) =>
        MapEntry(name, field.reset(widget.initialValues[name])));

    _fields.forEach((controller) {
      controller.didReset(this);
    });

    _triggerRebuild();
  }

  void _resetField(String name) {
    if (!data.containsKey(name)) {
      throw StateError(
          "You are trying to reset field $name, but it is not registered");
    }

    final field = _fieldsData[name]!;

    updateFieldData(field.reset(widget.initialValues[name]));

    _fields
        .where((controller) => controller.widget.name == name)
        .forEach((controller) => controller.didReset(this));
  }

  /// Resets all fields or one specific field with [name].
  void reset({String? name}) {
    if (name == null) {
      _resetAllFields();
    } else {
      _resetField(name);
    }
  }

  /// Un-registers the field, removing all of its data.
  ///
  /// If called with field state specified it will check if there is
  /// any other controlling widget left, removing data only if there is none left.
  ///
  /// If called with only a name it will remove the data unconditionally.
  /// Note however that if there is a controller for this field it may want
  /// to register the field again.
  ///
  /// Controlling widgets will usually call this method by themselves when their state
  /// is being disposed.
  void unregister({
    required String name,
    SuperFormFieldState? fieldState,
  }) {
    if (fieldState != null) {
      _fields.remove(fieldState);

      // If there are no other controller that means we can unregister the field state
      if (!_fields.any((element) => element.widget.name == name)) {
        _fieldsData = {...data};
        _fieldsData.removeWhere((key, value) => key == name);
        _triggerRebuild();
      }
    } else {
      _fieldsData = {...data};
      _fieldsData.removeWhere((key, value) => key == name);
      _triggerRebuild();
    }

    widget.onChange(data);
  }

  @override
  Widget build(BuildContext context) {
    return _SuperFormScope(
      state: this,
      child: widget.child,
    );
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableFormValues, 'formValues');

    widget.onInit(this);
  }
}

class _RestorableSuperFormValues extends RestorableValue<Map> {
  @override
  Map createDefaultValue() => {};

  @override
  void didUpdateValue(Map? oldValue) {
    notifyListeners();
  }

  @override
  Map fromPrimitives(Object? data) {
    final map = data as Map?;

    if (map == null) {
      return const {};
    }

    map.removeWhere((key, value) => key is! String);

    return map;
  }

  @override
  Object? toPrimitives() => value;
}

class ValidationError extends Error {
  final String message;

  ValidationError(this.message);

  @override
  String toString() {
    return 'ValidationError: "$message"';
  }
}

abstract class SuperFormFieldRule<T> {
  ValidationError? validate(T value);
}
