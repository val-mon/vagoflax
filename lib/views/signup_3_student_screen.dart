import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:provider/provider.dart';

class SignUpStudentScreen extends StatefulWidget {
  const SignUpStudentScreen({super.key});

  @override
  State<SignUpStudentScreen> createState() => _SignUpStudentScreenState();
}

final _nameController = TextEditingController();
final _descriptionController = TextEditingController();
final _cantonController = TextEditingController();
final _cityController = TextEditingController();

class _SignUpStudentScreenState extends State<SignUpStudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Sign Up'),
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // name
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Full name',
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

            //description
            TextField(
              controller: _descriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Description',
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
              controller: _cantonController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Canton (e.g., ZH, GE, VD)',
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
              controller: _cityController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'City',
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
                final name = _nameController.text.trim();
                final desc = _descriptionController.text.trim();
                final canton = _cantonController.text.trim();
                final city = _cityController.text.trim();

                if (name.isEmpty || desc.isEmpty || canton.isEmpty || city.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                // lancer app_state saveSignUpStep1Data(email, password) and then navigate to next screen
                context.read<ApplicationState>().saveSignUpStep3Student(name, desc, canton, city);

                context.go('/signup/finish');
              },
              child: const Text(
                'Finish signing up',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}