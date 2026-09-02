import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/history.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/services/address.dart';

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
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cantonController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillController = TextEditingController();
  final _companySizeController = TextEditingController();

  final _historyTitleController = TextEditingController();
  final _historyCompanyController = TextEditingController();
  DateTime? _historyStartedAt;
  DateTime? _historyEndedAt;

  final List<String> _skills = [];
  final List<HistoryEntry> _history = [];

  bool isSaving = false;
  bool _addressSelected = false;

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
    _companyNameController.text = state?.companyName ?? '';
    _addressController.text = state?.address ?? '';
    _cantonController.text = state?.canton ?? '';
    _descriptionController.text = state?.description ?? '';
    _companySizeController.text = state?.companySize?.toString() ?? '';
    _historyTitleController.text = '';
    _historyCompanyController.text = '';
    _historyStartedAt = null;
    _historyEndedAt = null;
    _skills.addAll(state?.skills ?? []);
    _history.addAll(state?.history ?? []);
    _addressSelected = state?.address != null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    _cantonController.dispose();
    _descriptionController.dispose();
    _companySizeController.dispose();
    _skillController.dispose();
    _historyTitleController.dispose();
    _historyCompanyController.dispose();
    _historyStartedAt = null;
    _historyEndedAt = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<UserProvider>().currentUser;
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
              if (state?.role == UserRole.student) ...[
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
              ] else if (state?.role == UserRole.employer) ...[
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(labelText: 'Company name'),
                  validator: _required,
                ),
              ],
              const SizedBox(height: 16),
              Autocomplete<AddressSuggestion>(
                initialValue: TextEditingValue(text: _addressController.text),
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              if (state?.role == UserRole.student) ...[
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
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addSkill,
                    ),
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
                      label: Text(s.jobTitle),
                      onDeleted: () => setState(() => _history.remove(s)),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _historyTitleController,
                  decoration: const InputDecoration(labelText: 'Job title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _historyCompanyController,
                  decoration: const InputDecoration(labelText: 'Company'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _historyStartedAt ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _historyStartedAt = date);
                          }
                        },
                        child: Text(
                          _historyStartedAt == null
                              ? 'Start date'
                              : _formatDate(_historyStartedAt!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _historyEndedAt ??
                                _historyStartedAt ??
                                DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _historyEndedAt = date);
                          }
                        },
                        child: Text(
                          _historyEndedAt == null
                              ? 'End date'
                              : _formatDate(_historyEndedAt!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add history item'),
                    onPressed: _addHistory,
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _companySizeController,
                  decoration: const InputDecoration(labelText: 'Company size'),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
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
    final title = _historyTitleController.text.trim();
    final company = _historyCompanyController.text.trim();

    if (title.isEmpty ||
        company.isEmpty ||
        _historyStartedAt == null ||
        _historyEndedAt == null) {
      return;
    }

    setState(() {
      _history.add(
        HistoryEntry(
          jobTitle: title,
          company: company,
          startedAt: _historyStartedAt!,
          endedAt: _historyEndedAt!,
        ),
      );

      _historyTitleController.clear();
      _historyCompanyController.clear();
      _historyStartedAt = null;
      _historyEndedAt = null;
    });
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_addressSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid address')),
      );
      return;
    }

    setState(() => isSaving = true);

    if (context.read<UserProvider>().currentUser?.role == UserRole.student) {
      await context.read<UserProvider>().updateUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        canton: _cantonController.text.trim(),
        description: _descriptionController.text.trim(),
        skills: _skills,
        history: _history,
        profilePicture: _profilePicture,
      );
    } else {
      await context.read<UserProvider>().updateUser(
        companyName: _companyNameController.text.trim(),
        companySize: int.tryParse(_companySizeController.text.trim()),
        address: _addressController.text.trim(),
        canton: _cantonController.text.trim(),
        description: _descriptionController.text.trim(),
        profilePicture: _profilePicture,
      );
    }

    setState(() => isSaving = false);
    if (!mounted) return;
    context.pop();
  }
}
