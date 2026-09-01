import 'package:flutter/material.dart';
import 'package:vagoflax/models/enum/status.dart';

class StatusPill extends StatelessWidget {
  final Status status;
  final IconData? icon;
  const StatusPill({super.key, required this.status, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 12, color: _getStatusColor(status)),
            const SizedBox(width: 4),
          ],
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getStatusColor(status),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Color _getStatusColor(Status status) {
  switch (status) {
    case Status.reviewing:
      return Colors.orange;
    case Status.accepted:
      return Colors.green;
    case Status.rejected:
      return Colors.red;
    case Status.submitted:
      return Colors.blueAccent;
  }
}
