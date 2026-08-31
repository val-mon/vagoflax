import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/providers/auth.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/views/admin.dart';
import 'package:vagoflax/views/student/gate.dart';
import 'package:vagoflax/views/loading.dart';
import 'package:vagoflax/views/auth/signup/2_type.dart';
import 'package:vagoflax/views/auth/welcome.dart';
import 'package:vagoflax/views/employer/job_offer.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<ApplicationState>().loggedIn;
    final user = context.watch<UserProvider>().currentUser;
    final isAccountLoading = context.watch<ApplicationState>().accountLoading;

    if (isAccountLoading) {
      return const LoadingScreen();
    }

    if (loggedIn) {
      if (user == null) {
        return const SignUpTypeScreen();
      }
      if (user.role == UserRole.student) {
        return const StudentGate();
      } else if (user.role == UserRole.employer) {
        return const JobProviderOfferScreen();
      } else if (user.role == UserRole.admin) {
        return const AdminScreen();
      } else {
        return const WelcomeScreen();
      }
    } else {
      return const WelcomeScreen();
    }
  }
}
