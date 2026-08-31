import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/app_state.dart';

class SignUpTypeScreen extends StatelessWidget {
  const SignUpTypeScreen({super.key});

  // save the role in the app state, then go to the matching profile form
  void _selectRole(BuildContext context, String role, String route) {
    context.read<ApplicationState>().signUpStep3(role);
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account setup'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<ApplicationState>().signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // Title text
            const Text(
              'What are you ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            ),

            const SizedBox(height: 48),

            // Student button with icon
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  _selectRole(context, 'student', '/signup/student'),
              icon: const Icon(Icons.school, size: 28), // Graduation cap icon
              label: const Text(
                'Student',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16), // Spacing between the two buttons
            // Employer button with icon
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () =>
                  _selectRole(context, 'employer', '/signup/employer'),
              icon: const Icon(Icons.business, size: 28), // Building icon
              label: const Text(
                'Employer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
