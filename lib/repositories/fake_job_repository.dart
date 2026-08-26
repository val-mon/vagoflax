import '../models/job_model.dart';
import '../models/enum/diplomas_model.dart';
import '../models/enum/role_model.dart';
import '../models/enum/perks_model.dart';
import '../models/enum/languages_model.dart';
import '../models/enum/industry_model.dart';
import 'job_repository.dart';

class FakeJobRepository implements JobRepository {
  var fakeJobs = [
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
      holidays: 30,
      maternityLeave: 20,
      paternityLeave: 6,
      workloadPercent: 100,
      salary: 120000,
      predictedSalary: 118000,
    ),
  ];

  @override
  Stream<List<Job>> getJobs() {
    return Stream.value(fakeJobs);
  }

  @override
  Future<void> addJob(Job job, String userUuid) {
    fakeJobs.add(job);
    return Future.value();
  }
}
