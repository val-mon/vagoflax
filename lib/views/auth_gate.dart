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
    final isLoggedIn = context.watch<ApplicationState>().loggedIn;
    final role = "employer";

    if (isLoggedIn) {
      if (role == "student") {
        return const JobListScreen();
      } else if (role == "employer") {
        return const JobProviderOfferScreen();
      } else {
        return const WelcomeScreen();
      }
    } else {
      return const WelcomeScreen();
    }
  }
}
