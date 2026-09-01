import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/job/filter_drawer.dart';
import 'package:vagoflax/widgets/search_filter.dart';
import 'package:vagoflax/widgets/profile_button.dart';

import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/widgets/job/student_item.dart';

import 'package:vagoflax/models/job_filters.dart';

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
    final jobProvider = context.watch<JobProvider>();

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

    filteredJobs.sort((a, b) => b.createdAt == null ? -1 : b.createdAt!.compareTo(a.createdAt!));

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('Vagoflax'),
        centerTitle: true,
        actions: [const ProfileButton()],
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
                  onFilterTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => FractionallySizedBox(
                        widthFactor: 1,
                        heightFactor: 0.90,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: JobFilterDrawer(
                            jobs: jobs,
                            initialFilters: filters,
                            onApply: (newFilters) {
                              setState(() {
                                filters = newFilters;
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ),
                    );
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
