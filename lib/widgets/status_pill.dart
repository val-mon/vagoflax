import 'package:flutter/material.dart';
import 'package:vagoflax/models/enum/status_model.dart';

class StatusPill extends StatelessWidget {
  final Status status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // L'espace à l'intérieur de la bulle
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1), // Un fond bleu très clair
        borderRadius: BorderRadius.circular(20), // Les bords très arrondis pour l'effet "pill"
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status), // Le texte de la même couleur que le fond mais bien visible
          fontSize: 12, // Légèrement plus petit pour un badge
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