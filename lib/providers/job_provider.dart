import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vagoflax/models/translation_model.dart';

import '../models/job_model.dart';
import '../repositories/job_repository.dart';

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

  // Subscribe to the job stream from the repository to get real-time updates and notify listeners when the job list changes.
  void _subscribeToJobs() {
    // Notify listeners that the job list is loading before starting the subscription.
    _isLoading = true;
    notifyListeners();

    // Subscribe to the job stream from the repository and update the job list when new data is received.
    _jobsSubscription = _jobRepository.getJobs().listen(
      (jobs) {
        _jobs = jobs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
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
