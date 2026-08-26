import 'package:cloud_firestore/cloud_firestore.dart';
import 'enum/status_model.dart';

class JobApplication {
  final String studentUuid;
  final Status status;
  final DateTime? date;

  JobApplication({
    required this.studentUuid,
    required this.status,
    this.date,
  });

  factory JobApplication.fromMap(Map<String, dynamic> data) {
    return JobApplication(
      studentUuid: data['student_uuid'] ?? '',
      status: data['status'] ?? 'submitted',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }
}