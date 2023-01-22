import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_form/super_form.dart';

Set<T> _correctValue<T>(dynamic value) {
  if (value == null) return {};
  if (value is Set<T>) return value;
  if (value is Iterable<T>) return value.toSet();
  if (value is List) {
    // Case to handle RestorationValue which type is List<Object?>
    return value.map((e) => e as T).toSet();
  }
  throw ArgumentError.value(
      value, "value", "CheckboxSuperFormField value must be a Iterable<T>");
}

/// A pair of value and optional label for a single checkbox.
///
/// Label is optional since some people may want to implement more complex
/// checkboxes and having single widget is quite limiting. [value] or extending
/// class propeperties should be used to provide more information.
class CheckboxOption<T> {
  final T value;
  final Widget? label;

  const CheckboxOption(this.value, this.label);
}

/// Builder for [CheckboxSuperFormField] which builds a [Column] with
/// [CheckboxListTile] for each [CheckboxOption].
Widget listTileCheckboxBuilder<T>(
  BuildContext context,
  CheckboxState<T> state, {
  Color? activeColor,
  Color? checkColor,
  Color? tileColor,
  Widget Function(CheckboxOption<T> option)? subtitle,
  bool isThreeLine = false,
  bool? dense,
  Widget? secondary,
  bool Function(CheckboxOption<T> option)? selected,
  ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
  bool autofocus = false,
  EdgeInsetsGeometry? contentPadding,
  ShapeBorder? shape,
  Color? selectedTileColor,
}) {
  return Focus(
    focusNode: state.focusNode,
    skipTraversal: true,
    child: Column(
      children: state.options.map((option) {
        final checked = state.checkedValues?.contains(option.value) ?? false;

        return CheckboxListTile(
          value: checked,
          activeColor: activeColor,
          checkColor: checkColor,
          tileColor: tileColor,
          title: option.label,
          subtitle: subtitle != null ? subtitle(option) : null,
          isThreeLine: isThreeLine,
          dense: dense,
          secondary: secondary,
          // ignore: avoid_bool_literals_in_conditional_expressions
          selected: selected != null ? selected(option) : false,
          controlAffinity: controlAffinity,
          autofocus: autofocus,
          contentPadding: contentPadding,
          shape: shape,
          selectedTileColor: selectedTileColor,
          onChanged: state.onChanged != null
              ? (checked) {
                  state.onChanged!(option.value, checked!);
                }
              : null,
        );
      }).toList(),
    ),
  );
}

/// Encapsulates checkbox field state into a single object.
class CheckboxState<T> {
  final List<CheckboxOption<T>> options;
  final Set<T>? checkedValues;
  final void Function(T value, bool checked)? onChanged;
  final FocusNode focusNode;

  const CheckboxState(
    this.options,
    this.checkedValues,
    this.onChanged,
    this.focusNode,
  );
}

typedef CheckboxBuilder<T> = Widget Function(
  BuildContext context,
  CheckboxState<T> state,
);

/// Base class for creating checkboxes that extends [SuperFormField].
///
/// This widget's state automatically registers field for [name] so there is
/// no need for manual registration.
///
/// Specify [rules] to add validation for this field. Errors will not be displayed
/// automatically. Consider putting [SuperFormErrorText] below the field.
///
/// Checkboxes are operating on [Set], but can take any [Iterable<T>] that is compatible.
/// If the Set contains the value the checkbox is considered checked.
///
/// The field will automatically clear values that no longer have corresponding
/// options.
///
/// ```dart
/// CheckboxSuperFormField.listTile(
///   name: "consent",
///   options: const [
///     CheckboxOption("tc", Text("I agree to the Terms and Conditions")),
///     CheckboxOption("marketing",Text("I would like to receive marketing...")),
///     CheckboxOption("offers", Text("I would like to receive emails about...")),
///   ],
///   rules: [
///     ContainsRule(
///       const MapEntry("tc", true),
///       "In order to proceed you must agree to our Terms and Conditions",
///     )
///   ],
/// );
/// ```
///
/// See also:
///
///  * [RadioSuperFormField], which is radio version of this widget
class CheckboxSuperFormField<T> extends SuperFormField {
  /// List of available options
  final List<CheckboxOption<T>> options;

  /// If false, the field will be displayed as disabled.
  final bool? enabled;

  /// Creates a [CheckboxSuperFormField] that delegates its build to a [builder]
  /// while providing helpful [CheckboxState] abstraction.
  ///
  /// You can check [listTileCheckboxBuilder] as an example implementation used in
  /// [CheckboxSuperFormField.listTile].
  CheckboxSuperFormField({
    Key? key,
    required CheckboxBuilder<T> builder,
    required String name,
    required this.options,
    List<SuperFormFieldRule>? rules,
    void Function(T value, bool checked)? onChanged,
    this.enabled,
  }) : super(
          key: key,
          name: name,
          rules: rules ?? [],
          builder: (context, fieldState, formState) {
            final Set<T> currentValue =
                _correctValue<T>(fieldState.data?.value);

            void effectiveOnChanged(T value, bool checked) {
              final Set<T> newValue = Set.of(currentValue);

              if (checked) {
                newValue.add(value);
              } else {
                newValue.remove(value);
              }

              SuperFormFieldData newData = fieldState.data!.copyWithValue(
                value: newValue,
                touched: true,
              );

              // If the field was tried to be submitted it should be now revalidated every change
              if (formState.validationMode == ValidationMode.onChange ||
                  newData.submitted) {
                newData = newData.validate(rules ?? []);
              }

              formState.updateFieldData(newData);

              if (onChanged != null) {
                onChanged(value, checked);
              }
            }

            final effectiveEnabled = enabled ?? formState.enabled;

            return builder(
              context,
              CheckboxState<T>(
                options,
                currentValue,
                effectiveEnabled ? effectiveOnChanged : null,
                fieldState.focusNode,
              ),
            );
          },
        );

  /// Creates a [Column] of connected [CheckboxListTile]s which represent the
  /// options.
  ///
  /// Check [CheckboxListTile] documentation for arguments documentation.
  ///
  /// Diffences between CheckboxListTile and this builder are:
  /// * No tristate available
  /// * [subtitle] is a function so developers can customize it per option
  /// * [selected] is a function so developers can customize it per option
  CheckboxSuperFormField.listTile({
    Key? key,
    required String name,
    required this.options,
    List<SuperFormFieldRule>? rules,
    Color? activeColor,
    Color? checkColor,
    Color? tileColor,
    Widget Function(CheckboxOption<T> state)? subtitle,
    bool isThreeLine = false,
    bool? dense,
    Widget? secondary,
    bool Function(CheckboxOption<T> option)? selected,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool autofocus = false,
    EdgeInsetsGeometry? contentPadding,
    ShapeBorder? shape,
    Color? selectedTileColor,
    void Function(T value, bool checked)? onChanged,
    this.enabled,
  }) : super(
          key: key,
          name: name,
          rules: rules ?? [],
          builder: (context, fieldState, formState) {
            final Set<T> currentValue =
                _correctValue<T>(fieldState.data?.value);

            void effectiveOnChanged(T value, bool checked) {
              final Set<T> newValue = Set.of(currentValue);

              if (checked) {
                newValue.add(value);
              } else {
                newValue.remove(value);
              }

              SuperFormFieldData newData = fieldState.data!.copyWithValue(
                value: newValue,
                touched: true,
              );

              // If the field was tried to be submitted it should be now revalidated every change
              if (formState.validationMode == ValidationMode.onChange ||
                  newData.submitted) {
                newData = newData.validate(rules ?? []);
              }

              formState.updateFieldData(newData);

              if (onChanged != null) {
                onChanged(value, checked);
              }
            }

            final effectiveEnabled = enabled ?? formState.enabled;

            return listTileCheckboxBuilder(
              context,
              CheckboxState<T>(
                options,
                currentValue,
                effectiveEnabled ? effectiveOnChanged : null,
                fieldState.focusNode,
              ),
              activeColor: activeColor,
              checkColor: checkColor,
              tileColor: tileColor,
              subtitle: subtitle,
              isThreeLine: isThreeLine,
              dense: dense,
              secondary: secondary,
              selected: selected,
              controlAffinity: controlAffinity,
              autofocus: autofocus,
              contentPadding: contentPadding,
              shape: shape,
              selectedTileColor: selectedTileColor,
            );
          },
        );

  @override
  _CheckboxSuperFormFieldState<T> createState() =>
      _CheckboxSuperFormFieldState<T>();
}

class _CheckboxSuperFormFieldState<T> extends SuperFormFieldState {
  @override
  CheckboxSuperFormField get widget => super.widget as CheckboxSuperFormField;

  @override
  void didUpdateWidget(covariant CheckboxSuperFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Clearing values that no longer have corresponding option
    if (!listEquals(oldWidget.options, widget.options) && data != null) {
      final Set<T> currentValues = _correctValue<T>(data!.value);
      final Set<T> newValues = {};

      for (final value in currentValues) {
        if (widget.options.any((element) => element.value == value)) {
          newValues.add(value);
        }
      }

      if (newValues.length != currentValues.length) {
        setValue(newValues);
      }
    }
  }
}
