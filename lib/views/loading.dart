import 'package:flutter/material.dart';
import 'package:vagoflax/widgets/app_icon.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ou la couleur de fond de ton app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(),

            const SizedBox(height: 32),

            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
