import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/connection.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/translation.dart';
import 'package:vagoflax/providers/application.dart';
import 'package:vagoflax/services/ollama.dart';
import 'package:vagoflax/services/transport.dart';
import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/providers/user.dart';

import 'package:go_router/go_router.dart';

/// Page displaying the details of a job.
class JobDetails extends StatefulWidget {
  final Job? job;

  const JobDetails({super.key, this.job});

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  bool translated = false;
  JobTranslation translationState = JobTranslation(
    title: '',
    description: '',
    language: null,
  );

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          title: const Row(
            children: [
              Icon(Icons.translate, size: 22),
              SizedBox(width: 10),
              Text('Choose Language'),
            ],
          ),
          children: [null, ...Languages.values].map((lang) {
            final isSelected = translationState.language == lang;
            final label = lang == null ? 'ORIGINAL' : lang.name.toUpperCase();

            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                _onLanguageSelected(lang);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.blueAccent : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _onLanguageSelected(Languages? lang) async {
    if (translationState.language == lang && translated) return;
    final jobProvider = context.read<JobProvider>();

    Job currentJob = widget.job!;
    try {
      currentJob = jobProvider.jobs.firstWhere((j) => j.id == widget.job!.id);
    } catch (_) {
      currentJob = widget.job!;
    }
    if (currentJob.id == null) return;

    if (lang == null) {
      setState(() {
        translated = false;
        translationState = JobTranslation(
          title: currentJob.title,
          description: currentJob.description ?? 'No description available',
          language: null,
        );
      });
      return;
    }

    try {
      final cached = currentJob.findTranslationByLanguage(lang);
      setState(() {
        translationState = cached;
        translated = true;
      });
      return;
    } catch (_) {
      // Non trouvé, on passe à la génération
    }

    // AI translation
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(content: Text('Generating translation for ${lang.name}...')),
    );

    try {
      final result = await OllamaService.translate(
        JobTranslation(
          title: currentJob.title,
          description: currentJob.description ?? 'No description available',
          language: lang,
        ),
      );

      await jobProvider.addTranslation(currentJob.id!, result);

      if (!mounted) return;
      setState(() {
        translationState = result;
        translated = true;
      });

      messenger.showSnackBar(
        const SnackBar(content: Text('Translation complete!')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Error translating. Please try again later. If the issue persists, contact your administrator.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.job == null) {
      return const Scaffold(body: Center(child: Text('Job not found')));
    }

    final userProvider = context.watch<UserProvider>();
    final jobProvider = context.watch<JobProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();

    final currentUserId = userProvider.currentUser?.id ?? '';
    final isStudent = userProvider.currentUser?.role == UserRole.student;

    // Get the updated job from the provider.
    Job currentJob = widget.job!;

    try {
      currentJob = jobProvider.jobs.firstWhere(
        (item) => item.id == widget.job!.id,
      );
    } catch (_) {
      currentJob = widget.job!;
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
          'Job information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Options',
            onSelected: (value) {
              if (value == 'translate') {
                _showLanguageSelectionDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'translate',
                child: Row(
                  children: [
                    Icon(Icons.translate_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Translate job details'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                GestureDetector(
                  onTap: () {
                    if (company == null) {
                      return;
                    }

                    context.push("/profile/${company.id}");
                  },
                  child: _CompanyImage(imageUrl: company?.profilePictureUrl),
                ),

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

            if (!currentJob.visible) ...[
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade400, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_off_rounded,
                      color: Colors.amber.shade900,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This job offer is not visible to students',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'It does not appear in the search results for candidates. ${userProvider.currentUser!.role == UserRole.employer ? 'You can change this in the job\'s settings.' : 'You can only see this offer because you applied.'}',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),

            /// JOB TITLE
            Text(
              !translated ? currentJob.title : translationState.title,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),

            if (translated) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.translate, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text.rich(
                    TextSpan(
                      text: 'Translated automatically • ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                translated = false;
                                translationState = JobTranslation(
                                  title: currentJob.title,
                                  description:
                                      currentJob.description ??
                                      'No description available',
                                  language: null,
                                );
                              });
                            },
                            child: Text(
                              'View original',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ] else ...[
              const SizedBox(height: 15),
            ],

            /// DESCRIPTION
            _SectionTitle(title: 'Description'),

            const SizedBox(height: 10),

            Text(
              !translated
                  ? currentJob.description == ''
                        ? 'No description available'
                        : currentJob.description!
                  : translationState.description,
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
              value: '${currentJob.workloadPercent ?? 'N/A'}%',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.description_outlined,
              title: 'Contract',
              value: _contractTime(currentJob.contractTime?.toInt() ?? 0),
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.timeline_outlined,
              title: 'Required experience',
              value:
                  currentJob.minYearsExperience != null &&
                      currentJob.maxYearsExperience != null
                  ? '${currentJob.minYearsExperience}–${currentJob.maxYearsExperience} years'
                  : 'Not specified',
            ),

            // Posted time
            if (currentJob.createdAt == null)
              const SizedBox.shrink()
            else
              Column(
                children: [
                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    title: 'Posted',
                    value:
                        '${currentJob.createdAt!.day.toString().padLeft(2, '0')}/${currentJob.createdAt!.month.toString().padLeft(2, '0')}/${currentJob.createdAt!.year}',
                  ),
                ],
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
              value: '${currentJob.holidays ?? 'N/A'} days / year',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.child_friendly_outlined,
              title: 'Maternity leave',
              value: '${currentJob.maternityLeave ?? 'N/A'} weeks',
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.family_restroom_outlined,
              title: 'Paternity leave',
              value: '${currentJob.paternityLeave ?? 'N/A'} weeks',
            ),

            const SizedBox(height: 35),

            /// TRANSPORT
            const _SectionTitle(title: 'Transport'),

            const SizedBox(height: 14),

            FutureBuilder<List<Connection>>(
              future: TransportService.getConnections(
                userProvider.currentUser?.address ?? '',
                company?.address ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final connections = snapshot.data ?? [];
                if (connections.isEmpty) {
                  return const Text(
                    'No transport option found',
                    style: TextStyle(fontSize: 15),
                  );
                }

                return Column(
                  children: connections.map((c) {
                    return ListTile(
                      leading: const Icon(Icons.train_outlined),
                      title: Text('${_hm(c.departure)} → ${_hm(c.arrival)}'),
                      subtitle: Text(
                        '${c.products.join(' • ')} | ${userProvider.currentUser?.address} → ${company?.address}',
                      ),
                    );
                  }).toList(),
                );
              },
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
              future: applicationProvider.hasApplied(
                currentJob.id!,
                currentUserId,
              ),
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

    return company.companyName ?? 'Company';
  }

  static String _location(User? company) {
    if (company == null) {
      return 'Location not specified';
    }

    final city = company.address.trim();
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

  static String _hm(DateTime? dt) {
    if (dt == null) return '--:--';
    final t = dt.toLocal();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
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
