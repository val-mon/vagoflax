import 'dart:convert';
import 'package:http/http.dart' as http;
class AddressSuggestion {
  final String fullAddress;
  final String canton;

  AddressSuggestion({
    required this.fullAddress,
    required this.canton,
  });
}

class AddressService {
  static Future<List<AddressSuggestion>> search(String query) async {
    if (query.trim().length < 3) return [];

    final uri = Uri.parse(
      'https://api3.geo.admin.ch/rest/services/api/SearchServer'
      '?searchText=${Uri.encodeQueryComponent(query)}'
      '&type=locations&origins=address&limit=8',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Address lookup failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);

    return results.map((r) {
      final attrs = r['attrs'] as Map<String, dynamic>;

      final fullAddress = (attrs['label'] as String? ?? '')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();

      String canton = (attrs['detail'] as String? ?? '').toUpperCase();
      canton = canton.substring(canton.length - 2);

      return AddressSuggestion(
        fullAddress: fullAddress,
        canton: canton,
      );
    }).toList();
  }
}