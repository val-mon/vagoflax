import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/utils/date.dart';
import 'package:vagoflax/widgets/application_status_dialog.dart';
import 'package:vagoflax/widgets/search_filter.dart';
import 'package:vagoflax/widgets/status_pill.dart';

import 'package:vagoflax/providers/application.dart';
import 'package:vagoflax/providers/user.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });
  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final applicationProvider = context.watch<ApplicationProvider>();
    final users = context.watch<UserProvider>().users;

    final jobApplications = applicationProvider.applications
        .where((app) => app.jobId == widget.jobId)
        .toList();

    // sort job applications by student applier name
    if (users.isNotEmpty && jobApplications.isNotEmpty) {
      jobApplications.sort((a, b) {
        final studentA = users.firstWhere(
          (u) => u.id == a.studentUuid,
          orElse: () => User(
            id: "-1",
            email: '',
            role: UserRole.student,
            createdAt: DateTime.now(),
            canton: "",
            address: "",
            description: "",
            profilePictureUrl: null,
          ),
        );
        final studentB = users.firstWhere(
          (u) => u.id == b.studentUuid,
          orElse: () => User(
            id: "-1",
            email: '',
            role: UserRole.student,
            createdAt: DateTime.now(),
            canton: "",
            address: "",
            description: "",
            profilePictureUrl: null,
          ),
        );
        return (studentA.firstName ?? '').compareTo(studentB.firstName ?? '');
      });
    }

    final filteredApps = jobApplications.where((app) {
      if (_searchQuery.trim().isEmpty) return true;
      final user = users.firstWhere(
        (u) => u.id == app.studentUuid,
        orElse: () => User(
          id: "-1",
          email: '',
          role: UserRole.student,
          createdAt: DateTime.now(),
          canton: "",
          address: "",
          description: "",
          profilePictureUrl: null,
        ),
      );
      if (user.id == "-1") return false;

      final query = _searchQuery.toLowerCase();
      final name =
          '${user.firstName ?? ''} ${(user.lastName ?? '').toLowerCase()}';
      final email = user.email.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Candidates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.jobTitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchFilter(
            onSearch: (value) => setState(() => _searchQuery = value),
            onFilterTap: () {},
            filters: false,
            text: "Search candidates",
          ),
          Expanded(
            child: applicationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredApps.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final application = filteredApps[index];

                final student = users.firstWhere(
                  (u) => u.id == application.studentUuid,
                  orElse: () => User(
                    id: "-1",
                    email: '',
                    role: UserRole.student,
                    createdAt: DateTime.now(),
                    canton: "",
                    address: "",
                    description: "",
                    profilePictureUrl: null,
                  ),
                );

                      final hasProfilePicture =
                          student.profilePictureUrl != null &&
                          student.profilePictureUrl!.isNotEmpty;

                      if (student.id == "-1") {
                        return const Text(
                          "Error displaying student information",
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          onTap: () {
                            context.push(
                              '/profile/${student.id}',
                              extra: student,
                            );
                          },
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: hasProfilePicture
                                ? NetworkImage(student.profilePictureUrl!)
                                : null,
                            child: !hasProfilePicture
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          title: Text(
                            '${student.firstName ?? ''} ${student.lastName ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? (student.companyName ?? 'Candidate')
                                : '${student.firstName} ${student.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // application date
                              Text(
                                application.createdAt != null
                                    ? "Applied on ${DateFormat.formatDate(application.createdAt!)}"
                                    : 'No application date available',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ApplicationStatusDialog(
                                              application: application,
                                            ),
                                      );
                                    },
                                    child: StatusPill(
                                      status: application.status,
                                      icon: Icons.edit,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
