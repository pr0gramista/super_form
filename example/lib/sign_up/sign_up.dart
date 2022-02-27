import 'package:flutter/material.dart';
import 'package:password_strength/password_strength.dart';
import 'package:super_form/super_form.dart';
import 'package:super_form_example/github_link.dart';
import 'package:super_form_example/result_dialog.dart';

/// Entrypoint for Sign Up demo
///
/// Shows how to compose validation rules to achieve gradual and instant, thanks
/// to [ValidationMode.onChange], form errors.
class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SuperForm(
        restorationId: "signup",
        validationMode: ValidationMode.onChange,
        onSubmit: (values) {
          showDialog(
            context: context,
            builder: (context) => ResultDialog(
              title: const Text("Form values"),
              result: values.toString(),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
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
                      SubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
            const GitHubLink(path: "/sign_up"),
          ],
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
      key: const Key('email'),
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
      key: const Key('password'),
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
          final double strength =
              estimatePasswordStrength(password as String? ?? "");

          if (strength < 0.3) return 'This password is too weak!';

          return null;
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
      key: const Key('password2'),
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
          final password = SuperForm.ofFieldValue(context, "password");
          final arePasswordsEqual = password == password2;

          if (!arePasswordsEqual) return "Passwords must match";

          return null;
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
  const TermsAndConditionsCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CheckboxSuperFormField.listTile(
        key: const Key('tc'),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.only(left: 4),
        name: "termsAndConditionsAccepted",
        rules: [
          ContainsRule(
              "yes", "You must accept our Terms & Condition to continue")
        ],
        options: [
          CheckboxOption(
            "yes",
            RichText(
              text: TextSpan(
                text: 'I accept ',
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                  const TextSpan(text: ' which I did not read.'),
                ],
              ),
            ),
          )
        ],
      ),
      const SuperFormErrorText(name: "termsAndConditionsAccepted"),
    ]);
  }
}
