import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:vagoflax/views/admin_screen.dart';
import 'package:vagoflax/views/job_list_screen.dart';
import 'package:vagoflax/views/loading_screen.dart';
import 'package:vagoflax/views/signup_2_type_screen.dart';
import 'package:vagoflax/views/welcome_screen.dart';
import 'package:vagoflax/views/job_provider_offer_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<ApplicationState>().loggedIn;
    final userRole = context.watch<ApplicationState>().userRole;
    final isAccountLoading = context.watch<ApplicationState>().accountLoading;

    if (isAccountLoading) {
      return const LoadingScreen();
    }

    if (loggedIn) {
      if (userRole == "student") {
        return const JobListScreen();
      } else if (userRole == "employer") {
        return const JobProviderOfferScreen();
      } else if (userRole == "admin") {
        return const AdminScreen();
      } else if (userRole == '') {
        return const SignUpTypeScreen();
      } else {
        return const WelcomeScreen();
      }
    } else {
      return const WelcomeScreen();
    }
  }
}
