import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vagoflax/models/translation.dart';

import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/repositories/application.dart';
import 'package:vagoflax/repositories/job.dart';

class FirestoreJobRepository implements JobRepository {
  final FirebaseFirestore _db;
  final ApplicationRepository applicationRepository;

  FirestoreJobRepository({
    required this.applicationRepository,
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _jobsRef() =>
      _db.collection('jobs');

  @override
  Stream<List<Job>> getJobs() {
    return _jobsRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Job.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> addJob(Job job) {
    return _jobsRef().add({
      ...job.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateJob(Job job) async {
    if (job.id == null) {
      throw Exception('Job ID is null');
    }

    await _jobsRef().doc(job.id).update(job.toFirestore());
  }

  @override
  Future<void> deleteJob(Job job) async {
    if (job.id == null) {
      throw Exception('Job ID is null');
    }

    await _jobsRef().doc(job.id).delete();

    // when deleting jobs, also delete all applications related to that job
    applicationRepository.deleteAllApplicationsForJob(job.id!);
  }

  @override
  Future<void> applyToJob(String jobId, String userId) async {
    await _jobsRef().doc(jobId).update({
      'applicants': FieldValue.arrayUnion([
        {
          'student_uuid': userId,
          'status': 'submitted',
          'date': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      ]),
    });
  }

  @override
  Future<void> addTranslation(String jobId, JobTranslation translation) async {
    await _jobsRef().doc(jobId).update({
      'translations': FieldValue.arrayUnion([
        {
          'title': translation.title,
          'description': translation.description,
          'language': translation.language?.name,
        },
      ]),
    });
  }
}
