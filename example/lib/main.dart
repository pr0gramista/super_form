import 'package:flutter/material.dart';
import 'package:password_strength/password_strength.dart';
import 'package:super_form/super_form.dart';

void main() {
  runApp(MyBeautifulApp());
}

class MyBeautifulApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Super Form Demo', home: LoginPage());
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SuperForm(
        validationMode: ValidationMode.onBlur,
        onSubmit: (values) {
          // ignore: avoid_print
          print(values.toString());

          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const RegistrationFinishedPage()));
        },
        onInit: (form) {
          form.register(name: "termsAndConditionsAccepted", rules: [
            IsEqualRule(true, "You must accept our terms and conditions")
          ]);
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 500,
            child: Column(
              children: const [
                EmailField(),
                SizedBox(height: 8),
                PasswordField(),
                SizedBox(height: 8),
                RepeatPasswordField(),
                SizedBox(height: 8),
                TermsAndConditionsCheckbox(),
                SizedBox(height: 8),
                SubmitButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextSuperFormField(
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.mail),
      ),
      name: "email",
      rules: [
        RequiredRule("Must not be empty"),
        EmailRule("Must be a valid email")
      ],
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextSuperFormField(
      decoration: const InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      name: "password",
      rules: [
        RequiredRule("Must not be empty"),
        MinimumLengthRule(
          6,
          "Must be at least 6 characters",
        ),
        CustomRule((password) {
          final double strength = estimatePasswordStrength(password as String);

          if (strength < 0.3) return 'This password is too weak!';
        }),
      ],
    );
  }
}

class RepeatPasswordField extends StatelessWidget {
  const RepeatPasswordField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextSuperFormField(
      decoration: const InputDecoration(
        labelText: "Repeat password",
        prefixIcon: Icon(Icons.lock),
      ),
      name: "password2",
      obscureText: true,
      rules: [
        RequiredRule("Must not be empty"),
        MinimumLengthRule(6, "Must be at least 6 characters"),
        CustomRule((password2) {
          final password = SuperForm.ofMaybe(context, listen: false)
              ?.data["password"]
              ?.value;
          final arePasswordsEqual = password == password2;

          if (!arePasswordsEqual) return "Passwords must match";
        })
      ],
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 32,
          ),
        ),
      ),
      onPressed: () => SuperForm.of(context, listen: false).submit(),
      child: const Text("Create account"),
    );
  }
}

class TermsAndConditionsCheckbox extends StatelessWidget {
  static const name = "termsAndConditionsAccepted";

  const TermsAndConditionsCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formState = SuperForm.ofFieldMaybe(context, name);
    final fieldData = formState?.data[name];

    final bool checked = fieldData?.value as bool? ?? false;

    void changeValue() {
      formState?.setValue(name, !checked);
      if (fieldData?.submitted ?? false) {
        formState?.validate(name);
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: changeValue,
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: (_) => changeValue(),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'I accept ',
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Terms & Conditions',
                          style:
                              TextStyle(color: Theme.of(context).accentColor)),
                      const TextSpan(text: ' which I did not read.'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SuperFormErrorText(name: name)
      ],
    );
  }
}

class RegistrationFinishedPage extends StatelessWidget {
  const RegistrationFinishedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Container(
            width: 500,
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: const [
                Icon(Icons.mail_outline_outlined, size: 40),
                Text(
                  "Great! You've successfully signed up for Our Beautiful App",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                    "We have sent a link to confirm your email address. Please check your inbox. It can take up to 10 minutes to show up in your inbox."),
              ],
            ),
          ),
        ));
  }
}
