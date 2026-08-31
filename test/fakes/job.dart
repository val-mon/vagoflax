import 'dart:async';

import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/translation.dart';
import 'package:vagoflax/repositories/job.dart';

class FakeJobRepository implements JobRepository {
  final _controller = StreamController<List<Job>>.broadcast();

  Job? added;
  Job? updated;
  Job? deleted;
  String? appliedJobId;
  String? appliedUserId;
  String? translatedJobId;
  JobTranslation? addedTranslation;

  void emit(List<Job> jobs) => _controller.add(jobs);

  @override
  Stream<List<Job>> getJobs() => _controller.stream;

  @override
  Future<void> addJob(Job job) async => added = job;

  @override
  Future<void> updateJob(Job job) async => updated = job;

  @override
  Future<void> deleteJob(Job job) async => deleted = job;

  @override
  Future<void> applyToJob(String jobId, String userId) async {
    appliedJobId = jobId;
    appliedUserId = userId;
  }

  @override
  Future<void> addTranslation(String jobId, JobTranslation translation) async {
    translatedJobId = jobId;
    addedTranslation = translation;
  }

  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);

  void dispose() => _controller.close();
}
