import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:provider/provider.dart';

class SignUpEmployerScreen extends StatefulWidget {
  const SignUpEmployerScreen({super.key});

  @override
  State<SignUpEmployerScreen> createState() => _SignUpEmployerScreenState();
}

final _nameController = TextEditingController();
final _descriptionController = TextEditingController();
final _cantonController = TextEditingController();
final _cityController = TextEditingController();
final _companySizeController = TextEditingController();

class _SignUpEmployerScreenState extends State<SignUpEmployerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Sign Up'),
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
                        text: 'Company Name',
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

            const SizedBox(height: 16),

            TextField(
              controller: _companySizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Number of employees in your company',
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
                final companySize = int.tryParse(_companySizeController.text.trim()) ?? 0;

                if (name.isEmpty || desc.isEmpty || canton.isEmpty || city.isEmpty || companySize == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                // lancer app_state saveSignUpStep1Data(email, password) and then navigate to next screen
                context.read<ApplicationState>().saveSignUpStep3Employer(name, desc, canton, city, companySize);

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