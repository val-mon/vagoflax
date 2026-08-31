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

      // Si le slider est sur toute la plage disponible,
      // on considère que le filtre salaire n'est pas actif.
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
    // On affiche uniquement les valeurs réellement présentes
    // dans les jobs actuellement disponibles.

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
            // --------------------------------------------------
            // Header
            // --------------------------------------------------

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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // --------------------------------------------------
            // Filters
            // --------------------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Salary
                  _buildSalaryFilter(),

                  const SizedBox(height: 24),

                  // Diplomas
                  _buildFilterSection<Diplomas>(
                    title: 'Diplomas',
                    values: availableDiplomas,
                    selectedValues: selectedDiplomas,
                    labelBuilder: (diploma) => diploma.name,
                  ),

                  const SizedBox(height: 24),

                  // Roles
                  _buildFilterSection<Role>(
                    title: 'Roles',
                    values: availableRoles,
                    selectedValues: selectedRoles,
                    labelBuilder: (role) => role.name,
                  ),

                  const SizedBox(height: 24),

                  // Industries
                  _buildFilterSection<Industry>(
                    title: 'Industries',
                    values: availableIndustries,
                    selectedValues: selectedIndustries,
                    labelBuilder: (industry) => industry.name,
                  ),

                  const SizedBox(height: 24),

                  // Languages
                  _buildFilterSection<Languages>(
                    title: 'Languages',
                    values: availableLanguages,
                    selectedValues: selectedLanguages,
                    labelBuilder: (language) => language.name,
                  ),
                ],
              ),
            ),

            const Divider(),

            // --------------------------------------------------
            // Bottom actions
            // --------------------------------------------------
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'No salary information available.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // RangeSlider nécessite une différence entre min et max.
    if (availableMinSalary == availableMaxSalary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('CHF ${availableMinSalary!.round()}'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          'CHF ${salaryRange!.start.round()}'
          ' - '
          'CHF ${salaryRange!.end.round()}',
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
  // Generic filter section
  // ------------------------------------------------------------

  Widget _buildFilterSection<T>({
    required String title,
    required List<T> values,
    required Set<T> selectedValues,
    required String Function(T value) labelBuilder,
  }) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            final selected = selectedValues.contains(value);

            return FilterChip(
              label: Text(_formatEnumName(labelBuilder(value))),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedValues.add(value);
                  } else {
                    selectedValues.remove(value);
                  }
                });
              },
            );
          }).toList(),
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
