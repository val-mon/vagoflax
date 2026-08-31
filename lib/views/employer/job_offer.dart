import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/profile_button.dart';

import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/widgets/job/employer_item.dart';

class JobProviderOfferScreen extends StatelessWidget {
  const JobProviderOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final userProvider = context.watch<UserProvider>();
    final jobs = jobProvider.jobs
        .where((job) => job.userUuid == userProvider.currentUser?.id)
        .toList();
    final isLoading = jobProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My offers'),
        actions: [const ProfileButton()],
      ),
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
                      return JobEmployerItem(job: job);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-job');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
