import 'package:flutter/material.dart';

import '../models/job_model.dart';

class JobItem extends StatelessWidget {
  final Job job;

  const JobItem({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(job.description),
      ),
    );
  }
}
