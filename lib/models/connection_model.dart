class Connection {
  final String fromName;
  final String toName;
  final DateTime? departure;
  final DateTime? arrival;
  final String duration;
  final List<String> products;

  Connection({
    required this.fromName,
    required this.toName,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.products,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    final from = json['from'] as Map<String, dynamic>?;
    final to = json['to'] as Map<String, dynamic>?;

    return Connection(
      fromName: from?['station']?['name'] ?? '',
      toName: to?['station']?['name'] ?? '',
      departure: _parse(from?['departure']),
      arrival: _parse(to?['arrival']),
      duration: json['duration'] ?? '',
      products: List<String>.from(json['products'] ?? []),
    );
  }

  static DateTime? _parse(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);
}
