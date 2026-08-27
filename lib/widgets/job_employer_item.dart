import 'package:flutter/material.dart';

import '../models/job_model.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../providers/job_provider.dart';

class JobEmployerItem extends StatelessWidget {
  final Job job;

  const JobEmployerItem({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(job.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.person_search),
              tooltip: 'View Applications',
              onPressed: () {
                context.push('/job-applications', extra: job);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/add-job', extra: job);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                final jobProvider = Provider.of<JobProvider>(
                  context,
                  listen: false,
                );
                jobProvider.deleteJob(job);
              },
            ),
          ],
        ),
        onTap: () => context.push('/job-details', extra: job),
      ),
    );
  }
}
