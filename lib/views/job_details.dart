import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/application_provider.dart';

import '../models/job_model.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';

/// Page displaying the details of a job.
class JobDetails extends StatelessWidget {
  final Job? job;

  const JobDetails({super.key, this.job});

  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return const Scaffold(body: Center(child: Text('Job not found')));
    }

    final appState = context.watch<ApplicationState>();
    final userProvider = context.watch<UserProvider>();
    final jobProvider = context.watch<JobProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();

    final currentUserId = appState.userId;
    final isStudent = appState.userRole == 'student';

    // Get the updated job from the provider.
    Job currentJob = job!;

    try {
      currentJob = jobProvider.jobs.firstWhere((item) => item.id == job!.id);
    } catch (_) {
      currentJob = job!;
    }

    // Get the company that published the job.
    User? company;

    try {
      company = userProvider.users.firstWhere(
        (user) => user.id == currentJob.userUuid,
      );
    } catch (_) {
      company = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Vagoflax',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// COMPANY
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompanyImage(imageUrl: company?.profilePictureUrl),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _companyName(company),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              _location(company),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.business_center_outlined, size: 18),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              _enumName(currentJob.industry.name),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            /// JOB TITLE
            Text(
              currentJob.title,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            /// DESCRIPTION
            const _SectionTitle(title: 'Description'),

            const SizedBox(height: 10),

            Text(
              currentJob.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 35),

            /// SALARY
            const _SectionTitle(title: 'Salary'),

            const SizedBox(height: 14),

            _InfoRow(
              icon: Icons.payments_outlined,
              title: 'Annual salary',
              value: currentJob.salary != null
                  ? '${_formatSalary(currentJob.salary!)} CHF / year'
                  : 'Not specified',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.auto_graph,
              title: 'Predicted salary',
              value: currentJob.predictedSalary != null
                  ? '${_formatSalary(currentJob.predictedSalary!)} CHF / year'
                  : 'Not available',
            ),

            const SizedBox(height: 35),

            /// JOB DETAILS
            const _SectionTitle(title: 'Job details'),

            const SizedBox(height: 14),

            _InfoRow(
              icon: Icons.schedule_outlined,
              title: 'Workload',
              value: '${currentJob.workloadPercent}%',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.description_outlined,
              title: 'Contract',
              value: _contractTime(currentJob.contractTime),
            ),

            const SizedBox(height: 35),

            /// DIPLOMAS
            const _SectionTitle(title: 'Required diplomas'),

            const SizedBox(height: 14),

            if (currentJob.diplomas.isEmpty)
              const Text('No diploma specified', style: TextStyle(fontSize: 16))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentJob.diplomas.map((diploma) {
                  return _InfoChip(
                    icon: Icons.school_outlined,
                    label: _enumName(diploma.name),
                  );
                }).toList(),
              ),

            const SizedBox(height: 35),

            /// LANGUAGES
            const _SectionTitle(title: 'Required languages'),

            const SizedBox(height: 14),

            if (currentJob.languages.isEmpty)
              const Text(
                'No language specified',
                style: TextStyle(fontSize: 16),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentJob.languages.map((language) {
                  return _InfoChip(
                    icon: Icons.language,
                    label: _enumName(language.name),
                  );
                }).toList(),
              ),

            const SizedBox(height: 35),

            /// LEAVE
            const _SectionTitle(title: 'Leave & holidays'),

            const SizedBox(height: 14),

            _InfoRow(
              icon: Icons.beach_access_outlined,
              title: 'Holidays',
              value: '${currentJob.holidays} days / year',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.child_friendly_outlined,
              title: 'Maternity leave',
              value: '${currentJob.maternityLeave} weeks',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.family_restroom_outlined,
              title: 'Paternity leave',
              value: '${currentJob.paternityLeave} weeks',
            ),

            const SizedBox(height: 35),

            /// TRANSPORT
            const _SectionTitle(title: 'Transport'),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.train_outlined, size: 26),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Transport information coming soon',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// APPLY BUTTON
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: FutureBuilder<bool>(
              future: applicationProvider.hasApplied(job!.id!, currentUserId),
              builder: (context, snapshot) {
                // loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                // result
                final alreadyApplied = snapshot.data ?? false;

                return ElevatedButton(
                  onPressed: !isStudent || alreadyApplied
                      ? null
                      : () async {
                          if (currentJob.id == null) {
                            return;
                          }

                          try {
                            await context
                                .read<ApplicationProvider>()
                                .applyToJob(currentJob.id!, currentUserId);

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Application sent!'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Unable to send application'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alreadyApplied
                        ? Colors.grey.shade300
                        : null,
                    foregroundColor: alreadyApplied
                        ? Colors.grey.shade700
                        : null,
                    disabledBackgroundColor: alreadyApplied
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    alreadyApplied
                        ? 'Already applied'
                        : !isStudent
                        ? 'Only students can apply'
                        : 'Apply',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _companyName(User? company) {
    if (company == null) {
      return 'Company';
    }

    return company.name;
  }

  static String _location(User? company) {
    if (company == null) {
      return 'Location not specified';
    }

    final city = company.city.trim();
    final canton = company.canton.trim();

    if (city.isNotEmpty && canton.isNotEmpty) {
      return '$city, $canton';
    }

    if (city.isNotEmpty) {
      return city;
    }

    if (canton.isNotEmpty) {
      return canton;
    }

    return 'Location not specified';
  }

  static String _contractTime(int contractTime) {
    // contract time is months
    if (contractTime == 0) {
      return 'Indefinite';
    }

    final years = contractTime ~/ 12;
    final months = contractTime % 12;

    final yearsText = years > 0 ? '$years year${years > 1 ? 's' : ''}' : '';

    final monthsText = months > 0
        ? '$months month${months > 1 ? 's' : ''}'
        : '';

    if (years > 0 && months > 0) {
      return '$yearsText and $monthsText';
    }

    if (years > 0) {
      return yearsText;
    }

    return monthsText;
  }

  static String _enumName(String value) {
    if (value.isEmpty) {
      return '';
    }

    final text = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return text[0].toUpperCase() + text.substring(1);
  }

  static String _formatSalary(double salary) {
    final value = salary.round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write("'");
      }

      buffer.write(value[i]);
    }

    return buffer.toString();
  }
}

/// Displays the company profile picture.
class _CompanyImage extends StatelessWidget {
  final String? imageUrl;

  const _CompanyImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 110,
      height: 110,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.business, size: 50, color: Colors.grey);
              },
            )
          : const Icon(Icons.business, size: 50, color: Colors.grey),
    );
  }
}

/// Displays a section title with a divider underneath.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Divider(thickness: 1, height: 1),
      ],
    );
  }
}

/// Displays job information with an icon and a value.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Displays a diploma or language as a small chip.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),

          const SizedBox(width: 6),

          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
