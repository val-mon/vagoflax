import 'package:vagoflax/models/job_application_model.dart';

abstract class ApplicationRepository {
  Stream<List<JobApplication>> getApplications();
  Future<List<JobApplication>> getApplicationsForJob(String jobId);
  Future<void> applyToJob(String jobId, String studentUuid);
  Future<void> changeApplicationStatus(
    String jobId,
    String studentUuid,
    String newStatus,
  );
  Future<bool> hasApplied(String jobId, String studentUuid);
}
