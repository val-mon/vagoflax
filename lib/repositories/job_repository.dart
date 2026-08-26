import '../models/job_model.dart';

abstract class JobRepository {
  Stream<List<Job>> getJobs();
  Future<void> addJob(Job job, String userUuid);
}
