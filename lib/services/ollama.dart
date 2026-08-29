import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:vagoflax/models/translation_model.dart';

// uses api key from .env file (OLLAMA_APIKEY)
class OllamaService {
  void main() async {}

  /// Translates the given JSON to the specified language. Langugage must be given in a two letter format, ex: "en", "fr", etc.
  static Future<JobTranslation> translate(JobTranslation tr) async {
    final apiKey = dotenv.get('OLLAMA_APIKEY');

    final json = {
      "title": tr.title,
      "description": tr.description,
      "language": tr.language.name,
    };

    final prompt =
        "You are a professional translator and must translate the following JSON to the specified language. The JSON is: $json. Return only the valid translated JSON, do not add any other text.";

    final response = await http.post(
      Uri.parse("https://ollama.com/api/generate"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gemma4:31b",
        "prompt": prompt,
        "stream": false, // gives the full response at once instead of streaming
        "format": "json",
      }),
    );

    if (response.statusCode == 200) {
      // 1. Décode la réponse globale d'Ollama
      final Map<String, dynamic> ollamaPayload = jsonDecode(response.body);
      String innerJsonText = ollamaPayload['response'] ?? '';

      // remove markdown
      innerJsonText = innerJsonText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // remove useless prefix
      if (innerJsonText.startsWith('json')) {
        innerJsonText = innerJsonText.substring(4).trim();
      }

      final Map<String, dynamic> translationData = jsonDecode(innerJsonText);

      // make sure we have the language field
      translationData['language'] =
          translationData['language'] ?? tr.language.name;

      return JobTranslation.from(translationData);
    } else {
      throw Exception('Failed to translate JSON: ${response.statusCode}');
    }
  }
}
