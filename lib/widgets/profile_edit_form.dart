import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/models/history_model.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:vagoflax/providers/user_provider.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({super.key});

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();

  File? _profilePicture;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _cantonController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillController = TextEditingController();
  final _historyController = TextEditingController();

  final List<String> _skills = [];
  final List<HistoryEntry> _history = [];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profilePicture = File(picked.path));
    }
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<UserProvider>().currentUser;
    _firstNameController.text = state?.firstName ?? '';
    _lastNameController.text = state?.lastName ?? '';
    _cityController.text = state?.city ?? '';
    _cantonController.text = state?.canton ?? '';
    _descriptionController.text = state?.description ?? '';
    _skills.addAll(state?.skills ?? []);
    _history.addAll(state?.history ?? []);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _cantonController.dispose();
    _descriptionController.dispose();
    _historyController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profilePicture != null
                        ? FileImage(_profilePicture!)
                        : null,
                    child: _profilePicture == null
                        ? const Icon(Icons.add_a_photo, size: 32)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantonController,
                decoration: const InputDecoration(labelText: 'Canton'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              Text('Skills', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _skills.map((s) {
                  return Chip(
                    label: Text(s),
                    onDeleted: () => setState(() => _skills.remove(s)),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: const InputDecoration(
                        labelText: 'Add a skill',
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addSkill),
                ],
              ),
              const SizedBox(height: 24),

              Text('History', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _history.map((s) {
                  return Chip(
                    label: Text(
                      s.jobTitle,
                    ), // TODO: FIX HISTORY RENDERING (AND EDIT AS WELL)
                    onDeleted: () => setState(() => _history.remove(s)),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _historyController,
                      decoration: const InputDecoration(
                        labelText: 'Add a history item',
                      ),
                      onSubmitted: (_) => _addHistory(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addHistory,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  void _addSkill() {
    final text = _skillController.text.trim();
    if (text.isEmpty || _skills.contains(text)) return;
    setState(() {
      _skills.add(text);
      _skillController.clear();
    });
  }

  void _addHistory() {
    final text = _historyController.text.trim();
    if (text.isEmpty ||
        _history.contains(
          HistoryEntry(
            jobTitle: text,
            company: text,
            startedAt: DateTime.now(),
            endedAt: DateTime.now(),
          ),
        )) {
      return; // TODO: FIX THIS
    }
    setState(() {
      _history.add(
        HistoryEntry(
          jobTitle: text,
          company: text,
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
        ),
      ); // Placeholder dates
      _historyController.clear();
    });
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await context.read<UserProvider>().updateUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      city: _cityController.text.trim(),
      canton: _cantonController.text.trim(),
      description: _descriptionController.text.trim(),
      skills: _skills,
      history: _history,
      profilePicture: _profilePicture,
    );

    if (!mounted) return;
    context.pop();
  }
}
