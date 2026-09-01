import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/auth.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/services/face.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isRecognizing = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your email.')),
                );
                return;
              }

              Navigator.pop(ctx);

              try {
                await context.read<ApplicationState>().sendPasswordResetEmail(
                  email,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset link sent! Check your inbox.',
                    ),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                String message = 'Failed to send reset email.';
                if (e.code == 'invalid-email') {
                  message = 'The email address is invalid.';
                }
                _showError(message);
              } catch (_) {
                if (!mounted) return;
                _showError('An unexpected error occurred.');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _recognizeFace() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _isRecognizing = true);

    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (file == null) {
        setState(() => _isRecognizing = false);
        return;
      }

      final signature = await FaceRecognitionService.instance.getFaceSignature(
        File(file.path),
      );

      if (!mounted) {
        return;
      }

      final knownFaces = context.read<UserProvider>().faceIndex;
      final matched = FaceRecognitionService.instance.findClosestMatch(
        signature,
        knownFaces,
        (entry) => entry.signature,
      );

      if (matched == null) {
        _showError('No face recognized. Please log in with your email.');
      } else {
        setState(() => _emailController.text = matched.email);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isRecognizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoading || _isRecognizing;

    return Scaffold(
      appBar: AppBar(title: const Text('Log In'), centerTitle: true),
      body: SingleChildScrollView(
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
                _isRecognizing
                    ? const SizedBox(
                        height: 32,
                        width: 32,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        iconSize: 32,
                        tooltip: 'Find my account with my face',
                        icon: const Icon(Icons.camera_alt),
                        onPressed: isBusy ? null : () => _recognizeFace(),
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
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isBusy ? null : _showForgotPasswordDialog,
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
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
                if (isBusy) return; // Prevent multiple taps

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
