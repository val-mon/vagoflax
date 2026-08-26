import 'job_application_model.dart';
import 'enum/diplomas_model.dart';
import 'enum/role_model.dart';
import 'enum/perks_model.dart';
import 'enum/languages_model.dart';
import 'enum/industry_model.dart';

class Job {
  final String id;
  final String userUuid;
  final String title;
  final String description;
  final List<Diplomas> diplomas;
  final int contractTime;
  final Role role;
  final Industry industry;
  final List<Perks> perks;
  final List<Languages> languages;
  final List<JobApplication> applications;
  final int holidays;
  final int maternityLeave;
  final int paternityLeave;
  final int workloadPercent;
  final double? salary;
  final double? predictedSalary;

  Job({
    required this.id,
    required this.userUuid,
    required this.title,
    required this.description,
    required this.diplomas,
    required this.contractTime,
    required this.role,
    required this.industry,
    required this.perks,
    required this.languages,
    required this.applications,
    required this.holidays,
    required this.maternityLeave,
    required this.paternityLeave,
    required this.workloadPercent,
    this.salary,
    this.predictedSalary,
  });

  factory Job.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      userUuid: data['userUuid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      diplomas: List<Diplomas>.from(
        (data['diplomas'] as List<dynamic>? ?? const []).map((d) => Diplomas.values.byName(d)),
      ),
      contractTime: data['contractTime'] ?? 0,
      role: Role.values.byName(data['role'] ?? ''),
      industry: Industry.values.byName(data['industry'] ?? ''),
      perks: List<Perks>.from(
        (data['perks'] as List<dynamic>? ?? const []).map((p) => Perks.values.byName(p)),
      ),
      languages: List<Languages>.from(
        (data['languages'] as List<dynamic>? ?? const []).map((l) => Languages.values.byName(l)),
      ),
      applications: (data['applications'] as List<dynamic>? ?? const [])
          .map((a) => JobApplication.fromMap(a as Map<String, dynamic>))
          .toList(),
      holidays: data['holidays'] ?? 20,
      maternityLeave: data['maternityLeave'] ?? 14,
      paternityLeave: data['paternityLeave'] ?? 2,
      workloadPercent: data['workloadPercent'] ?? 100,
      salary: (data['salary'] as num?)?.toDouble(),
      predictedSalary: (data['predictedSalary'] as num?)?.toDouble(),
    );
  }
}