import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:provider/provider.dart';

class SignUpEmailPwScreen extends StatefulWidget {
  const SignUpEmailPwScreen({super.key});

  @override
  State<SignUpEmailPwScreen> createState() => _SignUpEmailPwScreenState();
}

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

class _SignUpEmailPwScreenState extends State<SignUpEmailPwScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Email',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Password',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Confirm Password',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
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
              onPressed: () {
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
                  return;
                }

                // lancer app_state saveSignUpStep1Data(email, password) and then navigate to next screen
                context.read<ApplicationState>().saveSignUpStep1Data(
                  email,
                  password,
                );

                context.push('/signup/2');
              },
              child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
