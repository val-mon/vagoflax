import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/job_application.dart';
import 'package:vagoflax/models/enum/status.dart';
import 'package:vagoflax/providers/application.dart';

import '../fakes/application.dart';

JobApplication _application(String id) => JobApplication(
  id: id,
  studentUuid: 'student',
  jobId: 'job',
  status: Status.submitted,
);

void main() {
  late FakeApplicationRepository repository;
  late ApplicationProvider provider;

  setUp(() {
    repository = FakeApplicationRepository();
    provider = ApplicationProvider(repository);
  });

  tearDown(() {
    provider.dispose();
    repository.dispose();
  });

  test('starts loading', () {
    expect(provider.isLoading, isTrue);
    expect(provider.applications, isEmpty);
  });

  test('reflects applications emitted by the repository', () async {
    repository.emit([_application('1'), _application('2')]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.applications.map((a) => a.id), ['1', '2']);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('sets errorMessage when the stream emits an error', () async {
    repository.emitError('boom');
    await Future<void>.delayed(Duration.zero);

    expect(provider.errorMessage, contains('boom'));
    expect(provider.isLoading, isFalse);
  });

  test('applyToJob forwards jobId and studentUuid', () async {
    await provider.applyToJob('job1', 'student1');

    expect(repository.appliedJobId, 'job1');
    expect(repository.appliedStudentUuid, 'student1');
  });

  test('changeApplicationStatus forwards its arguments', () async {
    await provider.changeApplicationStatus('job1', 'student1', 'accepted');

    expect(repository.statusJobId, 'job1');
    expect(repository.statusStudentUuid, 'student1');
    expect(repository.newStatus, 'accepted');
  });

  test('hasApplied returns the repository response', () async {
    repository.hasAppliedResponse = true;

    final result = await provider.hasApplied('job1', 'student1');

    expect(result, isTrue);
  });

  test('deleteAllApplicationsForJob forwards the jobId', () async {
    await provider.deleteAllApplicationsForJob('job1');

    expect(repository.deletedJobId, 'job1');
  });
}
