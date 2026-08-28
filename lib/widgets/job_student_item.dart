import 'package:flutter/material.dart';

import '../models/job_model.dart';

import 'package:go_router/go_router.dart';

class JobStudentItem extends StatelessWidget {
  final Job job;

  const JobStudentItem({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(job.description),
        onTap: () {
          context.push('/job-details', extra: job);
        },
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
