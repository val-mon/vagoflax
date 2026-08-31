import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vagoflax/models/translation.dart';

import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/repositories/job.dart';

class JobProvider with ChangeNotifier {
  final JobRepository _jobRepository;
  StreamSubscription<List<Job>>? _jobsSubscription;
  List<Job> _jobs = [];
  bool _isLoading = false;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;

  JobProvider(this._jobRepository) {
    _subscribeToJobs();
  }

  void restart() {
    _jobsSubscription?.cancel();
    _subscribeToJobs();
  }

  // Subscribe to the job stream from the repository to get real-time updates and notify listeners when the job list changes.
  void _subscribeToJobs() {
    _isLoading = true;
    notifyListeners();

    _jobsSubscription = _jobRepository.getJobs().listen(
      (jobs) {
        _jobs = jobs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error, stackTrace) {
        _isLoading = false;
        _jobs = []; 
        notifyListeners();
        debugPrint('ERREUR STREAM JOBS : $error');
        debugPrint('Stacktrace: $stackTrace');
      },
    );
  }

  Future<void> addJob(Job job) async {
    await _jobRepository.addJob(job);
  }

  Future<void> updateJob(Job job) async {
    await _jobRepository.updateJob(job);
  }

  Future<void> deleteJob(Job job) async {
    await _jobRepository.deleteJob(job);
  }

  Future<void> applyToJob(String jobId, String userId) async {
    await _jobRepository.applyToJob(jobId, userId);
  }

  Future<void> addTranslation(String jobId, JobTranslation translation) async {
    await _jobRepository.addTranslation(jobId, translation);
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }
}
