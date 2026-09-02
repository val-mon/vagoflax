import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/translation.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/models/enum/diplomas.dart';

import '../fakes/job.dart';

Job _job(String id) => Job(
  id: id,
  userUuid: 'owner',
  title: 'T$id',
  description: '',
  diploma: Diplomas.bachelor,
  role: Role.intern,
  industry: Industry.informationTechnology,
  perks: const [],
  languages: const [],
  visible: true,
  translations: const [],
);

void main() {
  late FakeJobRepository repository;
  late JobProvider provider;

  setUp(() {
    repository = FakeJobRepository();
    provider = JobProvider(repository);
  });

  tearDown(() {
    provider.dispose();
    repository.dispose();
  });

  test('is loading before the first emission', () {
    expect(provider.isLoading, isTrue);
    expect(provider.jobs, isEmpty);
  });

  test('reflects jobs emitted by the repository', () async {
    repository.emit([_job('1'), _job('2')]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.jobs.map((j) => j.id), ['1', '2']);
    expect(provider.isLoading, isFalse);
  });

  test('addJob forwards the job to the repository', () async {
    await provider.addJob(_job('new'));
    expect(repository.added?.id, 'new');
  });

  test('updateJob forwards the job to the repository', () async {
    await provider.updateJob(_job('e'));
    expect(repository.updated?.id, 'e');
  });

  test('deleteJob forwards the job to the repository', () async {
    await provider.deleteJob(_job('d'));
    expect(repository.deleted?.id, 'd');
  });

  test('applyToJob forwards jobId and userId', () async {
    await provider.applyToJob('job1', 'user1');
    expect(repository.appliedJobId, 'job1');
    expect(repository.appliedUserId, 'user1');
  });

  test('addTranslation forwards jobId and translation', () async {
    final translation = JobTranslation(
      title: 'Titre',
      description: 'Desc',
      language: Languages.french,
    );

    await provider.addTranslation('job1', translation);

    expect(repository.translatedJobId, 'job1');
    expect(repository.addedTranslation?.title, 'Titre');
  });
}
