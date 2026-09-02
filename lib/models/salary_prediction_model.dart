import 'package:vagoflax/models/enum/diplomas.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/models/enum/languages.dart';
import 'package:vagoflax/models/enum/perks.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/user.dart';

class SalaryPredictionInput {
  final double minYearsExperience;
  final double contract;
  final bool isPermanent;
  final double holidays;
  final double workloadPercent;

  final String diploma;
  final String role;
  final String industry;
  final String canton;
  final String companySize;
  final List<String> perks;
  final List<String> languages;

  const SalaryPredictionInput({
    required this.minYearsExperience,
    required this.contract,
    required this.isPermanent,
    required this.holidays,
    required this.workloadPercent,
    required this.diploma,
    required this.role,
    required this.industry,
    required this.canton,
    required this.companySize,
    required this.perks,
    required this.languages,
  });

  factory SalaryPredictionInput.fromJobAndEmployer({
    required Job job,
    required User employer,
  }) {
    final minExperience = job.minYearsExperience;
    final contract = job.contractTime;
    final holidays = job.holidays;
    final workloadPercent = job.workloadPercent;
    final companySize = employer.companySize;

    if (minExperience == null) {
      throw ArgumentError('The minimum years of experience is required.');
    }
    if (minExperience < 0) {
      throw ArgumentError('The job experience minimum is invalid.');
    }
    if (contract == null) {
      throw ArgumentError('The contract duration is required.');
    }
    if (contract < 0) {
      throw ArgumentError('The contract duration cannot be negative.');
    }
    if (holidays == null) {
      throw ArgumentError('The number of holidays is required.');
    }
    if (holidays < 0) {
      throw ArgumentError('The number of holidays cannot be negative.');
    }
    if (workloadPercent == null) {
      throw ArgumentError('The workload percentage is required.');
    }
    if (workloadPercent <= 0 || workloadPercent > 100) {
      throw ArgumentError('The workload percentage must be between 1 and 100.');
    }
    if (employer.canton.trim().isEmpty) {
      throw ArgumentError('The employer canton is required.');
    }
    if (companySize == null || companySize <= 0) {
      throw ArgumentError('The employer company size is required.');
    }

    return SalaryPredictionInput(
      minYearsExperience: minExperience.toDouble(),
      contract: contract.toDouble(),
      isPermanent: contract == 0,
      holidays: holidays.toDouble(),
      workloadPercent: workloadPercent.toDouble(),
      diploma: _diplomaLabel(job.diploma),
      role: _roleLabel(job.role),
      industry: _industryLabel(job.industry),
      canton: employer.canton.trim().toUpperCase(),
      companySize: _companySizeLabel(companySize),
      perks: job.perks.map(_perkLabel).toList(growable: false),
      languages: job.languages.map(_languageLabel).toList(growable: false),
    );
  }

  static String _diplomaLabel(Diplomas diploma) => switch (diploma) {
    Diplomas.apprenticeship => 'Apprenticeship',
    Diplomas.bachelor => 'Bachelor',
    Diplomas.master => 'Master',
    Diplomas.phd => 'PhD',
  };

  static String _roleLabel(Role role) => switch (role) {
    Role.junior => 'Junior',
    Role.midLevel => 'Mid-level',
    Role.senior => 'Senior',
    Role.manager => 'Manager',
    Role.lead => 'Lead',
    Role.director => 'Director',
    Role.intern => 'Intern',
  };

  static String _industryLabel(Industry industry) => switch (industry) {
    Industry.construction => 'Construction',
    Industry.consulting => 'Consulting',
    Industry.education => 'Education',
    Industry.energy => 'Energy',
    Industry.finance => 'Finance',
    Industry.healthcare => 'Healthcare',
    Industry.hospitality => 'Hospitality',
    Industry.informationTechnology => 'IT',
    Industry.manufacturing => 'Manufacturing',
    Industry.pharmaceuticals => 'Pharma',
    Industry.publicSector => 'Public Sector',
    Industry.retail => 'Retail',
  };

  static String _perkLabel(Perks perk) => switch (perk) {
    Perks.ag => 'AG (train pass)',
    Perks.car => 'Car',
    Perks.housingSupport => 'Housing support',
    Perks.mealVouchers => 'Meal vouchers',
    Perks.stockOptions => 'Stock options',
  };

  static String _languageLabel(Languages language) => switch (language) {
    Languages.english => 'English',
    Languages.french => 'French',
    Languages.german => 'German',
    Languages.italian => 'Italian',
  };

  static String _companySizeLabel(int companySize) {
    if (companySize < 50) return 'Startup (<50)';
    if (companySize < 200) return 'Small (50-200)';
    if (companySize < 1000) return 'Medium (200-1000)';
    return 'Large (1000+)';
  }
}
