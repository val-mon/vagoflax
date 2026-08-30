import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/search_filter.dart';
import 'package:vagoflax/widgets/profile_button.dart';

import '../../providers/job_provider.dart';
import '../../widgets/job_student_item.dart';

import 'package:vagoflax/models/job_filters.dart';
import 'package:vagoflax/widgets/job_filter_drawer.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  String searchQuery = '';

  JobFilters filters = const JobFilters();

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: true);

    final jobs = jobProvider.jobs;
    final isLoading = jobProvider.isLoading;

    final filteredJobs = jobs.where((job) {
      //
      // Search
      //
      final query = searchQuery.trim().toLowerCase();

      final description = job.description?.toLowerCase() ?? '';
      final matchesSearch =
          query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          description.toLowerCase().contains(query);

      //
      // Salary
      //
      final salary = job.salary ?? job.predictedSalary;

      final matchesMinSalary =
          filters.minSalary == null ||
          (salary != null && salary >= filters.minSalary!);

      final matchesMaxSalary =
          filters.maxSalary == null ||
          (salary != null && salary <= filters.maxSalary!);

      //
      // Diplomas
      //
      final matchesDiplomas =
          filters.diplomas.isEmpty ||
          job.diplomas.any((diploma) => filters.diplomas.contains(diploma));

      //
      // Role
      //
      final matchesRoles =
          filters.roles.isEmpty || filters.roles.contains(job.role);

      //
      // Industry
      //
      final matchesIndustries =
          filters.industries.isEmpty ||
          filters.industries.contains(job.industry);

      //
      // Languages
      //
      final matchesLanguages =
          filters.languages.isEmpty ||
          job.languages.any((language) => filters.languages.contains(language));

      return matchesSearch &&
          matchesMinSalary &&
          matchesMaxSalary &&
          matchesDiplomas &&
          matchesRoles &&
          matchesIndustries &&
          matchesLanguages &&
          job.visible;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('Vagoflax'),
        centerTitle: true,
        actions: [const ProfileButton()],
      ),
      endDrawer: JobFilterDrawer(
        jobs: jobs,
        initialFilters: filters,
        onApply: (newFilters) {
          setState(() {
            filters = newFilters;
          });

          Navigator.pop(context);
        },
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SearchFilter(
                  activeFilterCount: filters.activeFilterCount,
                  onSearch: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),

                Expanded(
                  child: filteredJobs.isEmpty
                      ? const Center(child: Text('No jobs match your filters'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];

                            return JobStudentItem(job: job);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
