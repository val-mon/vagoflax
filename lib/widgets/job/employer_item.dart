import 'package:flutter/material.dart';

import 'package:vagoflax/models/job.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/utils/date.dart';

class JobEmployerItem extends StatelessWidget {
  final Job job;

  const JobEmployerItem({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(job.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.description == ''
                  ? 'No description available'
                  : job.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.lock_clock, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job.createdAt != null
                      ? DateFormat.formatDate(job.createdAt!)
                      : 'No posting date available',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!job.visible) ...[
              Icon(Icons.visibility_off, color: Colors.grey.shade600),
              const SizedBox(width: 8),
            ],
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
