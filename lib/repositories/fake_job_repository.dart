import '../models/job_model.dart';
import '../models/job_application_model.dart';
import '../models/enum/diplomas_model.dart';
import '../models/enum/role_model.dart';
import '../models/enum/perks_model.dart';
import '../models/enum/languages_model.dart';
import '../models/enum/industry_model.dart';
import '../models/enum/status_model.dart';
import 'job_repository.dart';

class FakeJobRepository implements JobRepository {
  @override
  Stream<List<Job>> getJobs() {
    final fakeJobs = [
      Job(
        id: '1',
        userUuid: 'employer-001',
        title: 'Flutter Developer',
        description: 'Développement d\'applications mobiles en Flutter.',
        diplomas: [Diplomas.bachelor],
        contractTime: 0, // CDI
        role: Role.junior,
        industry: Industry.informationTechnology,
        perks: [Perks.mealVouchers, Perks.stockOptions],
        languages: [Languages.english, Languages.french],
        applications: [
          JobApplication(
            studentUuid: 'student-100',
            status: Status.submitted,
            date: DateTime(2026, 8, 10),
          ),
        ],
        holidays: 25,
        maternityLeave: 16,
        paternityLeave: 4,
        workloadPercent: 100,
        salary: 95000,
        predictedSalary: 98000,
      ),
      Job(
        id: '2',
        userUuid: 'employer-002',
        title: 'Data Analyst',
        description: 'Analyse de données et reporting pour l\'équipe finance.',
        diplomas: [Diplomas.bachelor, Diplomas.master],
        contractTime: 2,
        role: Role.junior,
        industry: Industry.finance,
        perks: [Perks.car, Perks.mealVouchers],
        languages: [Languages.english, Languages.german, Languages.french],
        applications: [
          JobApplication(
            studentUuid: 'student-200',
            status: Status.evaluated,
            date: DateTime(2026, 7, 22),
          ),
          JobApplication(
            studentUuid: 'student-201',
            status: Status.rejected,
            date: DateTime(2026, 7, 25),
          ),
        ],
        holidays: 22,
        maternityLeave: 14,
        paternityLeave: 2,
        workloadPercent: 80,
        salary: null, // salaire invisible
        predictedSalary: 82000,
      ),
      Job(
        id: '3',
        userUuid: 'employer-003',
        title: 'Project Manager',
        description: 'Gestion de projets de construction dans le Valais.',
        diplomas: [Diplomas.master],
        contractTime: 0,
        role: Role.senior,
        industry: Industry.construction,
        perks: [Perks.car, Perks.housingSupport, Perks.ag],
        languages: [Languages.german, Languages.french],
        applications: [
          JobApplication(
            studentUuid: 'student-300',
            status: Status.accepted,
            date: DateTime(2026, 6, 15),
          ),
        ],
        holidays: 30,
        maternityLeave: 20,
        paternityLeave: 6,
        workloadPercent: 100,
        salary: 120000,
        predictedSalary: 118000,
      ),
    ];

    return Stream.value(fakeJobs);
  }
}