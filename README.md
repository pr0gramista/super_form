# Super Form
[![pub package](https://img.shields.io/pub/v/super_form.svg)](https://pub.dartlang.org/packages/charset_converter)
[![Tests status](https://github.com/pr0gramista/super_form/workflows/Tests/badge.svg)](https://github.com/pr0gramista/super_form/actions)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
[![codecov](https://codecov.io/gh/pr0gramista/super_form/branch/main/graph/badge.svg)](https://codecov.io/gh/pr0gramista/super_form)

Forms in Flutter without hassle 💪

Managing form state with standard Flutter forms can be extremely tedious. Super Form manages form values, errors and additional properties like whether an input was touched without complicated logic. Super Form also provides a set of ready to use form widgets, but don't worry it is also extremely simple to implement your own.

### Does it use state management?
Super Form follows the idea of form state being inherently ephemeral and local, so tracking it in Redux or Bloc is unnecessary. Super Form is also faster since changing one field doesn't trigger an update to all fields. While this behavior can be achieved with Redux/Bloc it is not done by default.

Having said that it is possible to save the values to anything you want.

## Usage
1. Create SuperForm widget at the top of your form the as you would do with Form. You may want to add a GlobalKey, but that's not required.
```dart
SuperForm(
  validationMode: ValidationMode.onBlur,
  onSubmit: (values) {
    // Do your thing
    print(values.toString());
  },
  child: Column(...)
)
```
2. Create fields
```dart
TextSuperFormField(
  decoration: InputDecoration(labelText: "Email"),
  name: "email",
  rules: [Required("Must not be empty")],
),
```
3. Add a button or whatever you want to submit the form
```dart
OutlinedButton(
  onPressed: () => SuperForm.of(context, listen: false).submit(),
  child: Text("Sign in"),
),
```

Note that you may want to wrap the child (like example of submit button) of the SuperForm in [Builder](https://api.flutter.dev/flutter/widgets/Builder-class.html) to be able to get SuperForm instance in the same widget.

## Validation
SuperForm comes with a set of validation rules. These are relatively simple synchronous validators. Each validator takes error message as an parameter which will be automatically displayed when the value won't pass the validation. This means you can compose these rules and show super helpful error messages.

Note that the order of the rules matters. Validation takes place from the beginning of the list.

```dart
TextSuperFormField(
  decoration: InputDecoration(labelText: "Password"),
  name: "password",
  rules: [
    RequiredRule("Must not be empty"),
    MinimumLengthRule(
      6,
      "Must be at least 6 characters",
    ),
    CustomRule((value) {
      double strength = estimatePasswordStrength(value);

      if (strength < 0.3) return "Password is too weak";
    })
  ],
),
```
To create your own rules you can either extend `SuperFormFieldRule`, existing rule or use CustomRule, which takes a function as its parameter.

## Validation modes
Validation is always run when the form is submitted, after that invalid fields will re-validate on change. However you can customize the initial behavior by passing `validationMode` to `SuperForm` widget.

- `onSubmit` (default) - validation will trigger only on submit
- `onBlur` - validation will also trigger when field loses focus
- `onChange` - validation will trigger when the field value is changed

## Virtual fields
There are cases where you want to have field in the form, but have no actual controls for it. Super form can do it! You just need to register the field. You can do it easily in `onInit` callback of the SuperForm widget.
```dart
SuperForm(
  onInit: (form) {
    form.register(
      name: "termsAndConditionsAccepted",
      rules: [IsEqualRule(true, 'You need to accept terms and conditions')],
    );
  },
  // ...
)
```
After you register a field you can trigger all standard operations like setting value, marking it as touched or triggering a validation. Submitting the form will also validate this field.

## Interacting programmatically 
SuperForm makes it super easy to interact, like setting a value, programmatically. Just retrieve SuperForm instance from context and you can do magic. Just remember that the field must be registered.

A perfect example is where you want to use `showDatePicker` as a way to collect form data: 
```dart
showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime.now(),
  lastDate: DateTime.utc(2040),
).then((value) {
  SuperForm.of(context, listen: false).setValue("to", value);
});
```

## Why use `dynamic`?
While it comes with many implications it allows to put everything into one place. Having tried to do that using generics resulted in putting lots of stupid mapping functions or additional classes. Code generation could solve that, but then I would name this package SuperChonkyForm. In the end, when static metaprogramming shows up I'll probably create SuperForm v2 which would preserve types.

## Contributing
Feel free to create issues, fix bugs, add new functionalities even if you are not sure about. Everyone is welcome!