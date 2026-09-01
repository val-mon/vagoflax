import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/enum/diplomas.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/perks.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/salary_prediction_model.dart';
import 'package:vagoflax/models/user.dart';

void main() {
  final job = Job(
    title: 'Developer',
    diplomas: const [Diplomas.bachelor, Diplomas.master],
    minYearsExperience: 2,
    maxYearsExperience: 5,
    contractTime: 0,
    role: Role.midLevel,
    industry: Industry.informationTechnology,
    perks: const [Perks.housingSupport],
    languages: const [Languages.english, Languages.french],
    holidays: 25,
    workloadPercent: 80,
    visible: true,
    translations: const [],
  );

  User employerWithSize(int size) => User(
    id: 'employer',
    canton: 'vd',
    city: 'Lausanne',
    description: '',
    email: 'company@example.com',
    role: UserRole.employer,
    companySize: size,
  );

  test('maps Job and employer data to the Python vocabulary', () {
    final input = SalaryPredictionInput.fromJobAndEmployer(
      job: job,
      employer: employerWithSize(250),
    );

    expect(input.minYearsExperience, 2.0);
    expect(input.maxYearsExperience, 5.0);
    expect(input.contractMonths, 0.0);
    expect(input.isPermanent, isTrue);
    expect(input.diplomas, ['Bachelor', 'Master']);
    expect(input.role, 'Mid-level');
    expect(input.industry, 'IT');
    expect(input.canton, 'VD');
    expect(input.companySize, 'Medium (200-1000)');
    expect(input.perks, ['Housing support']);
    expect(input.languages, ['English', 'French']);
  });

  test('maps company-size boundaries to the training categories', () {
    String category(int size) => SalaryPredictionInput.fromJobAndEmployer(
      job: job,
      employer: employerWithSize(size),
    ).companySize;

    expect(category(49), 'Startup (<50)');
    expect(category(50), 'Small (50-200)');
    expect(category(200), 'Medium (200-1000)');
    expect(category(1000), 'Large (1000+)');
  });
}
