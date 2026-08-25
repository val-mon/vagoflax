import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpEmailPwScreen extends StatelessWidget {
  const SignUpEmailPwScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Name',
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
                // TODO: Implement sign up logic here (validate inputs and add data to context)
                context.push('/signup/2');
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}