import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../super_form.dart';

/// Regular material [TextField] that extends [SuperFormField]
///
/// This widget's state automatically registers field
/// for [name] so there is no need for manual registration.
///
/// Specify [rules] to add validation for this field. Errors will be displayed
/// automatically as errorText of [InputDecoration]. Overriding this property will
/// hide errors from validation.
///
/// Most fields are kept the same as in [TextField] so see there for documentation
/// of specific properties.
///
/// ```dart
/// TextSuperFormField(
///   decoration: InputDecoration(
///     labelText: "Password",
///     prefixIcon: Icon(Icons.lock),
///   ),
///   obscureText: true,
///   name: "password",
///   rules: [
///     Required("Must not be empty"),
///     MinimumLengthRule(
///       6,
///       "Must be at least 6 characters",
///     ),
///   ],
/// )
/// ```
///
/// See also:
///
///  * [TextField], which is non-connected version of this widget
class TextSuperFormField extends SuperFormField {
  TextSuperFormField({
    Key? key,
    required String name,
    List<SuperFormFieldRule>? rules,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    ScrollController? scrollController,
    Widget? noFormFallback,
    FocusNode? focusNode,
  }) : super(
          key: key,
          name: name,
          rules: rules ?? const [],
          noFormFallback: noFormFallback ?? const SizedBox(),
          focusNode: focusNode,
          builder: (
            BuildContext context,
            fieldState,
            formState,
          ) {
            fieldState as _TextSuperFormFieldState;
            final fieldData = formState.data[name];

            InputDecoration? effectiveDecoration =
                decoration ?? const InputDecoration();
            if (fieldData != null && fieldData.errors.isNotEmpty) {
              effectiveDecoration = effectiveDecoration.copyWith(
                  errorText: fieldData.errors.first.message);
            }

            VoidCallback? effectiveOnEditingComplete = onEditingComplete;
            if (fieldData != null &&
                formState.validationMode == ValidationMode.onBlur) {
              effectiveOnEditingComplete = () {
                if (onEditingComplete != null) {
                  onEditingComplete();
                }

                final validated = fieldData.validate();
                if (validated.errors.isEmpty) {
                  fieldState.focusNode.nextFocus();
                }

                formState.updateFieldData(validated);
              };
            }

            final effectiveEnabled = enabled ?? decoration?.enabled ?? true;

            return TextField(
              controller: fieldState._controller,
              focusNode: fieldState.focusNode,
              decoration: effectiveDecoration,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              textDirection: textDirection,
              textCapitalization: textCapitalization,
              autofocus: autofocus,
              toolbarOptions: toolbarOptions,
              readOnly: readOnly,
              showCursor: showCursor,
              obscuringCharacter: obscuringCharacter,
              obscureText: obscureText,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType ??
                  (obscureText
                      ? SmartDashesType.disabled
                      : SmartDashesType.enabled),
              smartQuotesType: smartQuotesType ??
                  (obscureText
                      ? SmartQuotesType.disabled
                      : SmartQuotesType.enabled),
              enableSuggestions: enableSuggestions,
              maxLengthEnforcement: maxLengthEnforcement,
              maxLines: maxLines,
              minLines: minLines,
              expands: expands,
              maxLength: maxLength,
              onChanged: onChanged,
              onTap: onTap,
              onEditingComplete: effectiveOnEditingComplete,
              onSubmitted: onFieldSubmitted,
              inputFormatters: inputFormatters,
              enabled: effectiveEnabled,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              scrollPadding: scrollPadding,
              scrollPhysics: scrollPhysics,
              keyboardAppearance: keyboardAppearance,
              enableInteractiveSelection: enableInteractiveSelection,
              selectionControls: selectionControls,
              buildCounter: buildCounter,
              autofillHints: autofillHints,
              scrollController: scrollController,
            );
          },
        );

  @override
  _TextSuperFormFieldState createState() => _TextSuperFormFieldState();
}

class _TextSuperFormFieldState extends SuperFormFieldState {
  TextEditingController? _controller;

  @override
  TextSuperFormField get widget => super.widget as TextSuperFormField;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controller?.text != data?.value) {
      _controller?.text = data?.value as String? ?? "";
    }
  }

  @override
  void didUpdateWidget(TextSuperFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_controller?.text != data?.value) {
      _controller?.text = data?.value as String? ?? "";
    }
  }

  @override
  void didReset(SuperFormState formState) {
    super.didReset(formState);

    if (_controller == null) {
      _controller ??= TextEditingController(text: data?.value as String? ?? "");
      _controller?.addListener(onTextChange);
    } else {
      _controller?.text = data?.value as String? ?? "";
    }
  }

  void onTextChange() {
    // Copy so we can promote the type
    final currentFieldData = data;

    if (currentFieldData == null) {
      return;
    }

    if ((currentFieldData.value ?? "") != _controller?.text) {
      SuperFormFieldData newData = currentFieldData.copyWithValue(
          value: _controller?.text, touched: true);

      // If the field was tried to be submitted it should be now revalidated every change
      if (form?.validationMode == ValidationMode.onChange ||
          currentFieldData.submitted) {
        newData = newData.validate();
      }

      SuperForm.ofFieldMaybe(context, currentFieldData.name)
          ?.updateFieldData(newData);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
