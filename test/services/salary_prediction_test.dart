import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/salary_prediction_model.dart';
import 'package:vagoflax/services/salary_prediction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('runs the embedded LiteRT salary model', () async {
    final service = SalaryPredictionService();
    addTearDown(service.dispose);

    final salary = await service.predict(
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

    expect(salary.isFinite, isTrue);
    expect(salary, greaterThan(0));
  });
}
