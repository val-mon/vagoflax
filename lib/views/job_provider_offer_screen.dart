import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/job_provider.dart';
import '../widgets/job_item.dart';
import 'add_job_screen.dart';

class JobProviderOfferScreen extends StatelessWidget {
  const JobProviderOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: true);
    final jobs = jobProvider.jobs;
    final isLoading = jobProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('My offers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : jobs.isEmpty
                ? const Center(child: Text('No jobs available'))
                : ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return JobItem(job: job);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
