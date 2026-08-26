import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/app_state.dart';

class SignUpEndScreen extends StatefulWidget {
  const SignUpEndScreen({super.key});

  @override
  State<SignUpEndScreen> createState() => _SignUpEndScreenState();
}

class _SignUpEndScreenState extends State<SignUpEndScreen> {
  bool _isLoading = false;

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // On lance la création finale définie dans ApplicationState
      await context.read<ApplicationState>().finalizeSignUp();
      
      // Si succès, on redirige vers l'accueil
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      // En cas d'erreur, on arrête le chargement et on affiche l'erreur
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Almost there!'),
          centerTitle: true,
          automaticallyImplyLeading: false, 
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.black87,
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Ready to dive in?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Your profile is set. Click below to finalize your account and start exploring Vagoflax.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              
              const Spacer(),
              
              // Bouton de validation final
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // On désactive le bouton si ça charge déjà
                onPressed: _isLoading ? null : _createAccount,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      )
    );
  }
}