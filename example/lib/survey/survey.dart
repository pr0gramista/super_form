import 'package:flutter/material.dart';
import 'package:super_form/super_form.dart';
import 'package:super_form_example/github_link.dart';
import 'package:super_form_example/result_dialog.dart';

/// Entrypoint for Satisfaction Survey demo
///
/// Shows sliders and ability to dynamically change form fields - email field in
/// this case.
class SurveyPage extends StatelessWidget {
  const SurveyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SuperForm(
        onSubmit: (values) {
          showDialog(
            context: context,
            builder: (context) => ResultDialog(
              title: const Text("Form values"),
              result: values.toString(),
            ),
          );
        },
        initialValues: const {"experience_score": 3.0, "delivery_score": 3.0},
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text("Satisfaction Survey",
                            style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 32),
                        const SatisfactionSlider(
                          name: "experience_score",
                          question:
                              "How would you describe overall experience?",
                        ),
                        const SizedBox(height: 16),
                        const SatisfactionSlider(
                          name: "delivery_score",
                          question: "How would you describe delivery time?",
                        ),
                        const SizedBox(height: 16),
                        CheckboxSuperFormField.listTile(
                          name: "showEmail",
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          options: const [
                            CheckboxOption(
                              "yes",
                              Text(
                                  "I want to receive emails with special offers and discounts, but no spam."),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        OffersEmailField(),
                        const SizedBox(height: 8),
                        const SendButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const GitHubLink(path: "/survey")
          ],
        ),
      ),
    );
  }
}

class SatisfactionSlider extends StatelessWidget {
  final String question;
  final String name;

  const SatisfactionSlider({
    Key? key,
    required this.name,
    required this.question,
  }) : super(key: key);

  String _scoreLabel(int score) {
    switch (score) {
      case 1:
        return "Bad";
      case 2:
        return "Could be better";
      case 3:
        return "Ok";
      case 4:
        return "Good";
      case 5:
        return "Excellent";
      default:
        return "Don't know";
    }
  }

  @override
  Widget build(BuildContext context) {
    final int score =
        (SuperForm.ofFieldValue<double>(context, name) ?? 3.0).floor();

    return Column(
      children: [
        Text(question, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(_scoreLabel(score), style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(children: [
          const Text("😕", style: TextStyle(fontSize: 36)),
          Expanded(
            child: SliderSuperFormField(
              key: Key(name),
              name: name,
              min: 1,
              max: 5,
              divisions: 4,
            ),
          ),
          const Text("🙂", style: TextStyle(fontSize: 36)),
        ])
      ],
    );
  }
}

/// Required Email field that is shown only when checkbox is checked
class OffersEmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final showField =
        (SuperForm.ofFieldValue<List>(context, "showEmail") ?? []).isNotEmpty;

    if (!showField) {
      return const SizedBox();
    }

    return TextSuperFormField(
      key: const Key('email'),
      decoration: const InputDecoration(
        hintText: "Your email address",
        border: OutlineInputBorder(),
      ),
      name: "email",
      rules: [
        RequiredRule("Please provide a valid email address."),
        EmailRule("Please provide a valid email address.")
      ],
    );
  }
}

class SendButton extends StatelessWidget {
  const SendButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 24)),
        padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 48)),
      ),
      onPressed: () {
        SuperForm.of(context, listen: false).submit();
      },
      child: const Text("Send"),
    );
  }
}
