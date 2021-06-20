import 'package:flutter/widgets.dart';

import '../super_form.dart';

typedef SuperFormFieldBuilder<T> = Widget Function(
  BuildContext context,
  SuperFormFieldState fieldState,
  SuperFormState form,
);

/// Base widget for SuperFormFields like [TextSuperFormField].
///
/// These are also referred as field controlling widgets since they
/// register fields, thus requiring [name] and [rules].
///
/// It is fine to implement your own fields without extending this widget
/// especially when you wrap stateless widgets, but utilities provided by
/// this state might be helpful when implementing more complicated controls.
///
/// See also:
///   * [SuperFormFieldState] for description what underlying state does
class SuperFormField extends StatefulWidget {
  final SuperFormFieldBuilder builder;

  /// Field validation rules
  final List<SuperFormFieldRule> rules;

  /// Name of the field
  final String name;

  /// Fallback widget for a case where SuperForm ancestor is unavailable
  final Widget noFormFallback;

  final FocusNode? focusNode;

  const SuperFormField({
    Key? key,
    required this.builder,
    required this.name,
    this.rules = const [],
    this.noFormFallback = const SizedBox(),
    this.focusNode,
  }) : super(key: key);

  @override
  SuperFormFieldState createState() => SuperFormFieldState();
}

/// Base state for controls like [TextSuperFormField].
///
/// Base class does few things:
/// * It listens via [SuperForm.ofFieldMaybe] for the form and field data and
/// saves the references as [form] and [data]
/// * Registers and un-registers itself and field
/// * It checks if the SuperForm has been replaced via formId and calls [reset]
/// when that happens
/// * Provides few proxy methods for validating and changing value/touched
/// * Builds the [widget.builder]. If the form is not available it defaults
/// to [widget.noFormFallback]
class SuperFormFieldState extends State<SuperFormField> {
  SuperFormFieldData? data;
  SuperFormState? form;
  String? _lastKnownFormStateId;
  FocusNode? _stateFocusNode;
  bool focused = false;

  FocusNode get focusNode =>
      widget.focusNode ?? (_stateFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    form = SuperForm.ofFieldMaybe(context, widget.name);
    data = form?.data[widget.name];

    if (form != null &&
        (_lastKnownFormStateId == null ||
            _lastKnownFormStateId != form!.formId)) {
      data = form!.register(
        name: widget.name,
        rules: widget.rules,
        fieldState: this,
      );

      didReset(form!);
    }

    _lastKnownFormStateId = form?.formId;
  }

  @override
  void didUpdateWidget(covariant SuperFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.name != oldWidget.name) {
      form = SuperForm.ofFieldMaybe(context, widget.name);
      data = form?.data[widget.name];

      form?.unregister(
        name: oldWidget.name,
        fieldState: this,
      );

      data = form!.register(
        name: widget.name,
        rules: widget.rules,
        fieldState: this,
      );

      didReset(form!);
    }

    // Only rules have changed
    if (oldWidget.rules != widget.rules && widget.name == oldWidget.name) {
      form?.updateFieldData(data!.copyWith(rules: widget.rules));

      if (data?.submitted ?? false) {
        validate();
      }
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _stateFocusNode?.removeListener(onFocusChanged);

      focusNode.addListener(onFocusChanged);
    }

    _lastKnownFormStateId = form?.formId;
  }

  /// Called when field is initiated or reset
  ///
  /// Can be used to reset underlying stateful controllers like [TextEditingController]
  void didReset(SuperFormState formState) {
    data = formState.data[widget.name];
  }

  void validate({bool markSubmitted = false}) {
    form?.validate(widget.name, markSubmitted: markSubmitted);
  }

  void setValue(dynamic value) {
    form?.setValue(widget.name, value);
  }

  void setTouched(bool value) {
    form?.setTouched(widget.name, value);
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      focused = true;
    } else {
      if (focused) {
        focused = false;

        if (form?.validationMode == ValidationMode.onBlur) {
          validate(markSubmitted: true);
        }
      }
    }
  }

  @override
  void deactivate() {
    form?.unregister(
      name: widget.name,
      fieldState: this,
    );

    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _stateFocusNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (form == null) {
      return widget.noFormFallback;
    }

    form?.register(
      name: widget.name,
      rules: widget.rules,
      fieldState: this,
    );

    return widget.builder(context, this, form!);
  }
}
