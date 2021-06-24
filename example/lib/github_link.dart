import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const repositoryExampleTreeUrl =
    "https://github.com/pr0gramista/super_form/tree/master/example/lib";

class GitHubLink extends StatelessWidget {
  final String path;

  const GitHubLink({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launch(repositoryExampleTreeUrl + path);
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: const Text(
          "See the code at GitHub",
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
