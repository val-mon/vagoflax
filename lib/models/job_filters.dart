import 'package:vagoflax/models/enum/diplomas_model.dart';
import 'package:vagoflax/models/enum/industry_model.dart';
import 'package:vagoflax/models/enum/languages_model.dart';
import 'package:vagoflax/models/enum/role_model.dart';

class JobFilters {
  final double? minSalary;
  final double? maxSalary;

  final Set<Diplomas> diplomas;
  final Set<Role> roles;
  final Set<Industry> industries;
  final Set<Languages> languages;

  const JobFilters({
    this.minSalary,
    this.maxSalary,
    this.diplomas = const {},
    this.roles = const {},
    this.industries = const {},
    this.languages = const {},
  });

  bool get isEmpty =>
      minSalary == null &&
      maxSalary == null &&
      diplomas.isEmpty &&
      roles.isEmpty &&
      industries.isEmpty &&
      languages.isEmpty;

  int get activeFilterCount {
    int count = 0;

    if (minSalary != null || maxSalary != null) {
      count++;
    }

    if (diplomas.isNotEmpty) {
      count++;
    }

    if (roles.isNotEmpty) {
      count++;
    }

    if (industries.isNotEmpty) {
      count++;
    }

    if (languages.isNotEmpty) {
      count++;
    }

    return count;
  }

  JobFilters copyWith({
    double? minSalary,
    double? maxSalary,
    Set<Diplomas>? diplomas,
    Set<Role>? roles,
    Set<Industry>? industries,
    Set<Languages>? languages,
  }) {
    return JobFilters(
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      diplomas: diplomas ?? this.diplomas,
      roles: roles ?? this.roles,
      industries: industries ?? this.industries,
      languages: languages ?? this.languages,
    );
  }
}
