import 'package:flutter/material.dart';

import '../../super_form.dart';

/// Regular material [DropdownButton] wrapped in [InputDecorator] that extends
/// [SuperFormField]
///
/// This widget's state automatically registers field
/// for [name] so there is no need for manual registration.
///
/// Specify [rules] to add validation for this field. Errors will be displayed
/// automatically as errorText of [InputDecoration]. Overriding this property will
/// hide errors from validation.
///
/// If [enabled] is set to false, the field will be displayed as disabled.
/// If non-null this property overrides the [decoration]'s
/// [InputDecoration.enabled] property.
///
/// Most fields are kept the same as in [DropdownButton] so see there for documentation
/// of specific properties.
///
/// ```dart
/// DropdownSuperFormField(
///   name: "employment_status",
///   items: const [
///     DropdownMenuItem(value: "employed", child: Text("Employed")),
///     DropdownMenuItem(value: "self-employed", child: Text("Self-employed")),
///     DropdownMenuItem(value: "student", child: Text("Student")),
///     DropdownMenuItem(value: "unemployed", child: Text("Unemployed")),
///     DropdownMenuItem(value: "retired", child: Text("Retired")),
///   ],
///   rules: [RequiredRule("Cannot be empty")],
/// )
/// ```
///
/// See also:
///
///  * [DropdownButton], which is non-connected version of this widget
///  * [DropdownButtonField], which is Flutter form version of this widget
class DropdownSuperFormField<T> extends SuperFormField {
  DropdownSuperFormField({
    Key? key,
    required String name,
    List<SuperFormFieldRule>? rules,
    required List<DropdownMenuItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    double? menuMaxHeight,
    ValueChanged<T?>? onChanged,
    bool? enabled,
  }) : super(
          key: key,
          name: name,
          focusNode: focusNode,
          rules: rules ?? const [],
          builder: (context, fieldState, formState) {
            final fieldData = formState.data[name];

            InputDecoration? effectiveDecoration =
                (decoration ?? InputDecoration(focusColor: focusColor))
                    .applyDefaults(
                        Theme.of(fieldState.context).inputDecorationTheme);
            if (fieldData != null && fieldData.errors.isNotEmpty) {
              effectiveDecoration = effectiveDecoration.copyWith(
                  errorText: fieldData.errors.first.message);
            }

            final effectiveEnabled = enabled ?? formState.enabled;

            return Focus(
              canRequestFocus: false,
              skipTraversal: true,
              child: Builder(builder: (BuildContext context) {
                return InputDecorator(
                  decoration: effectiveDecoration!,
                  isEmpty: fieldData?.value == null,
                  isFocused: Focus.of(context).hasFocus,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      items: items,
                      selectedItemBuilder: selectedItemBuilder,
                      value: fieldData?.value as T?,
                      hint: hint,
                      disabledHint: disabledHint,
                      onChanged: effectiveEnabled
                          ? (newValue) {
                              SuperFormFieldData newData =
                                  fieldData!.copyWithValue(
                                value: newValue,
                                touched: true,
                              );

                              if (formState.validationMode ==
                                      ValidationMode.onChange ||
                                  newData.submitted) {
                                newData = newData.validate();
                              }

                              formState.updateFieldData(newData);

                              if (onChanged != null) onChanged(newValue);
                            }
                          : null,
                      onTap: onTap,
                      elevation: elevation,
                      style: style,
                      icon: icon,
                      iconDisabledColor: iconDisabledColor,
                      iconEnabledColor: iconEnabledColor,
                      iconSize: iconSize,
                      isDense: isDense,
                      isExpanded: isExpanded,
                      itemHeight: itemHeight,
                      focusColor: focusColor,
                      focusNode: fieldState.focusNode,
                      autofocus: autofocus,
                      dropdownColor: dropdownColor,
                      menuMaxHeight: menuMaxHeight,
                    ),
                  ),
                );
              }),
            );
          },
        );
}
