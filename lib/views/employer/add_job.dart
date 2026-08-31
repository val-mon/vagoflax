import 'package:flutter/material.dart';
import 'package:vagoflax/widgets/job/form.dart';
import 'package:vagoflax/models/job.dart';

class AddJobScreen extends StatelessWidget {
  final Job? job;
  const AddJobScreen({super.key, this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Job')),
      body: JobForm(job: job),
    );
  }
}
