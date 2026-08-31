import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vagoflax/models/translation.dart';

import 'package:vagoflax/models/enum/diplomas.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/enum/perks.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/industry.dart';

class Job {
  final String? id;
  final String? userUuid;
  final String title;
  final String? description;
  final List<Diplomas> diplomas;
  final int? contractTime;
  final Role role;
  final Industry industry;
  final List<Perks> perks;
  final List<Languages> languages;
  final int? holidays;
  final int? maternityLeave;
  final int? paternityLeave;
  final int? workloadPercent;
  final double? salary;
  final double? predictedSalary;
  final DateTime? createdAt;
  final bool visible;
  final List<JobTranslation> translations;

  Job({
    this.id,
    this.userUuid,
    required this.title,
    this.description,
    required this.diplomas,
    this.contractTime,
    required this.role,
    required this.industry,
    required this.perks,
    required this.languages,
    this.holidays,
    this.maternityLeave,
    this.paternityLeave,
    this.workloadPercent,
    this.salary,
    this.predictedSalary,
    this.createdAt,
    required this.visible,
    required this.translations,
  });

  factory Job.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      userUuid: data['userUuid']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString(),
      diplomas: (data['diplomas'] as List<dynamic>? ?? const [])
          .map(
            (d) => Diplomas.values.firstWhere(
              (e) => e.name.toLowerCase() == d.toString().toLowerCase(),
              orElse: () => Diplomas.values.first,
            ),
          )
          .toList(),
      contractTime: (data['contractTime'] as num?)?.toInt(),
      role: Role.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (data['role'] ?? '').toString().toLowerCase(),
        orElse: () => Role.values.first,
      ),
      industry: Industry.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (data['industry'] ?? '').toString().toLowerCase(),
        orElse: () => Industry.values.first,
      ),
      perks: (data['perks'] as List<dynamic>? ?? const [])
          .map(
            (p) => Perks.values.firstWhere(
              (e) => e.name.toLowerCase() == p.toString().toLowerCase(),
              orElse: () => Perks.values.first,
            ),
          )
          .toList(),
      languages: (data['languages'] as List<dynamic>? ?? const [])
          .map(
            (l) => Languages.values.firstWhere(
              (e) => e.name.toLowerCase() == l.toString().toLowerCase(),
              orElse: () => Languages.values.first,
            ),
          )
          .toList(),
      holidays: (data['holidays'] as num?)?.toInt(),
      maternityLeave: (data['maternityLeave'] as num?)?.toInt(),
      paternityLeave: (data['paternityLeave'] as num?)?.toInt(),
      workloadPercent: (data['workloadPercent'] as num?)?.toInt(),
      salary: (data['salary'] as num?)?.toDouble(),
      predictedSalary: (data['predictedSalary'] as num?)?.toDouble(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] is String
                ? DateTime.tryParse(data['createdAt'] as String)
                : null),
      visible: (data['visible'] as bool?) ?? true,
      translations: (data['translations'] as List<dynamic>? ?? [])
          .map((t) => JobTranslation.from(Map<String, dynamic>.from(t as Map)))
          .toList(),
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
      'translations': translations
          .map(
            (t) => {
              'title': t.title,
              'description': t.description,
              'language': t.language?.name,
            },
          )
          .toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// can return an error if the translation is not found, so make sure to handle that in the calling code.
  JobTranslation findTranslationByLanguage(Languages language) {
    return translations.firstWhere((t) => t.language == language);
  }
}
