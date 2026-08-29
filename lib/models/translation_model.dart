import 'package:vagoflax/models/enum/languages_model.dart';

class JobTranslation {
  final String title;
  final String description;
  final Languages? language;

  JobTranslation({
    required this.title,
    required this.description,
    required this.language,
  });

  factory JobTranslation.from(Map<String, dynamic> json) {
    return JobTranslation(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: Languages.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => Languages.english,
      ),
    );
  }
}
