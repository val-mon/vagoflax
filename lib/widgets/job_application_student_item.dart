import 'package:flutter/material.dart';
import 'package:vagoflax/models/job_application_model.dart';
import 'package:vagoflax/widgets/status_pill.dart';

import '../models/job_model.dart';

import 'package:go_router/go_router.dart';

class JobApplicationStudentItem extends StatelessWidget {
  final Job job;
  final JobApplication application;

  const JobApplicationStudentItem({
    super.key,
    required this.job,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(
          job.description == '' ? 'No description available' : job.description!,
        ),
        onTap: () {
          context.push('/job-details', extra: job);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusPill(status: application.status),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
