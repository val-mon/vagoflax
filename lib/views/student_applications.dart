import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/logout_button.dart';

import '../providers/app_state.dart';
import '../providers/job_provider.dart';
import '../widgets/job_student_item.dart';

class StudentApplicationsScreen extends StatelessWidget {
  const StudentApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final userId = context.watch<ApplicationState>().userId;

    final isLoading = jobProvider.isLoading;

    final appliedJobs = jobProvider.jobs
        .where((job) => job.applicants.contains(userId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('My applications'),
        centerTitle: true,
        actions: const [LogoutButton()],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appliedJobs.isEmpty
          ? const Center(child: Text('You have not applied to any job yet'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: appliedJobs.length,
              itemBuilder: (context, index) {
                return JobStudentItem(job: appliedJobs[index]);
              },
            ),
    );
  }
}
