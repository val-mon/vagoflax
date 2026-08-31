class SalaryPredictionInput {
  final double minYearsExperience;
  final double maxYearsExperience;
  final int contractMonths;
  final bool isPermanent;
  final int holidays;
  final int workloadPercent;

  final String diploma;
  final String role;
  final String industry;
  final String citySize;
  final String canton;
  final String companySize;

  final List<String> perks;
  final List<String> languages;

  const SalaryPredictionInput({
    required this.minYearsExperience,
    required this.maxYearsExperience,
    required this.contractMonths,
    required this.isPermanent,
    required this.holidays,
    required this.workloadPercent,
    required this.diploma,
    required this.role,
    required this.industry,
    required this.citySize,
    required this.canton,
    required this.companySize,
    required this.perks,
    required this.languages,
  });
}
