import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: true);
    final jobs = jobProvider.jobs;
    final isLoading = jobProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagoflax'),
        centerTitle: true,   // ← centre le titre horizontalement
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
          ? const Center(child: Text('No jobs available'))
          : ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return JobItem(
            job: job,
          );
        },
      ),
    );
  }
}