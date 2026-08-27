import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vagoflax/models/enum/status_model.dart';

class StatusPill extends StatelessWidget {
  final Status status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status)
            .withValues(
              alpha: 0.1
            ),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getStatusColor(
            status,
          ),
          fontSize: 12,
        ),
      ),
    );
  }
}

Color _getStatusColor(Status status) {
  switch (status) {
    case Status.evaluated:
      return Colors.orange;
    case Status.accepted:
      return Colors.green;
    case Status.rejected:
      return Colors.red;
    case Status.submitted:
      return Colors.blueAccent;
  }
}
