import 'package:flutter/material.dart';

import '../../widgets/job_form.dart';

import '../../models/job_model.dart';

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
