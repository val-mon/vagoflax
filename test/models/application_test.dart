import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/job_application.dart';
import 'package:vagoflax/models/enum/status.dart';

void main() {
  final createdAt = DateTime(2026, 8, 30, 16, 59, 57);
  final lastUpdatedAt = DateTime(2026, 8, 31, 10, 0, 0);

  final mapApplication = {
    'studentUuid': '1',
    'jobId': '1',
    'status': 'submitted',
    'createdAt': Timestamp.fromDate(createdAt),
    'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
  };

  test('fromFirestore includes id', () {
    expect(JobApplication.fromFirestore(mapApplication, '1').id, '1');
  });

  test('fromFirestore includes studentUuid', () {
    expect(JobApplication.fromFirestore(mapApplication, '1').studentUuid, '1');
  });

  test('fromFirestore includes jobId', () {
    expect(JobApplication.fromFirestore(mapApplication, '1').jobId, '1');
  });

  test('fromFirestore parses status', () {
    expect(
      JobApplication.fromFirestore(mapApplication, '1').status,
      Status.submitted,
    );
  });

  test('fromFirestore parses createdAt', () {
    expect(
      JobApplication.fromFirestore(mapApplication, '1').createdAt,
      createdAt,
    );
  });

  test('fromFirestore parses lastUpdatedAt', () {
    expect(
      JobApplication.fromFirestore(mapApplication, '1').lastUpdatedAt,
      lastUpdatedAt,
    );
  });

  test('fromFirestore defaults studentUuid to empty string when missing', () {
    final map = Map<String, dynamic>.from(mapApplication)
      ..remove('studentUuid');
    expect(JobApplication.fromFirestore(map, '1').studentUuid, '');
  });

  test('fromFirestore defaults jobId to empty string when missing', () {
    final map = Map<String, dynamic>.from(mapApplication)..remove('jobId');
    expect(JobApplication.fromFirestore(map, '1').jobId, '');
  });

  test('fromFirestore defaults status to submitted when missing', () {
    final map = Map<String, dynamic>.from(mapApplication)..remove('status');
    expect(JobApplication.fromFirestore(map, '1').status, Status.submitted);
  });

  test('fromFirestore leaves createdAt null when missing', () {
    final map = Map<String, dynamic>.from(mapApplication)..remove('createdAt');
    expect(JobApplication.fromFirestore(map, '1').createdAt, isNull);
  });

  test('fromFirestore leaves lastUpdatedAt null when missing', () {
    final map = Map<String, dynamic>.from(mapApplication)
      ..remove('lastUpdatedAt');
    expect(JobApplication.fromFirestore(map, '1').lastUpdatedAt, isNull);
  });
}
