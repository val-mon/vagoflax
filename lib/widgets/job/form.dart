import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/user.dart';

import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/enum/diplomas.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/enum/perks.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/providers/job.dart';

import 'package:go_router/go_router.dart';

class JobForm extends StatefulWidget {
  final Job? job;

  const JobForm({super.key, this.job});

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contractTimeController = TextEditingController();
  final _holidaysController = TextEditingController();
  final _maternityLeaveController = TextEditingController();
  final _paternityLeaveController = TextEditingController();
  final _workloadPercentController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _visible = true;

  Role _selectedRole = Role.intern;
  Industry _selectedIndustry = Industry.informationTechnology;

  final List<Diplomas> _selectedDiplomas = [];
  final List<Perks> _selectedPerks = [];
  final List<Languages> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    if (job != null) {
      // Editing an existing job
      _titleController.text = job.title;
      _descriptionController.text = job.description ?? '';
      _contractTimeController.text = job.contractTime == null
          ? ''
          : job.contractTime.toString();
      _holidaysController.text = job.holidays == null
          ? ''
          : job.holidays.toString();
      _maternityLeaveController.text = job.maternityLeave == null
          ? ''
          : job.maternityLeave.toString();
      _paternityLeaveController.text = job.paternityLeave == null
          ? ''
          : job.paternityLeave.toString();
      _workloadPercentController.text = job.workloadPercent == null
          ? ''
          : job.workloadPercent.toString();
      _salaryController.text = job.salary?.toString() ?? '';
      _selectedRole = job.role;
      _selectedIndustry = job.industry;
      _selectedDiplomas.addAll(job.diplomas);
      _selectedPerks.addAll(job.perks);
      _selectedLanguages.addAll(job.languages);
      _visible = job.visible;
    } else {
      // DEfault values for a new job
      _holidaysController.text = '20';
      _maternityLeaveController.text = '14';
      _paternityLeaveController.text = '2';
      _workloadPercentController.text = '100';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contractTimeController.dispose();
    _holidaysController.dispose();
    _maternityLeaveController.dispose();
    _paternityLeaveController.dispose();
    _workloadPercentController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Job Title'),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Job Description'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<Role>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: Role.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedRole = value);
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<Industry>(
              initialValue: _selectedIndustry,
              decoration: const InputDecoration(labelText: 'Industry'),
              items: Industry.values
                  .map((i) => DropdownMenuItem(value: i, child: Text(i.name)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedIndustry = value);
              },
            ),
            const SizedBox(height: 16),

            _buildMultiSelect<Diplomas>(
              label: 'Diplomas',
              all: Diplomas.values,
              selected: _selectedDiplomas,
            ),
            const SizedBox(height: 16),
            _buildMultiSelect<Perks>(
              label: 'Perks',
              all: Perks.values,
              selected: _selectedPerks,
            ),
            const SizedBox(height: 16),
            _buildMultiSelect<Languages>(
              label: 'Languages',
              all: Languages.values,
              selected: _selectedLanguages,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contractTimeController,
              decoration: const InputDecoration(
                labelText: 'Contract time (months)',
              ),
              keyboardType: TextInputType.number,
              validator: _intValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _holidaysController,
              decoration: const InputDecoration(labelText: 'Holidays (days)'),
              keyboardType: TextInputType.number,
              validator: _intValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maternityLeaveController,
              decoration: const InputDecoration(
                labelText: 'Maternity leave (weeks)',
              ),
              keyboardType: TextInputType.number,
              validator: _intValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paternityLeaveController,
              decoration: const InputDecoration(
                labelText: 'Paternity leave (weeks)',
              ),
              keyboardType: TextInputType.number,
              validator: _intValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workloadPercentController,
              decoration: const InputDecoration(labelText: 'Workload (%)'),
              keyboardType: TextInputType.number,
              validator: _intValidator,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _salaryController,
              decoration: const InputDecoration(labelText: 'Salary (optional)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is job visible?'),
              value: _visible,
              tileColor: Colors.transparent,
              onChanged: (value) {
                setState(() {
                  _visible = value;
                });
              },
              secondary: const Icon(Icons.visibility),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => _saveJob(context),
              child: Text(widget.job == null ? 'Create Job' : 'Update Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelect<T extends Enum>({
    required String label,
    required List<T> all,
    required List<T> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: all.map((item) {
            return FilterChip(
              label: Text(item.name),
              selected: selected.contains(item),
              onSelected: (value) {
                setState(() {
                  value ? selected.add(item) : selected.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? _intValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value) == null) return 'Enter a whole number';
    return null;
  }

  void _saveJob(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    final job = Job(
      id: widget.job?.id,
      userUuid: context.read<UserProvider>().currentUser?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      diplomas: _selectedDiplomas,
      contractTime: int.tryParse(_contractTimeController.text),
      role: _selectedRole,
      industry: _selectedIndustry,
      perks: _selectedPerks,
      languages: _selectedLanguages,
      holidays: int.tryParse(_holidaysController.text),
      maternityLeave: int.tryParse(_maternityLeaveController.text),
      paternityLeave: int.tryParse(_paternityLeaveController.text),
      workloadPercent: int.tryParse(_workloadPercentController.text),
      salary: double.tryParse(_salaryController.text),
      visible: _visible,
      translations: widget.job?.translations ?? [],
    );

    if (widget.job == null) {
      jobProvider.addJob(job);
    } else {
      jobProvider.updateJob(job);
    }

    context.pop();
  }
}
