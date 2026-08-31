import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job_application_model.dart';
import '../providers/application_provider.dart';

class ApplicationStatusDialog extends StatelessWidget {
  final JobApplication application;

  const ApplicationStatusDialog({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Update Application Status',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusOptionTile(
            application: application,
            title: 'Submitted',
            newStatus: 'submitted',
            icon: Icons.mail,
            color: Colors.blueAccent,
          ),
          _StatusOptionTile(
            application: application,
            title: 'Evaluated',
            newStatus: 'evaluated',
            icon: Icons.hourglass_empty,
            color: Colors.orange,
          ),
          const Divider(height: 1),
          _StatusOptionTile(
            application: application,
            title: 'Accept',
            newStatus: 'accepted',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          const Divider(height: 1),
          _StatusOptionTile(
            application: application,
            title: 'Reject',
            newStatus: 'rejected',
            icon: Icons.cancel_outlined,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

/// Sous-widget privé pour gérer chaque ligne (évite de répéter du code)
class _StatusOptionTile extends StatelessWidget {
  final JobApplication application;
  final String title;
  final String newStatus;
  final IconData icon;
  final Color color;

  const _StatusOptionTile({
    required this.application,
    required this.title,
    required this.newStatus,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentStatus =
        application.status.name.toLowerCase() == newStatus;

    return ListTile(
      leading: Icon(icon, color: isCurrentStatus ? color : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
          color: isCurrentStatus ? color : Colors.black87,
        ),
      ),
      trailing: isCurrentStatus
          ? Icon(Icons.check, color: color, size: 20)
          : null,
      onTap: isCurrentStatus
          ? null
          : () async {
              Navigator.pop(context);

              try {
                if (newStatus == 'accepted') {
                  // Show a dialog to inform the employer that the job is now hidden
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Job Hidden'),
                      content: const Text(
                        'The job has been hidden from the job board since you accepted a candidate. You can make it visible again in the job\'s settings.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                await context
                    .read<ApplicationProvider>()
                    .changeApplicationStatus(
                      application.jobId,
                      application.studentUuid,
                      newStatus,
                    );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status updated to $title'),
                    backgroundColor: Colors.grey.shade800,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update status')),
                );
              }
            },
    );
  }
}
