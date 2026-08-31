import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/widgets/application_status_dialog.dart';
import 'package:vagoflax/widgets/status_pill.dart';

import 'package:vagoflax/providers/application.dart';
import 'package:vagoflax/providers/user.dart';

class JobApplicationsScreen extends StatelessWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    final applicationProvider = context.watch<ApplicationProvider>();
    final users = context.watch<UserProvider>().users;

    // Filtering
    final jobApplications = applicationProvider.applications
        .where((app) => app.jobId == jobId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Candidates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              jobTitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: applicationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobApplications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobApplications.length,
              itemBuilder: (context, index) {
                final application = jobApplications[index];

                final student = users.firstWhere(
                  (u) => u.id == application.studentUuid,
                  orElse: () => User(
                    id: "-1",
                    email: '',
                    role: UserRole.student,
                    profilePictureUrl: '',
                    createdAt: DateTime.now(),
                    canton: "",
                    city: "",
                    description: "",
                    faceRecognitionUrl: "",
                  ),
                );

                if (student.id == "-1") {
                  return const Text("Error displaying student information");
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: student.hasProfilePicture
                          ? NetworkImage(student.profilePictureUrl!)
                          : null,
                      child: !student.hasProfilePicture
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      '${student.firstName} ${student.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusPill(status: application.status),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_search),
                          tooltip: 'View Profile',
                          onPressed: () {
                            context.push('/profile', extra: student);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: "Change Application Status",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ApplicationStatusDialog(
                                application: application,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No applications yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
