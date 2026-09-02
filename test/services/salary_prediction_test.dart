import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/salary_prediction_model.dart';
import 'package:vagoflax/services/salary_preprocessor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds the feature vector from preprocessing metadata', () async {
    final preprocessor = SalaryPreprocessor();
    await preprocessor.initialize();

    final values = preprocessor.transform(
      const SalaryPredictionInput(
        minYearsExperience: 2,
        contract: 0,
        isPermanent: true,
        holidays: 25,
        workloadPercent: 80,
        diploma: 'Bachelor',
        role: 'Mid-level',
        industry: 'IT',
        canton: 'VD',
        companySize: 'Medium',
        perks: ['Housing support'],
        languages: ['English', 'French'],
      ),
    );

    expect(values, hasLength(preprocessor.inputDimension));
    expect(values[preprocessor.featureNames.indexOf('Diploma_Bachelor')], 1.0);
    expect(values[preprocessor.featureNames.indexOf('Role_Mid-level')], 1.0);
    expect(values[preprocessor.featureNames.indexOf('Industry_IT')], 1.0);
    expect(values[preprocessor.featureNames.indexOf('Canton_VD')], 1.0);
    expect(
      values[preprocessor.featureNames.indexOf('CompanySize_Medium')],
      1.0,
    );
    expect(
      values[preprocessor.featureNames.indexOf('Perks_Housing support')],
      1.0,
    );
    expect(values[preprocessor.featureNames.indexOf('Languages_English')], 1.0);
    expect(values[preprocessor.featureNames.indexOf('Languages_French')], 1.0);
  });
}
