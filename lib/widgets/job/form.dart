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
import 'package:vagoflax/models/salary_prediction_model.dart';
import 'package:vagoflax/services/salary_prediction.dart';

import 'package:go_router/go_router.dart';

class JobForm extends StatefulWidget {
  final Job? job;

  const JobForm({super.key, this.job});

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  final _formKey = GlobalKey<FormState>();
  final _salaryPredictionService = SalaryPredictionService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minYearsExperienceController = TextEditingController();
  final _maxYearsExperienceController = TextEditingController();
  final _contractTimeController = TextEditingController();
  final _holidaysController = TextEditingController();
  final _maternityLeaveController = TextEditingController();
  final _paternityLeaveController = TextEditingController();
  final _workloadPercentController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _visible = true;

  Role _selectedRole = Role.intern;
  Industry _selectedIndustry = Industry.informationTechnology;
  Diplomas _selectedDiploma = Diplomas.bachelor;

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
      _minYearsExperienceController.text =
          job.minYearsExperience?.toString() ?? '';
      _maxYearsExperienceController.text =
          job.maxYearsExperience?.toString() ?? '';
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
      _selectedDiploma = job.diploma;
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
    _minYearsExperienceController.dispose();
    _maxYearsExperienceController.dispose();
    _contractTimeController.dispose();
    _holidaysController.dispose();
    _maternityLeaveController.dispose();
    _paternityLeaveController.dispose();
    _workloadPercentController.dispose();
    _salaryController.dispose();
    _salaryPredictionService.dispose();
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
              validator: (v) => _stringLength(v, 50, true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Job Description'),
              validator: (v) => _stringLength(v, 500, false),
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

            DropdownButtonFormField<Diplomas>(
              initialValue: _selectedDiploma,
              decoration: const InputDecoration(labelText: 'Diploma'),
              items: Diplomas.values
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedDiploma = value);
              },
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
              controller: _minYearsExperienceController,
              decoration: const InputDecoration(
                labelText: 'Minimum years of experience',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => _intLength(v, 0, 50, false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxYearsExperienceController,
              decoration: const InputDecoration(
                labelText: 'Maximum years of experience',
              ),
              keyboardType: TextInputType.number,
              validator: _maxExperienceValidator,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contractTimeController,
              decoration: const InputDecoration(
                labelText: 'Contract time (months)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => _intLength(v, 0, 600, false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _holidaysController,
              decoration: const InputDecoration(labelText: 'Holidays (days)'),
              keyboardType: TextInputType.number,
              validator: (v) => _intLength(v, 0, 365, false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maternityLeaveController,
              decoration: const InputDecoration(
                labelText: 'Maternity leave (weeks)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => _intLength(v, 0, 52, false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paternityLeaveController,
              decoration: const InputDecoration(
                labelText: 'Paternity leave (weeks)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => _intLength(v, 0, 52, false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workloadPercentController,
              decoration: const InputDecoration(labelText: 'Workload (%)'),
              keyboardType: TextInputType.number,
              validator: _workloadValidator,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _salaryController,
              decoration: const InputDecoration(labelText: 'Salary (optional)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => _doubleLength(v, 0, 1000000, false),
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
              onPressed: () async => await _saveJob(context),
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

  String? _stringLength(String? value, int max, bool required) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'This field is required';
    }
    if (value != null && value.length > max) {
      return 'Maximum length is $max characters';
    }
    return null;
  }

  String? _doubleLength(String? value, double min, double max, bool required) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'This field is required';
    }
    if (value != null) {
      final parsed = double.tryParse(value);
      if (parsed == null) return null;
      if (parsed < min || parsed > max) {
        return 'Enter a value between $min and $max';
      }
    }
    return null;
  }

  String? _intLength(String? value, int min, int max, bool required) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'This field is required';
    }
    if (value != null) {
      final parsed = int.tryParse(value);
      if (parsed == null) return null;
      if (parsed < min || parsed > max) {
        return 'Enter a value between $min and $max';
      }
    }
    return null;
  }

  String? _requiredNonNegativeIntValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty values for optional fields
    }

    final parsed = int.tryParse(value);
    if (parsed == null) return 'Enter a whole number';
    if (parsed < 0) return 'Enter a positive value';
    return null;
  }

  String? _maxExperienceValidator(String? value) {
    final validationError = _requiredNonNegativeIntValidator(value);
    if (validationError != null) return validationError;


    final minimum = int.tryParse(_minYearsExperienceController.text) ?? 0;

    final maximum = int.tryParse(value ?? '0') ?? 0;

    if (maximum < minimum) {
      _maxYearsExperienceController.text = minimum.toString();
      return null;
    }

    if (maximum > 50) {
      return 'Maximum years of experience cannot exceed 50';
    }

    return null;
  }

  String? _workloadValidator(String? value) {
    final validationError = _requiredNonNegativeIntValidator(value);
    if (validationError != null) return validationError;

    final workload = int.parse(value!);
    if (workload == 0 || workload > 100) {
      return 'Enter a value between 1 and 100';
    }

    return null;
  }

  Future<void> _saveJob(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    final draftJob = Job(
      id: widget.job?.id,
      userUuid: context.read<UserProvider>().currentUser?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      diploma: _selectedDiploma,
      minYearsExperience: int.tryParse(_minYearsExperienceController.text) ?? 0,
      maxYearsExperience: int.tryParse(_maxYearsExperienceController.text) ?? 0,
      contractTime: int.tryParse(_contractTimeController.text) ?? 0,
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
      createdAt: widget.job?.createdAt,
    );

    final employer = context.read<UserProvider>().currentUser;
    if (employer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load the employer profile.')),
      );
      return;
    }

    late final Job job;
    try {
      final predictionInput = SalaryPredictionInput.fromJobAndEmployer(
        job: draftJob,
        employer: employer,
      );
      final predictedSalary = await _salaryPredictionService.predict(
        predictionInput,
      );
      job = draftJob.withPredictedSalary(predictedSalary);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Salary prediction failed: $error')),
      );
      return;
    }

    if (widget.job == null) {
      await jobProvider.addJob(job);
    } else {
      await jobProvider.updateJob(job);
    }

    if (context.mounted) {
      context.pop();
    }
  }
}
