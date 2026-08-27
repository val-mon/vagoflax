import '../models/job_model.dart';

abstract class JobRepository {
  Stream<List<Job>> getJobs();
  Future<void> addJob(Job job);
  Future<void> updateJob(Job job);
  Future<void> deleteJob(Job job);
}
