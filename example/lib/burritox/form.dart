import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_form/super_form.dart';

import 'model.dart';

/// Form for adding and editing burrito orders
class BurritoForm extends StatelessWidget {
  final void Function(BurritoOrder order) onSubmit;
  final GlobalKey<SuperFormState> formKey;
  final bool isEditing;
  final Map<String, dynamic> initialValues;

  const BurritoForm({
    Key? key,
    required this.onSubmit,
    required this.formKey,
    this.isEditing = false,
    this.initialValues = const {"count": "1", "filling": "beef"},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SuperForm(
      key: formKey,
      onSubmit: (values) {
        onSubmit(BurritoOrder(
          burrito: Burrito(
            filling: values["filling"] as String,
            sauce: (values["sauce"] as List<String>).toSet(),
            extras: (values["extras"] as List<String>? ?? <String>[]).toSet(),
          ),
          count: int.parse(values["count"] as String),
        ));

        if (!isEditing) {
          // Clear form after submit if it's not editing.
          // We actually can reset when it's editing, but we don't do it to
          // prevent values flickering
          formKey.currentState?.reset();
        }
      },
      initialValues: initialValues,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownSuperFormField(
            name: "filling",
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "beef", child: Text("Beef")),
              DropdownMenuItem(value: "pork", child: Text("Pork")),
              DropdownMenuItem(value: "chicken", child: Text("Chicken")),
              DropdownMenuItem(
                  value: "seitan", child: Text("Seitan (vegan 🌱)")),
            ],
            rules: [RequiredRule("Choose your main ingredient")],
          ),
          const SuperFormErrorText(name: "filling"),
          const SizedBox(height: 16),
          const Text("Sauces (maximum 2):"),
          const SizedBox(height: 8),
          CheckboxSuperFormField.listTile(
            name: "sauce",
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.only(left: 4),
            dense: true,
            rules: [
              RequiredRule("Choose your sauces"),
              MinimumLengthRule(1, "Choose your sauces"),
              MaximumLengthRule(2, "You can't choose more sauces")
            ],
            options: const [
              CheckboxOption("salsa_mango", Text("Salsa mango")),
              CheckboxOption("salsa_chili", Text("Salsa chili")),
              CheckboxOption("guacamole", Text("Guacamole")),
              CheckboxOption("mayo", Text("Mayo")),
            ],
          ),
          const SuperFormErrorText(name: "sauce"),
          const SizedBox(height: 8),
          const Text("Extras:"),
          const SizedBox(height: 8),
          CheckboxSuperFormField.listTile(
            name: "extras",
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.only(left: 4),
            dense: true,
            options: const [
              CheckboxOption("fries", Text("Fries (+1\$)")),
              CheckboxOption(
                  "sweet_potato_fries", Text("Sweet potato fries (+2\$)")),
              CheckboxOption("coleslaw", Text("Coleslaw (+1\$)")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const ChangeCountButton(increment: false),
              SizedBox(
                width: 45,
                child: TextSuperFormField(
                  // key: const Key('count'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  name: "count",
                  keyboardType: TextInputType.number,
                  rules: [
                    IsIntegerRule("Must be a number"),
                    // You can use rules dynamically!
                    if (!isEditing) MinValueRule(1, "Must be at least one"),
                    if (isEditing) MinValueRule(0, "Must not be negative"),
                  ],
                ),
              ),
              const ChangeCountButton(increment: true),
              const SizedBox(width: 20),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    key: const Key('submit'),
                    onPressed: () {
                      formKey.currentState?.submit();
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    )),
                    label: isEditing ? const Text("Save") : const Text("Add"),
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ChangeCountButton extends StatelessWidget {
  final bool increment;

  const ChangeCountButton({Key? key, required this.increment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int value =
        int.tryParse(SuperForm.ofFieldValue<String>(context, "count") ?? "") ??
            1;

    return IconButton(
      key: Key(increment ? 'plus' : 'minus'),
      onPressed: () {
        final newValue = increment ? value + 1 : value - 1;

        SuperForm.of(context, listen: false)
            .setValue("count", newValue.toString());
      },
      icon: Icon(increment ? Icons.add : Icons.remove),
    );
  }
}
