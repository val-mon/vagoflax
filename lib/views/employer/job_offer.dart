import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/job_filters.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/job/filter_drawer.dart';
import 'package:vagoflax/widgets/profile_button.dart';

import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/widgets/job/employer_item.dart';
import 'package:vagoflax/widgets/search_filter.dart';

class JobProviderOfferScreen extends StatefulWidget {
  const JobProviderOfferScreen({super.key});

  @override
  State<JobProviderOfferScreen> createState() => _JobProviderOfferScreenState();
}

class _JobProviderOfferScreenState extends State<JobProviderOfferScreen> {
  String searchQuery = '';
  JobFilters filters = const JobFilters();

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final userProvider = context.watch<UserProvider>();
    final jobs = jobProvider.jobs
        .where((job) => job.userUuid == userProvider.currentUser?.id)
        .toList();
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
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredJobs.isEmpty
                      ? const Center(child: Text('No jobs available'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];

                            return JobEmployerItem(job: job);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-job');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
