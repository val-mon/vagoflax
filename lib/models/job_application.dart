import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:vagoflax/models/enum/status.dart';

class JobApplication {
  final String? id;
  final String studentUuid;
  final String jobId;
  Status status;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  JobApplication({
    required this.id,
    required this.studentUuid,
    required this.jobId,
    required this.status,
    this.createdAt,
    this.lastUpdatedAt,
  });

  factory JobApplication.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return JobApplication(
      id: documentId,
      studentUuid: data['studentUuid'] ?? '',
      jobId: data['jobId'] ?? '',
      status: Status.values.byName(data['status'] ?? 'submitted'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
