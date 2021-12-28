import 'package:flutter/material.dart';
import '../../super_form.dart';

/// Regular material [Slider] that extends [SuperFormField]
///
/// This widget's state automatically registers field for [name] so there is
/// no need for manual registration.
///
/// Specify [rules] to add validation for this field. Errors will not be displayed
/// automatically. Consider putting [SuperFormErrorText] below the slider.
///
/// Most fields are kept the same as in [Slider] so see there for documentation of
/// specific properties.
///
/// ```dart
/// SliderSuperFormField(
///   name: "power",
///   rules: [MaxValueRule(limit, "Cannot exceed the user limit")],
/// ),
/// ```
///
/// See also:
///
///  * [Slider], which is non-connected version of this widget
class SliderSuperFormField extends SuperFormField {
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value the user can select.
  ///
  /// Defaults to 0.0. Must be less than or equal to [max].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double min;

  /// The maximum value the user can select.
  ///
  /// Defaults to 1.0. Must be greater than or equal to [min].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double max;

  /// The number of discrete divisions.
  ///
  /// Typically used with [label] to show the current discrete value.
  ///
  /// If null, the slider is continuous.
  final int? divisions;

  /// A label to show above the slider when the slider is active.
  ///
  /// It is used to display the value of a discrete slider, and it is displayed
  /// as part of the value indicator shape.
  ///
  /// The label is rendered using the active [ThemeData]'s [TextTheme.bodyText1]
  /// text style, with the theme data's [ColorScheme.onPrimary] color. The
  /// label's text style can be overridden with
  /// [SliderThemeData.valueIndicatorTextStyle].
  ///
  /// If null, then the value indicator will not be displayed.
  ///
  /// Ignored if this slider is created with [Slider.adaptive].
  ///
  /// See also:
  ///
  ///  * [SliderComponentShape] for how to create a custom value indicator
  ///    shape.
  final String? label;

  /// The color to use for the portion of the slider track that is active.
  ///
  /// The "active" side of the slider is the side between the thumb and the
  /// minimum value.
  ///
  /// Defaults to [SliderThemeData.activeTrackColor] of the current
  /// [SliderTheme].
  ///
  /// Using a [SliderTheme] gives much more fine-grained control over the
  /// appearance of various components of the slider.
  final Color? activeColor;

  /// The color for the inactive portion of the slider track.
  ///
  /// The "inactive" side of the slider is the side between the thumb and the
  /// maximum value.
  ///
  /// Defaults to the [SliderThemeData.inactiveTrackColor] of the current
  /// [SliderTheme].
  ///
  /// Using a [SliderTheme] gives much more fine-grained control over the
  /// appearance of various components of the slider.
  ///
  /// Ignored if this slider is created with [Slider.adaptive].
  final Color? inactiveColor;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// The callback used to create a semantic value from a slider value.
  ///
  /// Defaults to formatting values as a percentage.
  ///
  /// This is used by accessibility frameworks like TalkBack on Android to
  /// inform users what the currently selected value is with more context.
  ///
  /// {@tool snippet}
  ///
  /// In the example below, a slider for currency values is configured to
  /// announce a value with a currency label.
  ///
  /// ```dart
  /// Slider(
  ///   value: _dollars.toDouble(),
  ///   min: 20.0,
  ///   max: 330.0,
  ///   label: '$_dollars dollars',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _dollars = newValue.round();
  ///     });
  ///   },
  ///   semanticFormatterCallback: (double newValue) {
  ///     return '${newValue.round()} dollars';
  ///   }
  ///  )
  /// ```
  /// {@end-tool}
  ///
  /// Ignored if this slider is created with [Slider.adaptive]
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// If false the slider will be displayed as disabled.
  final bool? enabled;

  SliderSuperFormField({
    Key? key,
    required String name,
    List<SuperFormFieldRule>? rules,
    FocusNode? focusNode,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.autofocus = false,
    this.enabled,
  }) : super(
          key: key,
          name: name,
          rules: rules ?? const [],
          focusNode: focusNode,
          builder: (
            BuildContext context,
            fieldState,
            formState,
          ) {
            final fieldData = formState.data[name]!;

            final effectiveEnabled = enabled ?? formState.enabled;

            void effectiveOnChange(double newValue) {
              SuperFormFieldData newData = fieldData.copyWithValue(
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
                onChanged(newValue);
              }
            }

            return Slider(
              value: (fieldData.value as double?) ?? min,
              onChanged: effectiveEnabled ? effectiveOnChange : null,
              onChangeStart: onChangeStart,
              onChangeEnd: onChangeEnd,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              mouseCursor: mouseCursor,
              semanticFormatterCallback: semanticFormatterCallback,
              focusNode: fieldState.focusNode,
              autofocus: autofocus,
            );
          },
        );
}
