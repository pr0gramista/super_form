import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_form/super_form.dart';

/// A pair of value and optional label for a single radio.
///
/// Label is optional since some people may want to implement more complex
/// radios and having single widget is quite limiting. [value] or extending
/// class propeperties should be used to provide more information.
class RadioOption<T> {
  final T value;
  final Widget? label;

  const RadioOption(this.value, this.label);
}

/// Builder for [RadioSuperFormField] which builds a [Column] with
/// [RadioListTile] for each [RadioOption].
Widget listTileRadioBuilder<T>(
  BuildContext context,
  RadioState<T> state, {
  bool toggleable = false,
  Color? activeColor,
  Widget Function(RadioOption<T> option)? subtitle,
  bool isThreeLine = false,
  bool? dense,
  Widget? secondary,
  bool Function(RadioOption<T> option)? selected,
  ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
  bool autofocus = false,
  EdgeInsetsGeometry? contentPadding,
  ShapeBorder? shape,
  Color? tileColor,
  Color? selectedTileColor,
}) {
  return Focus(
    focusNode: state.focusNode,
    skipTraversal: true,
    child: Column(
      children: state.options.map((option) {
        return RadioListTile(
          groupValue: state.groupValue,
          onChanged: (T? value) {
            state.onChanged(value);
          },
          value: option.value,
          title: option.label,
          toggleable: toggleable,
          activeColor: activeColor,
          subtitle: subtitle != null ? subtitle(option) : null,
          // ignore: avoid_bool_literals_in_conditional_expressions
          selected: selected != null ? selected(option) : false,
          isThreeLine: isThreeLine,
          dense: dense,
          secondary: secondary,
          controlAffinity: controlAffinity,
          autofocus: autofocus,
          contentPadding: contentPadding,
          shape: shape,
          tileColor: tileColor,
          selectedTileColor: selectedTileColor,
        );
      }).toList(),
    ),
  );
}

/// Encapsulates radio field state into a single object.
class RadioState<T> {
  final List<RadioOption<T>> options;
  final T? groupValue;
  final void Function(T? value) onChanged;
  final FocusNode focusNode;

  const RadioState(
    this.options,
    this.groupValue,
    this.onChanged,
    this.focusNode,
  );
}

typedef RadioBuilder<T> = Widget Function(
  BuildContext context,
  RadioState<T> state,
);

/// Base class for creating radio groups that extends [SuperFormField].
///
/// This widget's state automatically registers field for [name] so there is
/// no need for manual registration.
///
/// Specify [rules] to add validation for this field. Errors will not be displayed
/// automatically. Consider putting [SuperFormErrorText] below the field.
///
/// The field will automatically clear group value it no longer have corresponding
/// option.
///
/// ```dart
/// RadioSuperFormField.listTile(
///   name: "size",
///   options: const [
///     RadioOption("s", Text("Small")),
///     RadioOption("m", Text("Medium")),
///     RadioOption("l", Text("Large")),
///     RadioOption("xl", Text("X-Large")),
///   ],
///   rules: [RequiredRule("Please choose size")],
///   dense: true,
/// ),
/// ```
///
/// See also:
///
///  * [CheckboxSuperFormField], which is checkbox version of this widget
class RadioSuperFormField<T> extends SuperFormField {
  /// List of available options
  final List<RadioOption<T>> options;

  /// Creates a [RadioSuperFormField] that delegates its build to a [builder]
  /// while providing helpful [RadioState] abstraction.
  ///
  /// You can check [listTileRadioBuilder] as an example implementation used in
  /// [RadioSuperFormField.listTile].
  RadioSuperFormField({
    Key? key,
    required RadioBuilder<T> builder,
    required String name,
    required this.options,
    List<SuperFormFieldRule>? rules,
    void Function(T? value)? onChanged,
  }) : super(
          key: key,
          name: name,
          rules: rules ?? [],
          builder: (context, fieldState, formState) {
            final T? currentGroupValue = fieldState.data?.value as T?;

            void effectiveOnChanged(T? value) {
              SuperFormFieldData newData = fieldState.data!.copyWithValue(
                value: value,
                touched: true,
              );

              // If the field was tried to be submitted it should be now revalidated every change
              if (formState.validationMode == ValidationMode.onChange ||
                  newData.submitted) {
                newData = newData.validate();
              }

              formState.updateFieldData(newData);

              if (onChanged != null) {
                onChanged(value);
              }
            }

            return builder(
              context,
              RadioState<T>(
                options,
                currentGroupValue,
                effectiveOnChanged,
                fieldState.focusNode,
              ),
            );
          },
        );

  /// Creates a [Column] of connected [RadioListTile]s which represent the
  /// options.
  ///
  /// Check [RadioListTile] documentation for arguments documentation.
  ///
  /// Diffences between RadioListTile and this builder are:
  /// * [subtitle] is a function so developers can customize it per option
  /// * [selected] is a function so developers can customize it per option
  RadioSuperFormField.listTile({
    Key? key,
    required String name,
    required this.options,
    List<SuperFormFieldRule>? rules,
    bool toggleable = false,
    Color? activeColor,
    Widget Function(RadioOption<T> option)? subtitle,
    bool isThreeLine = false,
    bool? dense,
    Widget? secondary,
    bool Function(RadioOption<T> option)? selected,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool autofocus = false,
    EdgeInsetsGeometry? contentPadding,
    ShapeBorder? shape,
    Color? tileColor,
    Color? selectedTileColor,
    void Function(T? value)? onChanged,
  }) : super(
          key: key,
          name: name,
          rules: rules ?? [],
          builder: (context, fieldState, formState) {
            final T? currentGroupValue = fieldState.data?.value as T?;

            void effectiveOnChanged(T? value) {
              SuperFormFieldData newData = fieldState.data!.copyWithValue(
                value: value,
                touched: true,
              );

              // If the field was tried to be submitted it should be now revalidated every change
              if (formState.validationMode == ValidationMode.onChange ||
                  newData.submitted) {
                newData = newData.validate();
              }

              formState.updateFieldData(newData);

              if (onChanged != null) {
                onChanged(value);
              }
            }

            return listTileRadioBuilder(
              context,
              RadioState<T>(
                options,
                currentGroupValue,
                effectiveOnChanged,
                fieldState.focusNode,
              ),
              toggleable: toggleable,
              activeColor: activeColor,
              subtitle: subtitle,
              isThreeLine: isThreeLine,
              dense: dense,
              secondary: secondary,
              selected: selected,
              controlAffinity: controlAffinity,
              autofocus: autofocus,
              contentPadding: contentPadding,
              shape: shape,
              tileColor: tileColor,
              selectedTileColor: selectedTileColor,
            );
          },
        );

  @override
  _RadioSuperFormFieldState<T> createState() => _RadioSuperFormFieldState<T>();
}

class _RadioSuperFormFieldState<T> extends SuperFormFieldState {
  @override
  RadioSuperFormField get widget => super.widget as RadioSuperFormField;

  @override
  void didUpdateWidget(covariant RadioSuperFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Clearing groupValue if that no longer have corresponding option
    if (!listEquals(oldWidget.options, widget.options)) {
      final currentGroupValue = data!.value as T?;

      final contains =
          widget.options.any((element) => element.value == currentGroupValue);

      if (!contains) {
        setValue(null);
      }
    }
  }
}
