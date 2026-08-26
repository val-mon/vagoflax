import 'package:flutter/material.dart';
import '../widgets/job_form.dart';

class AddJobScreen extends StatelessWidget {
  const AddJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Job')),
      body: JobForm(),
    );
  }

}