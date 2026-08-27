import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vagoflax/widgets/app_icon.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About us'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),

            const AppIcon(),

            const SizedBox(height: 48),

            const Text(
              'Vagoflax is a platform that connects students and companies to offer job opportunities for students who are finishing their cursus.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            const Text(
              "We are a team of students from the HES-SO Valais-Wallis, and we created this platform as part of our Summer School 2 project.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),
            // clickable GitHub link
            const Text(
              "This is an open-source project whose code you can see on GitHub:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                try {
                  launchUrl(Uri.parse('https://github.com/val-mon/vagoflax'));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error occurred while launching URL: $e"),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              },
              child: const Text(
                "https://github.com/val-mon/vagoflax",
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
