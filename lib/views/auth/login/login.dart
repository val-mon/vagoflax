import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// import 'package:vagoflax/views/job_list_screen.dart'; // Décommente si besoin pour la navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

bool _isLoading = false;

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Camera recognition not implemented yet.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (_isLoading) return; // Prevent multiple taps

                // remove old error message
                ScaffoldMessenger.of(context).clearSnackBars();

                setState(() {
                  _isLoading = true;
                });

                final email = _emailController.text.trim();
                final password = _passwordController.text;

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill in both email and password fields.',
                      ),
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                try {
                  await context.read<ApplicationState>().logIn(email, password);
                  if (context.mounted) context.go('/');
                  setState(() {
                    _isLoading = false;
                  });

                  _emailController.clear();
                  _passwordController.clear();
                } on FirebaseAuthException catch (e) {
                  if (!context.mounted) return; // if user navigated away, don't show snackbar so it doesn't crash

                  setState(() {
                    _isLoading = false;
                  });

                  String errorMessage =
                      'Unexcpected error occurred. Please try again.';

                  switch (e.code) {
                    case 'invalid-email':
                      errorMessage = "The email address is badly formatted.";
                      break;
                    case 'user-disabled':
                      errorMessage = "This account has been disabled.";
                      break;
                    case 'user-not-found': // Old version of firebase, just in case
                    case 'wrong-password': // Old version of firebase, just in case
                    case 'invalid-credential':
                      errorMessage = "Email or password is incorrect.";
                      break;
                    case 'network-request-failed':
                      errorMessage = "Please check your internet connection.";
                      break;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'An unexpected error occurred. Please try again.',
                      ),
                    ),
                  );
                }
              },
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Log In', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
