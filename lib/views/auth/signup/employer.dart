import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/providers/auth.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:vagoflax/services/address.dart';

class SignUpEmployerScreen extends StatefulWidget {
  const SignUpEmployerScreen({super.key});

  @override
  State<SignUpEmployerScreen> createState() => _SignUpEmployerScreenState();
}

class _SignUpEmployerScreenState extends State<SignUpEmployerScreen> {
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cantonController = TextEditingController();
  final _addressController = TextEditingController();
  final _companySizeController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _addressSelected = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // disposes of answers when the widget is closed
  @override
  void dispose() {
    _selectedImage?.delete(); // Delete the temporary image file if it exists
    _nameController.dispose();
    _descriptionController.dispose();
    _cantonController.dispose();
    _addressController.dispose();
    _companySizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading, // Prevent back navigation when loading
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employer account setup'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // profile picture
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Add a profile picture',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),

              const SizedBox(height: 32),
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

              //address
              Autocomplete<AddressSuggestion>(
                displayStringForOption: (option) => option.fullAddress,
                optionsBuilder: (value) async {
                  if (value.text.trim().length < 3) {
                    return const Iterable<AddressSuggestion>.empty();
                  }
                  try {
                    return await AddressService.search(value.text);
                  } catch (_) {
                    return const Iterable<AddressSuggestion>.empty();
                  }
                },
                onSelected: (address) {
                  _addressController.text = address.fullAddress;
                  _cantonController.text = address.canton;
                  _addressSelected = true;
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  );
                },
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
                onPressed: () async {
                  if (_isLoading) return; // Prevent multiple taps

                  setState(() {
                    _isLoading = true;
                  });

                  final name = _nameController.text.trim();
                  final desc = _descriptionController.text.trim();
                  final canton = _cantonController.text.trim();
                  final address = _addressController.text.trim();
                  final companySize =
                      int.tryParse(_companySizeController.text.trim()) ?? 0;

                  if (!_addressSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a valid address.'),
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    return;
                  }

                  if (name.isEmpty ||
                      desc.isEmpty ||
                      canton.isEmpty ||
                      address.isEmpty ||
                      companySize == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields.'),
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    return;
                  }

                  // launch app_state signUpStep4Employer and then navigate to next screen
                  try {
                    await context.read<ApplicationState>().signUpStep4Employer(
                      name,
                      desc,
                      canton,
                      address,
                      companySize,
                      _selectedImage,
                    );
                    if (!context.mounted) return;
                    context.go('/');
                    setState(() {
                      _isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error occurred while signing up.'),
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
                    : const Text(
                        'Finish signing up',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
