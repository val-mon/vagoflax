import 'dart:async';

import 'package:vagoflax/models/job_application.dart';
import 'package:vagoflax/repositories/application.dart';

class FakeApplicationRepository implements ApplicationRepository {
  final _controller = StreamController<List<JobApplication>>.broadcast();

  String? appliedJobId;
  String? appliedStudentUuid;
  String? statusJobId;
  String? statusStudentUuid;
  String? newStatus;
  String? deletedJobId;

  bool hasAppliedResponse = false;

  void emit(List<JobApplication> applications) => _controller.add(applications);
  void emitError(Object error) => _controller.addError(error);

  @override
  Stream<List<JobApplication>> getApplications() => _controller.stream;

  @override
  Future<void> applyToJob(String jobId, String studentUuid) async {
    appliedJobId = jobId;
    appliedStudentUuid = studentUuid;
  }

  @override
  Future<void> changeApplicationStatus(
    String jobId,
    String studentUuid,
    String newStatus,
  ) async {
    statusJobId = jobId;
    statusStudentUuid = studentUuid;
    this.newStatus = newStatus;
  }

  @override
  Future<bool> hasApplied(String jobId, String studentUuid) async =>
      hasAppliedResponse;

  @override
  Future<void> deleteAllApplicationsForJob(String jobId) async =>
      deletedJobId = jobId;

  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);

  void dispose() => _controller.close();
}
