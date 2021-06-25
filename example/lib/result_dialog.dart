import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final Text title;
  final String result;

  const ResultDialog({Key? key, required this.result, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          title,
          const SizedBox(height: 16),
          SelectableText(
            result,
          ),
        ]),
      ),
    );
  }
}
