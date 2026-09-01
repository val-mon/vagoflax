import 'package:flutter/material.dart';

import 'package:vagoflax/models/job.dart';

import 'package:go_router/go_router.dart';
import 'package:vagoflax/utils/date.dart';

class JobStudentItem extends StatelessWidget {
  final Job job;

  const JobStudentItem({super.key, required this.job});

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
        onTap: () {
          context.push('/job-details', extra: job);
        },
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
