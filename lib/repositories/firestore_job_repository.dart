import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/job_model.dart';
import 'job_repository.dart';

class FirestoreJobRepository implements JobRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _jobsRef() =>
      _db.collection('jobs');

  @override
  Stream<List<Job>> getJobs() {
    return _jobsRef().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Job.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  @override
  Future<void> addJob(Job job) {
    return _jobsRef().add({...job.toFirestore()});
  }

  @override
  Future<void> updateJob(Job job) async {
    await _jobsRef().doc(job.id).update(job.toFirestore());
  }

  @override
  Future<void> deleteJob(Job job) async {
    await _jobsRef().doc(job.id).delete();
  }
}
