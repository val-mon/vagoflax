import 'package:cloud_firestore/cloud_firestore.dart';

import 'enum/diplomas_model.dart';
import 'enum/role_model.dart';
import 'enum/perks_model.dart';
import 'enum/languages_model.dart';
import 'enum/industry_model.dart';

class Job {
  final String? id;
  final String? userUuid;
  final String title;
  final String description;
  final List<Diplomas> diplomas;
  final int contractTime;
  final Role role;
  final Industry industry;
  final List<Perks> perks;
  final List<Languages> languages;
  final int holidays;
  final int maternityLeave;
  final int paternityLeave;
  final int workloadPercent;
  final double? salary;
  final double? predictedSalary;
  final DateTime? createdAt;
  final bool visible;

  Job({
    this.id,
    this.userUuid,
    required this.title,
    required this.description,
    required this.diplomas,
    required this.contractTime,
    required this.role,
    required this.industry,
    required this.perks,
    required this.languages,
    required this.holidays,
    required this.maternityLeave,
    required this.paternityLeave,
    required this.workloadPercent,
    this.salary,
    this.predictedSalary,
    this.createdAt,
    required this.visible,
  });

  factory Job.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      userUuid: data['userUuid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      diplomas: List<Diplomas>.from(
        (data['diplomas'] as List<dynamic>? ?? const []).map(
          (d) => Diplomas.values.byName(d),
        ),
      ),
      contractTime: data['contractTime'] ?? 0,
      role: Role.values.byName(data['role'] ?? ''),
      industry: Industry.values.byName(data['industry'] ?? ''),
      perks: List<Perks>.from(
        (data['perks'] as List<dynamic>? ?? const []).map(
          (p) => Perks.values.byName(p),
        ),
      ),
      languages: List<Languages>.from(
        (data['languages'] as List<dynamic>? ?? const []).map(
          (l) => Languages.values.byName(l),
        ),
      ),
      holidays: data['holidays'] ?? 20,
      maternityLeave: data['maternityLeave'] ?? 14,
      paternityLeave: data['paternityLeave'] ?? 2,
      workloadPercent: data['workloadPercent'] ?? 100,
      salary: (data['salary'] as num?)?.toDouble(),
      predictedSalary: (data['predictedSalary'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      visible: (data['visible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userUuid': userUuid,
      'title': title,
      'description': description,
      'diplomas': diplomas.map((d) => d.name).toList(),
      'contractTime': contractTime,
      'role': role.name,
      'industry': industry.name,
      'perks': perks.map((p) => p.name).toList(),
      'languages': languages.map((l) => l.name).toList(),
      'holidays': holidays,
      'maternityLeave': maternityLeave,
      'paternityLeave': paternityLeave,
      'workloadPercent': workloadPercent,
      'salary': salary,
      'predictedSalary': predictedSalary,
      'visible': visible,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
