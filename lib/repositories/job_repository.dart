import '../models/job_model.dart';

abstract class JobRepository {
  Stream<List<Job>> getJobs();
}
