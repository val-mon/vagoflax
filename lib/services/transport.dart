import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vagoflax/models/connection_model.dart';

class TransportService {
  static const _base = 'https://transport.opendata.ch/v1';

  static Future<List<Connection>> getConnections(
    String from,
    String to,
  ) async {
    final uri = Uri.parse('$_base/connections').replace(queryParameters: {
      'from': from,
      'to': to,
      'limit': '5',
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Erreur API transport: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['connections'] as List?) ?? [];
    return list
        .map((c) => Connection.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}