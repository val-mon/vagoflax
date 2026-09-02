import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/application.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/job/application_student_item.dart';
import 'package:vagoflax/widgets/profile_button.dart';

import 'package:vagoflax/providers/job.dart';

class StudentApplicationsScreen extends StatelessWidget {
  const StudentApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final userId = context.watch<UserProvider>().currentUser?.id;
    final applicationProvider = context.watch<ApplicationProvider>();

    final applications = applicationProvider.applications
        .where((app) => app.studentUuid == userId)
        .toList(); // Ajout du .toList() pour la performance

    // 2. On récupère les jobs correspondants
    final appliedJobs = jobProvider.jobs
        .where((job) => applications.any((app) => app.jobId == job.id))
        .toList();
    if (appliedJobs.isNotEmpty && appliedJobs[0].id == "-1") {
      appliedJobs.removeAt(0);
    }

    if (appliedJobs.isNotEmpty) {
      appliedJobs.sort((a, b) {
        final appA = applications.firstWhere((app) => app.jobId == a.id);
        final appB = applications.firstWhere((app) => app.jobId == b.id);
        return appB.createdAt!.compareTo(appA.createdAt!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('My applications'),
        centerTitle: true,
        actions: const [ProfileButton()],
      ),

      body: applicationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appliedJobs.isEmpty
          ? const Center(child: Text('You have not applied to any job yet'))
          : Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: appliedJobs.length,
                    itemBuilder: (context, index) {
                      final job = appliedJobs[index];

                      final application = applications.firstWhere(
                        (app) => app.jobId == job.id,
                      );

                      return JobApplicationStudentItem(
                        job: job,
                        application: application,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
