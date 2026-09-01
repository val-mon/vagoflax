import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/salary_prediction_model.dart';
import 'package:vagoflax/services/salary_preprocessor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds the 72-feature vector with multiple diplomas', () async {
    final preprocessor = SalaryPreprocessor();
    await preprocessor.initialize();

    final values = preprocessor.transform(
      const SalaryPredictionInput(
        minYearsExperience: 2,
        contractMonths: 0,
        isPermanent: true,
        holidays: 25,
        workloadPercent: 80,
        diplomas: ['Bachelor', 'Master'],
        role: 'Mid-level',
        industry: 'IT',
        canton: 'VD',
        companySize: 'Medium (200-1000)',
        perks: ['Housing support'],
        languages: ['English', 'French'],
      ),
    );

    expect(values, hasLength(72));
    expect(preprocessor.featureNames, isNot(contains('CitySize__Large city')));
    expect(values[preprocessor.featureNames.indexOf('Diploma__Bachelor')], 1.0);
    expect(values[preprocessor.featureNames.indexOf('Diploma__Master')], 1.0);
  });
}
