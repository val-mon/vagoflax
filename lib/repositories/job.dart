import 'package:vagoflax/models/translation.dart';
import 'package:vagoflax/models/job.dart';

abstract class JobRepository {
  Stream<List<Job>> getJobs();
  Future<void> addJob(Job job);
  Future<void> updateJob(Job job);
  Future<void> deleteJob(Job job);
  Future<void> applyToJob(String jobId, String userId);
  Future<void> addTranslation(String jobId, JobTranslation translation);
}
