import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/logout_button.dart';

import '../providers/job_provider.dart';
import '../widgets/job_student_item.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: true);
    final jobs = jobProvider.jobs;
    final isLoading = jobProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('Vagoflax'),
        centerTitle: true,
        actions: [const LogoutButton()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
          ? const Center(child: Text('No jobs available'))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return JobStudentItem(job: job);
              },
            ),
    );
  }
}
