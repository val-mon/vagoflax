import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:vagoflax/views/job_list_screen.dart';
import 'package:vagoflax/views/welcome_screen.dart';
import 'package:vagoflax/views/job_provider_offer_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // watch the loggedIn state from ApplicationState provider
    final appState = context.watch<ApplicationState>();

    if (appState.loggedIn) {
      if (appState.userRole == "student") {
        return const JobListScreen();
      } else if (appState.userRole == "employer") {
        return const JobProviderOfferScreen();
      } else {
        return const WelcomeScreen();
      }
    } else {
      return const WelcomeScreen();
    }
  }
}
