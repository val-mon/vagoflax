class Section {
  final String? journeyName; // If null it is a walk section, otherwise it is a transport section with the transport number
  final int? walkDuration;
  final String departureName;
  final String arrivalName;
  final DateTime? departure;
  final DateTime? arrival;
  final int? departureDelay;
  final int? arrivalDelay;

  Section({
    required this.journeyName,
    required this.walkDuration,
    required this.departureName,
    required this.arrivalName,
    required this.departure,
    required this.arrival,
    required this.departureDelay,
    required this.arrivalDelay,
  });

  bool get isWalk => journeyName == null;

  factory Section.fromJson(Map<String, dynamic> json) {
    final journey = json['journey'] as Map<String, dynamic>?;
    final walk = json['walk'] as Map<String, dynamic>?;
    final dep = json['departure'] as Map<String, dynamic>?;
    final arr = json['arrival'] as Map<String, dynamic>?;

    return Section(
      journeyName: journey?['number'] as String?,
      walkDuration: walk?['duration'] as int?,
      departureName: dep?['station']?['name'] ?? '',
      arrivalName: arr?['station']?['name'] ?? '',
      departure: _parse(dep?['departure']),
      arrival: _parse(arr?['arrival']),
      departureDelay: dep?['delay'] as int?,
      arrivalDelay: arr?['delay'] as int?,
    );
  }

  static DateTime? _parse(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);
}
