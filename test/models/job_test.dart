import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/translation.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/diplomas.dart';
void main() {
  final createdAt = DateTime(2026, 8, 30, 14, 24, 30);

  final job = Job(
    id: '1',
    userUuid: '1',
    title: 'title',
    description: 'description',
    diploma:  Diplomas.bachelor,
    minYearsExperience: 2,
    maxYearsExperience: 5,
    contractTime: 13,
    role: Role.intern,
    industry: Industry.informationTechnology,
    perks: const [],
    languages: const [Languages.english],
    holidays: 20,
    maternityLeave: 14,
    paternityLeave: 2,
    workloadPercent: 100,
    salary: null,
    predictedSalary: null,
    createdAt: createdAt,
    visible: true,
    translations: [
      JobTranslation(
        title: 'Titre',
        description: 'Une description',
        language: Languages.french,
      ),
    ],
  );

  final mapJob = {
    'userUuid': '1',
    'title': 'title',
    'description': 'description',
    'diploma': 'bachelor',
    'minYearsExperience': 2,
    'maxYearsExperience': 5,
    'contractTime': 13,
    'role': 'intern',
    'industry': 'informationTechnology',
    'perks': <String>[],
    'languages': ['english'],
    'holidays': 20,
    'maternityLeave': 14,
    'paternityLeave': 2,
    'workloadPercent': 100,
    'salary': null,
    'predictedSalary': null,
    'visible': true,
    'translations': [
      {
        'title': 'Titre',
        'description': 'Une description',
        'language': 'french',
      },
    ],
    'createdAt': Timestamp.fromDate(createdAt),
  };

  test('toFirestore includes userUuid', () {
    expect(job.toFirestore()['userUuid'], '1');
  });

  test('toFirestore includes title', () {
    expect(job.toFirestore()['title'], 'title');
  });

  test('toFirestore includes description', () {
    expect(job.toFirestore()['description'], 'description');
  });

  test('toFirestore includes contractTime', () {
    expect(job.toFirestore()['contractTime'], 13);
  });

  test('toFirestore includes experience range', () {
    expect(job.toFirestore()['minYearsExperience'], 2);
    expect(job.toFirestore()['maxYearsExperience'], 5);
  });

  test('toFirestore includes role name', () {
    expect(job.toFirestore()['role'], 'intern');
  });

  test('toFirestore includes industry name', () {
    expect(job.toFirestore()['industry'], 'informationTechnology');
  });

  test('toFirestore includes languages as names', () {
    expect(job.toFirestore()['languages'], ['english']);
  });

  test('toFirestore includes holidays', () {
    expect(job.toFirestore()['holidays'], 20);
  });

  test('toFirestore includes maternityLeave', () {
    expect(job.toFirestore()['maternityLeave'], 14);
  });

  test('toFirestore includes paternityLeave', () {
    expect(job.toFirestore()['paternityLeave'], 2);
  });

  test('toFirestore includes workloadPercent', () {
    expect(job.toFirestore()['workloadPercent'], 100);
  });

  test('toFirestore includes visible', () {
    expect(job.toFirestore()['visible'], true);
  });

  test('toFirestore serializes translations', () {
    final translations = job.toFirestore()['translations'] as List<dynamic>;
    expect(translations.length, 1);
    expect(translations.first['title'], 'Titre');
    expect(translations.first['language'], 'french');
  });

  test('fromFirestore includes id', () {
    expect(Job.fromFirestore(mapJob, '1').id, '1');
  });

  test('fromFirestore includes userUuid', () {
    expect(Job.fromFirestore(mapJob, '1').userUuid, '1');
  });

  test('fromFirestore includes title', () {
    expect(Job.fromFirestore(mapJob, '1').title, 'title');
  });

  test('fromFirestore includes description', () {
    expect(Job.fromFirestore(mapJob, '1').description, 'description');
  });

  test('fromFirestore includes contractTime', () {
    expect(Job.fromFirestore(mapJob, '1').contractTime, 13);
  });

  test('fromFirestore includes experience range', () {
    final parsed = Job.fromFirestore(mapJob, '1');
    expect(parsed.minYearsExperience, 2);
    expect(parsed.maxYearsExperience, 5);
  });

  test('fromFirestore parses role', () {
    expect(Job.fromFirestore(mapJob, '1').role, Role.intern);
  });

  test('fromFirestore parses industry', () {
    expect(
      Job.fromFirestore(mapJob, '1').industry,
      Industry.informationTechnology,
    );
  });

  test('fromFirestore parses languages', () {
    expect(Job.fromFirestore(mapJob, '1').languages, [Languages.english]);
  });

  test('fromFirestore includes holidays', () {
    expect(Job.fromFirestore(mapJob, '1').holidays, 20);
  });

  test('fromFirestore defaults visible to true when missing', () {
    final map = Map<String, dynamic>.from(mapJob)..remove('visible');
    expect(Job.fromFirestore(map, '1').visible, true);
  });

  test('fromFirestore parses createdAt', () {
    expect(Job.fromFirestore(mapJob, '1').createdAt, createdAt);
  });

  test('fromFirestore parses translations', () {
    final parsed = Job.fromFirestore(mapJob, '1');
    expect(parsed.translations.length, 1);
    expect(parsed.translations.first.language, Languages.french);
  });

  test('findTranslationByLanguage returns matching translation', () {
    expect(job.findTranslationByLanguage(Languages.french).title, 'Titre');
  });

  test('findTranslationByLanguage throws when not found', () {
    expect(
      () => job.findTranslationByLanguage(Languages.english),
      throwsStateError,
    );
  });
}
