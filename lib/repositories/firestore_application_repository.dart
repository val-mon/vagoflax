import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/job_application_model.dart';
import 'application_repository.dart';

class FirestoreApplicationRepository implements ApplicationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _applicationsRef() =>
      _db.collection('applications');

  @override
  Stream<List<JobApplication>> getApplications() {
    return _applicationsRef().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => JobApplication.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  @override
  Future<void> applyToJob(String jobId, String studentUuid) async {
    // document id for an application is this combination:
    final docId = '${jobId}_$studentUuid';
    // it allows us to easily check if a student has already applied to a job by checking if the document exists

    await _applicationsRef().doc(docId).set({
      'jobId': jobId,
      'studentUuid': studentUuid,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> changeApplicationStatus(
    String jobId,
    String studentUuid,
    String newStatus,
  ) async {
    final docId = '${jobId}_$studentUuid';

    await _applicationsRef().doc(docId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (newStatus == 'accepted') {
      // if status is accepted, we automatically hide the job
      final jobDoc = await _db.collection('jobs').doc(jobId).get();
      if (jobDoc.exists) {
        await _db.collection('jobs').doc(jobId).update({'visible': false});
      }
    }
  }

  @override
  Future<bool> hasApplied(String jobId, String studentUuid) async {
    final docId = '${jobId}_$studentUuid';

    final docSnapshot = await _applicationsRef().doc(docId).get();

    return docSnapshot.exists;
  }
}
