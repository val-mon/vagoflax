import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vagoflax/models/job_application.dart';
import 'package:vagoflax/repositories/application.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository _repository;
  StreamSubscription? _subscription;

  List<JobApplication> _applications = [];
  List<JobApplication> get applications => _applications;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ApplicationProvider(this._repository) {
    _listenToApplications();
  }

  void _listenToApplications() {
    _subscription = _repository.getApplications().listen(
      (applicationsList) {
        _applications = applicationsList;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> applyToJob(String jobId, String studentUuid) async {
    try {
      await _repository.applyToJob(jobId, studentUuid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeApplicationStatus(
    String jobId,
    String studentUuid,
    String newStatus,
  ) async {
    try {
      await _repository.changeApplicationStatus(jobId, studentUuid, newStatus);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasApplied(String jobId, String studentUuid) async {
    try {
      return await _repository.hasApplied(jobId, studentUuid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllApplicationsForJob(String jobId) async {
    try {
      await _repository.deleteAllApplicationsForJob(jobId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
