import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/translation.dart';
import 'package:vagoflax/models/enum/languages.dart';

void main() {
  final mapTranslation = {
    'title': 'Flutter Developer',
    'description': 'A great opportunity',
    'language': 'french',
  };

  test('from includes title', () {
    expect(JobTranslation.from(mapTranslation).title, 'Flutter Developer');
  });

  test('from includes description', () {
    expect(
      JobTranslation.from(mapTranslation).description,
      'A great opportunity',
    );
  });

  test('from includes language', () {
    expect(JobTranslation.from(mapTranslation).language, Languages.french);
  });

  test('from defaults title to empty string when missing', () {
    expect(JobTranslation.from({}).title, '');
  });

  test('from defaults description to empty string when missing', () {
    expect(JobTranslation.from({}).description, '');
  });

  test('from falls back to english for unknown language', () {
    expect(
      JobTranslation.from({'language': 'klingon'}).language,
      Languages.english,
    );
  });

  test('from falls back to english when language is missing', () {
    expect(JobTranslation.from({}).language, Languages.english);
  });
}
