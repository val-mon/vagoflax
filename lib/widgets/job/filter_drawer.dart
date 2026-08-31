import 'package:flutter/material.dart';

import 'package:vagoflax/models/job_filters.dart';
import 'package:vagoflax/models/job.dart';

import 'package:vagoflax/models/enum/diplomas.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/role.dart';

class JobFilterDrawer extends StatefulWidget {
  final List<Job> jobs;
  final JobFilters initialFilters;
  final ValueChanged<JobFilters> onApply;

  const JobFilterDrawer({
    super.key,
    required this.jobs,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<JobFilterDrawer> createState() => _JobFilterDrawerState();
}

class _JobFilterDrawerState extends State<JobFilterDrawer> {
  late Set<Diplomas> selectedDiplomas;
  late Set<Role> selectedRoles;
  late Set<Industry> selectedIndustries;
  late Set<Languages> selectedLanguages;

  RangeValues? salaryRange;

  double? availableMinSalary;
  double? availableMaxSalary;

  @override
  void initState() {
    super.initState();

    selectedDiplomas = {...widget.initialFilters.diplomas};
    selectedRoles = {...widget.initialFilters.roles};
    selectedIndustries = {...widget.initialFilters.industries};
    selectedLanguages = {...widget.initialFilters.languages};

    _initializeSalaryRange();
  }

  // ------------------------------------------------------------
  // Salary
  // ------------------------------------------------------------

  void _initializeSalaryRange() {
    final salaries = widget.jobs
        .map((job) => job.salary ?? job.predictedSalary)
        .whereType<double>()
        .toList();

    if (salaries.isEmpty) {
      availableMinSalary = null;
      availableMaxSalary = null;
      salaryRange = null;
      return;
    }

    availableMinSalary = salaries.reduce((a, b) => a < b ? a : b);
    availableMaxSalary = salaries.reduce((a, b) => a > b ? a : b);

    final start = widget.initialFilters.minSalary ?? availableMinSalary!;
    final end = widget.initialFilters.maxSalary ?? availableMaxSalary!;

    salaryRange = RangeValues(start, end);
  }

  // ------------------------------------------------------------
  // Reset
  // ------------------------------------------------------------

  void _resetFilters() {
    setState(() {
      selectedDiplomas.clear();
      selectedRoles.clear();
      selectedIndustries.clear();
      selectedLanguages.clear();

      if (availableMinSalary != null && availableMaxSalary != null) {
        salaryRange = RangeValues(availableMinSalary!, availableMaxSalary!);
      }
    });
  }

  // ------------------------------------------------------------
  // Apply
  // ------------------------------------------------------------

  void _applyFilters() {
    double? minSalary;
    double? maxSalary;

    if (salaryRange != null &&
        availableMinSalary != null &&
        availableMaxSalary != null) {
      final isFullRange =
          salaryRange!.start == availableMinSalary &&
          salaryRange!.end == availableMaxSalary;

      if (!isFullRange) {
        minSalary = salaryRange!.start;
        maxSalary = salaryRange!.end;
      }
    }

    widget.onApply(
      JobFilters(
        minSalary: minSalary,
        maxSalary: maxSalary,
        diplomas: {...selectedDiplomas},
        roles: {...selectedRoles},
        industries: {...selectedIndustries},
        languages: {...selectedLanguages},
      ),
    );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<Diplomas> availableDiplomas = widget.jobs
        .expand((job) => job.diplomas)
        .toSet()
        .toList();

    final List<Role> availableRoles = widget.jobs
        .map((job) => job.role)
        .toSet()
        .toList();

    final List<Industry> availableIndustries = widget.jobs
        .map((job) => job.industry)
        .toSet()
        .toList();

    final List<Languages> availableLanguages = widget.jobs
        .expand((job) => job.languages)
        .toSet()
        .toList();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filter sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildSalaryFilter(),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdownSection<Diplomas>(
                    title: 'Diplomas',
                    icon: Icons.school_outlined,
                    values: availableDiplomas,
                    selectedValues: selectedDiplomas,
                    labelBuilder: (diploma) => diploma.name,
                  ),

                  _buildDropdownSection<Role>(
                    title: 'Roles',
                    icon: Icons.work_outline,
                    values: availableRoles,
                    selectedValues: selectedRoles,
                    labelBuilder: (role) => role.name,
                  ),

                  _buildDropdownSection<Industry>(
                    title: 'Industries',
                    icon: Icons.business_outlined,
                    values: availableIndustries,
                    selectedValues: selectedIndustries,
                    labelBuilder: (industry) => industry.name,
                  ),

                  _buildDropdownSection<Languages>(
                    title: 'Languages',
                    icon: Icons.language_outlined,
                    values: availableLanguages,
                    selectedValues: selectedLanguages,
                    labelBuilder: (language) => language.name,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Dropdown filter section (ExpansionTile)
  // ------------------------------------------------------------

  Widget _buildDropdownSection<T>({
    required String title,
    required IconData icon,
    required List<T> values,
    required Set<T> selectedValues,
    required String Function(T value) labelBuilder,
  }) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedCount = selectedValues.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$selectedCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: values.map((value) {
          final isSelected = selectedValues.contains(value);

          return CheckboxListTile(
            dense: true,
            title: Text(_formatEnumName(labelBuilder(value))),
            value: isSelected,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  selectedValues.add(value);
                } else {
                  selectedValues.remove(value);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // ------------------------------------------------------------
  // Salary widget
  // ------------------------------------------------------------

  Widget _buildSalaryFilter() {
    if (salaryRange == null ||
        availableMinSalary == null ||
        availableMaxSalary == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'No salary information available.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    if (availableMinSalary == availableMaxSalary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('CHF ${availableMinSalary!.round()}'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Salary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'CHF ${salaryRange!.start.round()} - CHF ${salaryRange!.end.round()}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        RangeSlider(
          min: availableMinSalary!,
          max: availableMaxSalary!,
          values: salaryRange!,
          labels: RangeLabels(
            'CHF ${salaryRange!.start.round()}',
            'CHF ${salaryRange!.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              salaryRange = values;
            });
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Formatting
  // ------------------------------------------------------------

  String _formatEnumName(String value) {
    if (value.isEmpty) {
      return value;
    }

    final formatted = value
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .trim();

    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}